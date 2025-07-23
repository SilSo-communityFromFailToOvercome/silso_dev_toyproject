// lib/services/comment_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';
import '../models/post.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _commentsCollection = 'comments';
  final String _postsCollection = 'posts';
  final String _reactionsCollection = 'reactions';
  final String _membershipsCollection = 'community_memberships';

  // Create a new comment
  Future<String> createComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String content,
    String? parentCommentId,
  }) async {
    final batch = _firestore.batch();

    try {
      final commentRef = _firestore.collection(_commentsCollection).doc();
      final comment = Comment(
        id: commentRef.id,
        postId: postId,
        authorId: authorId,
        authorName: authorName,
        content: content,
        parentCommentId: parentCommentId,
        reactionCounts: {for (final reactionType in ReactionType.values) reactionType: 0},
        replyCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isReported: false,
        isModerated: false,
      );

      batch.set(commentRef, comment.toFirestore());

      // Update post comment count
      final postRef = _firestore.collection(_postsCollection).doc(postId);
      batch.update(postRef, {
        'commentCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If this is a reply, update parent comment reply count
      if (parentCommentId != null) {
        final parentCommentRef = _firestore.collection(_commentsCollection).doc(parentCommentId);
        batch.update(parentCommentRef, {
          'replyCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Update user's comment count in membership
      final post = await _firestore.collection(_postsCollection).doc(postId).get();
      if (post.exists) {
        final postData = post.data() as Map<String, dynamic>;
        final communityId = postData['communityId'];

        final membershipQuery = await _firestore
            .collection(_membershipsCollection)
            .where('userId', isEqualTo: authorId)
            .where('communityId', isEqualTo: communityId)
            .get();

        if (membershipQuery.docs.isNotEmpty) {
          final membershipRef = membershipQuery.docs.first.reference;
          batch.update(membershipRef, {
            'commentCount': FieldValue.increment(1),
          });
        }
      }

      await batch.commit();
      return commentRef.id;
    } catch (e) {
      throw Exception('Failed to create comment: $e');
    }
  }

  // Get comments for a post
  Future<List<Comment>> getComments(String postId, {int limit = 50}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_commentsCollection)
          .where('postId', isEqualTo: postId)
          .where('isModerated', isEqualTo: false)
          .orderBy('createdAt', descending: false) // Oldest first for threading
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        return Comment.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get comments: $e');
    }
  }

  // Get comments stream for real-time updates
  Stream<List<Comment>> getCommentsStream(String postId, {int limit = 50}) {
    return _firestore
        .collection(_commentsCollection)
        .where('postId', isEqualTo: postId)
        .where('isModerated', isEqualTo: false)
        .orderBy('createdAt', descending: false)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Comment.fromFirestore(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  // Get replies for a comment
  Future<List<Comment>> getReplies(String parentCommentId, {int limit = 20}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_commentsCollection)
          .where('parentCommentId', isEqualTo: parentCommentId)
          .where('isModerated', isEqualTo: false)
          .orderBy('createdAt', descending: false)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        return Comment.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get replies: $e');
    }
  }

  // Get single comment
  Future<Comment?> getComment(String commentId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_commentsCollection)
          .doc(commentId)
          .get();

      if (doc.exists && doc.data() != null) {
        return Comment.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get comment: $e');
    }
  }

  // Add reaction to comment
  Future<void> addReactionToComment(String commentId, String userId, ReactionType reactionType) async {
    final batch = _firestore.batch();

    try {
      // Check if user already reacted
      final existingReaction = await _firestore
          .collection(_reactionsCollection)
          .where('commentId', isEqualTo: commentId)
          .where('userId', isEqualTo: userId)
          .get();

      if (existingReaction.docs.isNotEmpty) {
        // Remove existing reaction first
        for (final doc in existingReaction.docs) {
          final oldReaction = Reaction.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          batch.delete(doc.reference);
          
          // Decrement old reaction count
          final commentRef = _firestore.collection(_commentsCollection).doc(commentId);
          batch.update(commentRef, {
            'reactionCounts.${oldReaction.type.name}': FieldValue.increment(-1),
          });
        }
      }

      // Add new reaction
      final reactionRef = _firestore.collection(_reactionsCollection).doc();
      final reaction = Reaction(
        id: reactionRef.id,
        userId: userId,
        type: reactionType,
        createdAt: DateTime.now(),
      );

      batch.set(reactionRef, {
        ...reaction.toFirestore(),
        'commentId': commentId,
      });

      // Increment new reaction count
      final commentRef = _firestore.collection(_commentsCollection).doc(commentId);
      batch.update(commentRef, {
        'reactionCounts.${reactionType.name}': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to add reaction to comment: $e');
    }
  }

  // Remove reaction from comment
  Future<void> removeReactionFromComment(String commentId, String userId) async {
    final batch = _firestore.batch();

    try {
      final reactions = await _firestore
          .collection(_reactionsCollection)
          .where('commentId', isEqualTo: commentId)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in reactions.docs) {
        final reaction = Reaction.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        batch.delete(doc.reference);

        // Decrement reaction count
        final commentRef = _firestore.collection(_commentsCollection).doc(commentId);
        batch.update(commentRef, {
          'reactionCounts.${reaction.type.name}': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to remove reaction from comment: $e');
    }
  }

  // Get user's reaction to a comment
  Future<ReactionType?> getUserCommentReaction(String commentId, String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_reactionsCollection)
          .where('commentId', isEqualTo: commentId)
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final reaction = Reaction.fromFirestore(snapshot.docs.first.data() as Map<String, dynamic>, snapshot.docs.first.id);
        return reaction.type;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user comment reaction: $e');
    }
  }

  // Report comment
  Future<void> reportComment(String commentId, String userId, String reason) async {
    try {
      await _firestore.collection('reports').add({
        'commentId': commentId,
        'reportedBy': userId,
        'reason': reason,
        'type': 'comment',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      // Mark comment as reported
      await _firestore.collection(_commentsCollection).doc(commentId).update({
        'isReported': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to report comment: $e');
    }
  }

  // Get threaded comments (organize comments and replies)
  Future<List<Comment>> getThreadedComments(String postId) async {
    try {
      final comments = await getComments(postId);
      
      // Separate root comments and replies
      final rootComments = comments.where((c) => c.parentCommentId == null).toList();
      final replies = comments.where((c) => c.parentCommentId != null).toList();
      
      // For simple implementation, return root comments first, then replies
      // In a more complex implementation, you'd nest replies under their parents
      return [...rootComments, ...replies];
    } catch (e) {
      throw Exception('Failed to get threaded comments: $e');
    }
  }
}
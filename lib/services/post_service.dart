// lib/services/post_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _postsCollection = 'posts';
  final String _reactionsCollection = 'reactions';
  final String _membershipsCollection = 'community_memberships';

  // Create a new post
  Future<String> createPost({
    required String authorId,
    required String authorName,
    required String communityId,
    required String title,
    required String content,
    required PostType type,
    required List<String> tags,
  }) async {
    final batch = _firestore.batch();

    try {
      final postRef = _firestore.collection(_postsCollection).doc();
      final post = Post(
        id: postRef.id,
        authorId: authorId,
        authorName: authorName,
        communityId: communityId,
        title: title,
        content: content,
        type: type,
        tags: tags,
        reactionCounts: {for (final reactionType in ReactionType.values) reactionType: 0},
        commentCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isReported: false,
        isModerated: false,
      );

      batch.set(postRef, post.toFirestore());

      // Update user's post count in membership
      final membershipQuery = await _firestore
          .collection(_membershipsCollection)
          .where('userId', isEqualTo: authorId)
          .where('communityId', isEqualTo: communityId)
          .get();

      if (membershipQuery.docs.isNotEmpty) {
        final membershipRef = membershipQuery.docs.first.reference;
        batch.update(membershipRef, {
          'postCount': FieldValue.increment(1),
        });
      }

      // Update community activity
      final communityRef = _firestore.collection('communities').doc(communityId);
      batch.update(communityRef, {
        'lastActivityAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return postRef.id;
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Get posts for a community
  Future<List<Post>> getPosts(String communityId, {int limit = 20}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_postsCollection)
          .where('communityId', isEqualTo: communityId)
          .where('isModerated', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        return Post.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get posts: $e');
    }
  }

  // Get posts stream for real-time updates
  Stream<List<Post>> getPostsStream(String communityId, {int limit = 20}) {
    return _firestore
        .collection(_postsCollection)
        .where('communityId', isEqualTo: communityId)
        .where('isModerated', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Post.fromFirestore(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  // Get single post
  Future<Post?> getPost(String postId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_postsCollection)
          .doc(postId)
          .get();

      if (doc.exists && doc.data() != null) {
        return Post.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get post: $e');
    }
  }

  // Add reaction to post
  Future<void> addReactionToPost(String postId, String userId, ReactionType reactionType) async {
    final batch = _firestore.batch();

    try {
      // Check if user already reacted
      final existingReaction = await _firestore
          .collection(_reactionsCollection)
          .where('postId', isEqualTo: postId)
          .where('userId', isEqualTo: userId)
          .get();

      if (existingReaction.docs.isNotEmpty) {
        // Remove existing reaction first
        for (final doc in existingReaction.docs) {
          final oldReaction = Reaction.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          batch.delete(doc.reference);
          
          // Decrement old reaction count
          final postRef = _firestore.collection(_postsCollection).doc(postId);
          batch.update(postRef, {
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
        'postId': postId,
      });

      // Increment new reaction count
      final postRef = _firestore.collection(_postsCollection).doc(postId);
      batch.update(postRef, {
        'reactionCounts.${reactionType.name}': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to add reaction: $e');
    }
  }

  // Remove reaction from post
  Future<void> removeReactionFromPost(String postId, String userId) async {
    final batch = _firestore.batch();

    try {
      final reactions = await _firestore
          .collection(_reactionsCollection)
          .where('postId', isEqualTo: postId)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in reactions.docs) {
        final reaction = Reaction.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        batch.delete(doc.reference);

        // Decrement reaction count
        final postRef = _firestore.collection(_postsCollection).doc(postId);
        batch.update(postRef, {
          'reactionCounts.${reaction.type.name}': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to remove reaction: $e');
    }
  }

  // Get user's reaction to a post
  Future<ReactionType?> getUserReaction(String postId, String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_reactionsCollection)
          .where('postId', isEqualTo: postId)
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final reaction = Reaction.fromFirestore(snapshot.docs.first.data() as Map<String, dynamic>, snapshot.docs.first.id);
        return reaction.type;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user reaction: $e');
    }
  }

  // Report post
  Future<void> reportPost(String postId, String userId, String reason) async {
    try {
      await _firestore.collection('reports').add({
        'postId': postId,
        'reportedBy': userId,
        'reason': reason,
        'type': 'post',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      // Mark post as reported
      await _firestore.collection(_postsCollection).doc(postId).update({
        'isReported': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to report post: $e');
    }
  }

  // Search posts
  Future<List<Post>> searchPosts(String query, String communityId) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a simple title search. For better search, consider using Algolia or similar
      final QuerySnapshot snapshot = await _firestore
          .collection(_postsCollection)
          .where('communityId', isEqualTo: communityId)
          .where('isModerated', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      final posts = snapshot.docs.map((doc) {
        return Post.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      // Filter by query on client side (simple search)
      return posts.where((post) {
        final searchText = query.toLowerCase();
        return post.title.toLowerCase().contains(searchText) ||
               post.content.toLowerCase().contains(searchText) ||
               post.tags.any((tag) => tag.toLowerCase().contains(searchText));
      }).toList();
    } catch (e) {
      throw Exception('Failed to search posts: $e');
    }
  }
}
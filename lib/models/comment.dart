// lib/models/comment.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post.dart';

class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String content;
  final String? parentCommentId;
  final Map<ReactionType, int> reactionCounts;
  final int replyCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isReported;
  final bool isModerated;

  Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.content,
    this.parentCommentId,
    required this.reactionCounts,
    required this.replyCount,
    required this.createdAt,
    required this.updatedAt,
    required this.isReported,
    required this.isModerated,
  });

  factory Comment.fromFirestore(Map<String, dynamic> data, String id) {
    final reactions = Map<String, dynamic>.from(data['reactionCounts'] ?? {});
    final reactionCounts = <ReactionType, int>{};
    for (final reactionType in ReactionType.values) {
      reactionCounts[reactionType] = reactions[reactionType.name] ?? 0;
    }

    return Comment(
      id: id,
      postId: data['postId'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      content: data['content'] ?? '',
      parentCommentId: data['parentCommentId'],
      reactionCounts: reactionCounts,
      replyCount: data['replyCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isReported: data['isReported'] ?? false,
      isModerated: data['isModerated'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    final reactions = <String, int>{};
    for (final entry in reactionCounts.entries) {
      reactions[entry.key.name] = entry.value;
    }

    return {
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'parentCommentId': parentCommentId,
      'reactionCounts': reactions,
      'replyCount': replyCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isReported': isReported,
      'isModerated': isModerated,
    };
  }

  Comment copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? authorName,
    String? content,
    String? parentCommentId,
    Map<ReactionType, int>? reactionCounts,
    int? replyCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isReported,
    bool? isModerated,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      reactionCounts: reactionCounts ?? this.reactionCounts,
      replyCount: replyCount ?? this.replyCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isReported: isReported ?? this.isReported,
      isModerated: isModerated ?? this.isModerated,
    );
  }

  int get totalReactions => reactionCounts.values.fold(0, (total, reactionCount) => total + reactionCount);
  bool get isReply => parentCommentId != null;
}
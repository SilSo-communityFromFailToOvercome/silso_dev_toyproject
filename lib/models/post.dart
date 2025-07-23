// lib/models/post.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum PostType {
  story,
  question,
  advice,
  support
}

extension PostTypeExtension on PostType {
  String get displayName {
    switch (this) {
      case PostType.story:
        return 'Story';
      case PostType.question:
        return 'Question';
      case PostType.advice:
        return 'Advice';
      case PostType.support:
        return 'Support';
    }
  }

  String get emoji {
    switch (this) {
      case PostType.story:
        return '📖';
      case PostType.question:
        return '❓';
      case PostType.advice:
        return '💡';
      case PostType.support:
        return '🤝';
    }
  }
}

enum ReactionType {
  empathy,
  support,
  helpful,
  inspiring,
  thankful
}

extension ReactionTypeExtension on ReactionType {
  String get emoji {
    switch (this) {
      case ReactionType.empathy:
        return '💙';
      case ReactionType.support:
        return '🤗';
      case ReactionType.helpful:
        return '👍';
      case ReactionType.inspiring:
        return '⭐';
      case ReactionType.thankful:
        return '🙏';
    }
  }

  String get label {
    switch (this) {
      case ReactionType.empathy:
        return 'Empathy';
      case ReactionType.support:
        return 'Support';
      case ReactionType.helpful:
        return 'Helpful';
      case ReactionType.inspiring:
        return 'Inspiring';
      case ReactionType.thankful:
        return 'Thankful';
    }
  }
}

class Reaction {
  final String id;
  final String userId;
  final ReactionType type;
  final DateTime createdAt;

  Reaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.createdAt,
  });

  factory Reaction.fromFirestore(Map<String, dynamic> data, String id) {
    return Reaction(
      id: id,
      userId: data['userId'] ?? '',
      type: ReactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ReactionType.support,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String communityId;
  final String title;
  final String content;
  final PostType type;
  final List<String> tags;
  final Map<ReactionType, int> reactionCounts;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isReported;
  final bool isModerated;

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.communityId,
    required this.title,
    required this.content,
    required this.type,
    required this.tags,
    required this.reactionCounts,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
    required this.isReported,
    required this.isModerated,
  });

  factory Post.fromFirestore(Map<String, dynamic> data, String id) {
    final reactions = Map<String, dynamic>.from(data['reactionCounts'] ?? {});
    final reactionCounts = <ReactionType, int>{};
    for (final reactionType in ReactionType.values) {
      reactionCounts[reactionType] = reactions[reactionType.name] ?? 0;
    }

    return Post(
      id: id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      communityId: data['communityId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      type: PostType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => PostType.story,
      ),
      tags: List<String>.from(data['tags'] ?? []),
      reactionCounts: reactionCounts,
      commentCount: data['commentCount'] ?? 0,
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
      'authorId': authorId,
      'authorName': authorName,
      'communityId': communityId,
      'title': title,
      'content': content,
      'type': type.name,
      'tags': tags,
      'reactionCounts': reactions,
      'commentCount': commentCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isReported': isReported,
      'isModerated': isModerated,
    };
  }

  Post copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? communityId,
    String? title,
    String? content,
    PostType? type,
    List<String>? tags,
    Map<ReactionType, int>? reactionCounts,
    int? commentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isReported,
    bool? isModerated,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      communityId: communityId ?? this.communityId,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      reactionCounts: reactionCounts ?? this.reactionCounts,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isReported: isReported ?? this.isReported,
      isModerated: isModerated ?? this.isModerated,
    );
  }

  int get totalReactions => reactionCounts.values.fold(0, (total, reactionCount) => total + reactionCount);
}
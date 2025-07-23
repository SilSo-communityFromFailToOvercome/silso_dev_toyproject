// lib/models/community_membership.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum MembershipRole {
  member,
  moderator,
  admin
}

extension MembershipRoleExtension on MembershipRole {
  String get displayName {
    switch (this) {
      case MembershipRole.member:
        return 'Member';
      case MembershipRole.moderator:
        return 'Moderator';
      case MembershipRole.admin:
        return 'Admin';
    }
  }
}

class CommunityMembership {
  final String id;
  final String userId;
  final String communityId;
  final MembershipRole role;
  final DateTime joinedAt;
  final int postCount;
  final int commentCount;
  final int helpfulReactionsReceived;
  final bool isActive;

  CommunityMembership({
    required this.id,
    required this.userId,
    required this.communityId,
    required this.role,
    required this.joinedAt,
    required this.postCount,
    required this.commentCount,
    required this.helpfulReactionsReceived,
    required this.isActive,
  });

  factory CommunityMembership.fromFirestore(Map<String, dynamic> data, String id) {
    return CommunityMembership(
      id: id,
      userId: data['userId'] ?? '',
      communityId: data['communityId'] ?? '',
      role: MembershipRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => MembershipRole.member,
      ),
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      postCount: data['postCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      helpfulReactionsReceived: data['helpfulReactionsReceived'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'communityId': communityId,
      'role': role.name,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'postCount': postCount,
      'commentCount': commentCount,
      'helpfulReactionsReceived': helpfulReactionsReceived,
      'isActive': isActive,
    };
  }

  CommunityMembership copyWith({
    String? id,
    String? userId,
    String? communityId,
    MembershipRole? role,
    DateTime? joinedAt,
    int? postCount,
    int? commentCount,
    int? helpfulReactionsReceived,
    bool? isActive,
  }) {
    return CommunityMembership(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      communityId: communityId ?? this.communityId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      postCount: postCount ?? this.postCount,
      commentCount: commentCount ?? this.commentCount,
      helpfulReactionsReceived: helpfulReactionsReceived ?? this.helpfulReactionsReceived,
      isActive: isActive ?? this.isActive,
    );
  }

  int get totalContributions => postCount + commentCount;
}
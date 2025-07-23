// lib/models/community.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum FailureCategory {
  academic,
  career,
  employment,
  entrepreneurship,
  relationship,
  housing,
  personal,
  health,
  financial
}

extension FailureCategoryExtension on FailureCategory {
  String get displayName {
    switch (this) {
      case FailureCategory.academic:
        return 'Academic';
      case FailureCategory.career:
        return 'Career';
      case FailureCategory.employment:
        return 'Employment';
      case FailureCategory.entrepreneurship:
        return 'Entrepreneurship';
      case FailureCategory.relationship:
        return 'Relationship';
      case FailureCategory.housing:
        return 'Housing';
      case FailureCategory.personal:
        return 'Personal Growth';
      case FailureCategory.health:
        return 'Health & Wellness';
      case FailureCategory.financial:
        return 'Financial';
    }
  }

  String get description {
    switch (this) {
      case FailureCategory.academic:
        return 'Share academic challenges, study failures, and learning experiences';
      case FailureCategory.career:
        return 'Discuss career setbacks, professional growth, and workplace challenges';
      case FailureCategory.employment:
        return 'Connect over job search struggles, interviews, and employment issues';
      case FailureCategory.entrepreneurship:
        return 'Share startup failures, business lessons, and entrepreneurial journeys';
      case FailureCategory.relationship:
        return 'Support each other through relationship challenges and personal connections';
      case FailureCategory.housing:
        return 'Discuss housing struggles, living situations, and home-related challenges';
      case FailureCategory.personal:
        return 'Share personal development challenges and self-improvement journeys';
      case FailureCategory.health:
        return 'Support each other through health challenges and wellness journeys';
      case FailureCategory.financial:
        return 'Discuss financial setbacks, money management, and economic challenges';
    }
  }

  String get emoji {
    switch (this) {
      case FailureCategory.academic:
        return '📚';
      case FailureCategory.career:
        return '💼';
      case FailureCategory.employment:
        return '👥';
      case FailureCategory.entrepreneurship:
        return '🚀';
      case FailureCategory.relationship:
        return '💝';
      case FailureCategory.housing:
        return '🏠';
      case FailureCategory.personal:
        return '🌱';
      case FailureCategory.health:
        return '💪';
      case FailureCategory.financial:
        return '💰';
    }
  }
}

class Community {
  final String id;
  final String name;
  final FailureCategory category;
  final String description;
  final int memberCount;
  final bool isActive;
  final List<String> moderatorIds;
  final DateTime createdAt;
  final DateTime lastActivityAt;

  Community({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.memberCount,
    required this.isActive,
    required this.moderatorIds,
    required this.createdAt,
    required this.lastActivityAt,
  });

  factory Community.fromFirestore(Map<String, dynamic> data, String id) {
    return Community(
      id: id,
      name: data['name'] ?? '',
      category: FailureCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => FailureCategory.personal,
      ),
      description: data['description'] ?? '',
      memberCount: data['memberCount'] ?? 0,
      isActive: data['isActive'] ?? true,
      moderatorIds: List<String>.from(data['moderatorIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActivityAt: (data['lastActivityAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category.name,
      'description': description,
      'memberCount': memberCount,
      'isActive': isActive,
      'moderatorIds': moderatorIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActivityAt': Timestamp.fromDate(lastActivityAt),
    };
  }

  Community copyWith({
    String? id,
    String? name,
    FailureCategory? category,
    String? description,
    int? memberCount,
    bool? isActive,
    List<String>? moderatorIds,
    DateTime? createdAt,
    DateTime? lastActivityAt,
  }) {
    return Community(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      memberCount: memberCount ?? this.memberCount,
      isActive: isActive ?? this.isActive,
      moderatorIds: moderatorIds ?? this.moderatorIds,
      createdAt: createdAt ?? this.createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }
}
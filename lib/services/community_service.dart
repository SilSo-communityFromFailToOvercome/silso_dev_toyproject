// lib/services/community_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/community.dart';
import '../models/community_membership.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _communitiesCollection = 'communities';
  final String _membershipsCollection = 'community_memberships';

  // Get all active communities
  Future<List<Community>> getCommunities() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_communitiesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('memberCount', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return Community.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get communities: $e');
    }
  }

  // Get communities by category
  Future<List<Community>> getCommunitiesByCategory(FailureCategory category) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_communitiesCollection)
          .where('category', isEqualTo: category.name)
          .where('isActive', isEqualTo: true)
          .orderBy('memberCount', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return Community.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get communities by category: $e');
    }
  }

  // Get single community
  Future<Community?> getCommunity(String communityId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_communitiesCollection)
          .doc(communityId)
          .get();

      if (doc.exists && doc.data() != null) {
        return Community.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get community: $e');
    }
  }

  // Get communities stream for real-time updates
  Stream<List<Community>> getCommunitiesStream() {
    return _firestore
        .collection(_communitiesCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('lastActivityAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Community.fromFirestore(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  // Join a community
  Future<void> joinCommunity(String userId, String communityId) async {
    final batch = _firestore.batch();

    try {
      // Check if already a member
      final existingMembership = await _firestore
          .collection(_membershipsCollection)
          .where('userId', isEqualTo: userId)
          .where('communityId', isEqualTo: communityId)
          .get();

      if (existingMembership.docs.isNotEmpty) {
        throw Exception('User is already a member of this community');
      }

      // Create membership
      final membershipRef = _firestore.collection(_membershipsCollection).doc();
      final membership = CommunityMembership(
        id: membershipRef.id,
        userId: userId,
        communityId: communityId,
        role: MembershipRole.member,
        joinedAt: DateTime.now(),
        postCount: 0,
        commentCount: 0,
        helpfulReactionsReceived: 0,
        isActive: true,
      );

      batch.set(membershipRef, membership.toFirestore());

      // Update community member count
      final communityRef = _firestore.collection(_communitiesCollection).doc(communityId);
      batch.update(communityRef, {
        'memberCount': FieldValue.increment(1),
        'lastActivityAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to join community: $e');
    }
  }

  // Leave a community
  Future<void> leaveCommunity(String userId, String communityId) async {
    final batch = _firestore.batch();

    try {
      // Find membership
      final membershipQuery = await _firestore
          .collection(_membershipsCollection)
          .where('userId', isEqualTo: userId)
          .where('communityId', isEqualTo: communityId)
          .get();

      if (membershipQuery.docs.isEmpty) {
        throw Exception('User is not a member of this community');
      }

      // Delete membership
      for (final doc in membershipQuery.docs) {
        batch.delete(doc.reference);
      }

      // Update community member count
      final communityRef = _firestore.collection(_communitiesCollection).doc(communityId);
      batch.update(communityRef, {
        'memberCount': FieldValue.increment(-1),
        'lastActivityAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to leave community: $e');
    }
  }

  // Get user's community memberships
  Future<List<CommunityMembership>> getUserMemberships(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_membershipsCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        return CommunityMembership.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user memberships: $e');
    }
  }

  // Check if user is member of community
  Future<bool> isUserMember(String userId, String communityId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_membershipsCollection)
          .where('userId', isEqualTo: userId)
          .where('communityId', isEqualTo: communityId)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check membership: $e');
    }
  }

  // Get user's membership for a specific community
  Future<CommunityMembership?> getUserMembership(String userId, String communityId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_membershipsCollection)
          .where('userId', isEqualTo: userId)
          .where('communityId', isEqualTo: communityId)
          .where('isActive', isEqualTo: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return CommunityMembership.fromFirestore(
          snapshot.docs.first.data() as Map<String, dynamic>,
          snapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user membership: $e');
    }
  }

  // Update community activity
  Future<void> updateCommunityActivity(String communityId) async {
    try {
      await _firestore.collection(_communitiesCollection).doc(communityId).update({
        'lastActivityAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update community activity: $e');
    }
  }

  // Initialize default communities (call once during app setup)
  Future<void> initializeDefaultCommunities() async {
    try {
      final batch = _firestore.batch();

      for (final category in FailureCategory.values) {
        final communityRef = _firestore.collection(_communitiesCollection).doc();
        final community = Community(
          id: communityRef.id,
          name: '${category.displayName} Support',
          category: category,
          description: category.description,
          memberCount: 0,
          isActive: true,
          moderatorIds: [],
          createdAt: DateTime.now(),
          lastActivityAt: DateTime.now(),
        );

        batch.set(communityRef, community.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to initialize default communities: $e');
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reflection.dart';

class ReflectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'reflections';

  // Add a new reflection for a user
  Future<void> addReflection(String userId, Reflection reflection) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .collection('user_reflections')
          .doc(reflection.id)
          .set(reflection.toFirestore());
    } catch (e) {
      throw Exception('Failed to add reflection: $e');
    }
  }

  // Get all reflections for a user
  Future<List<Reflection>> getReflections(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(_collectionName)
          .doc(userId)
          .collection('user_reflections')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return Reflection.fromFirestore(
          doc.data(),
          doc.id,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get reflections: $e');
    }
  }

  // Get reflections stream for real-time updates
  Stream<List<Reflection>> getReflectionsStream(String userId) {
    return _firestore
        .collection(_collectionName)
        .doc(userId)
        .collection('user_reflections')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Reflection.fromFirestore(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  // Update a reflection
  Future<void> updateReflection(String userId, Reflection reflection) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .collection('user_reflections')
          .doc(reflection.id)
          .update(reflection.toFirestore());
    } catch (e) {
      throw Exception('Failed to update reflection: $e');
    }
  }

  // Delete a reflection
  Future<void> deleteReflection(String userId, String reflectionId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .collection('user_reflections')
          .doc(reflectionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete reflection: $e');
    }
  }

  // Get reflection count for a user
  Future<int> getReflectionCount(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .doc(userId)
          .collection('user_reflections')
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get reflection count: $e');
    }
  }

  // Delete all reflections for a user
  Future<void> deleteAllReflections(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .doc(userId)
          .collection('user_reflections')
          .get();

      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all reflections: $e');
    }
  }
}
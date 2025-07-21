import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet.dart';

class PetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'pets';

  // Create a new pet for a user
  Future<void> createPet(String userId, Pet pet) async {
    try {
      Map<String, dynamic> petData = pet.toFirestore();
      petData['createdAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection(_collectionName).doc(userId).set(petData);
    } catch (e) {
      throw Exception('Failed to create pet: $e');
    }
  }

  // Get pet data for a user
  Future<Pet?> getPet(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collectionName).doc(userId).get();
      
      if (doc.exists && doc.data() != null) {
        return Pet.fromFirestore(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get pet: $e');
    }
  }

  // Update pet data for a user
  Future<void> updatePet(String userId, Pet pet) async {
    try {
      await _firestore.collection(_collectionName).doc(userId).update(pet.toFirestore());
    } catch (e) {
      throw Exception('Failed to update pet: $e');
    }
  }

  // Listen to pet data changes in real-time
  Stream<Pet?> getPetStream(String userId) {
    return _firestore
        .collection(_collectionName)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return Pet.fromFirestore(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Delete pet data for a user
  Future<void> deletePet(String userId) async {
    try {
      await _firestore.collection(_collectionName).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete pet: $e');
    }
  }
}

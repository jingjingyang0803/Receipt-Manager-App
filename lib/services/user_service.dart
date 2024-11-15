import 'package:cloud_firestore/cloud_firestore.dart';

import '../logger.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch user profile data for a specified user by email
  Stream<DocumentSnapshot<Map<String, dynamic>>> fetchUserProfile(
      String email) {
    // Retrieve the user profile data from Firestore
    return _firestore
        .collection('users')
        .doc(email) // Use provided email as document ID
        .snapshots();
  }

  // Add new user profile with only userName, profileImagePath, and currencyCode
  Future<void> addUserProfile({
    required String email,
    required String userName,
    String profileImagePath = '',
    String currencyCode = '',
  }) async {
    // Reference to the user's document in Firestore using their email as document ID
    DocumentReference userDocRef = _firestore.collection('users').doc(email);

    // Create a new user profile document with the specified fields
    await userDocRef.set({
      'userName': userName,
      'profileImagePath': profileImagePath, // Default empty if not provided
      'currencyCode': currencyCode, // Default empty if not provided
    }, SetOptions(merge: true));
  }

  // Update user profile data with userName, profileImagePath, and currencyCode
  Future<void> updateUserProfile({
    required String email,
    required String userName,
    String? profileImagePath,
    String? currencyCode,
  }) async {
    // Reference to the user's document in Firestore using their email as document ID
    DocumentReference userDocRef = _firestore.collection('users').doc(email);

    // Set or update the user's profile data
    await userDocRef.set({
      'userName': userName,
      if (profileImagePath != null) 'profileImagePath': profileImagePath,
      if (currencyCode != null) 'currencyCode': currencyCode,
    }, SetOptions(merge: true));
  }

  // Update profile image only
  Future<void> updateProfileImage(String email, String profileImagePath) async {
    DocumentReference userDocRef = _firestore.collection('users').doc(email);

    await userDocRef.update({
      'profileImagePath': profileImagePath,
    });
  }

  // Delete the user profile data
  Future<void> deleteUserProfile(String email) async {
    DocumentReference userDocRef = _firestore.collection('users').doc(email);

    await userDocRef.delete();
  }

  // Clear all history: Receipts and Categories associated with the user
  Future<void> clearAllHistory(String email) async {
    // Clear receipts
    await _firestore.collection('receipts').doc(email).update({
      'receiptlist': [], // Clear the array
    });

    // Clear categories
    await _firestore.collection('categories').doc(email).update({
      'categorylist': [], // Clear the array
    });
  }

  // Delete the Firebase Firestore profile, receipts, and categories for a specified email
  Future<void> deleteUser(String email) async {
    try {
      // Delete user profile in Firestore
      await _firestore.collection('users').doc(email).delete();

      // Delete receipts
      await _firestore.collection('receipts').doc(email).delete();

      // Delete categories
      await _firestore.collection('categories').doc(email).delete();

      logger.e('User profile and associated data deleted successfully');
    } catch (e) {
      logger.e("Error deleting user: $e");
    }
  }
}

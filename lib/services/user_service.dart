import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../logger.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
    // Reference to the user's document in Firestore
    final userDocRef = _firestore.collection('users').doc(email);

    // Prepare update data
    final Map<String, dynamic> updateData = {
      'userName': userName,
      if (profileImagePath != null && profileImagePath.isNotEmpty)
        'profileImagePath': profileImagePath,
      if (currencyCode != null && currencyCode.isNotEmpty)
        'currencyCode': currencyCode,
    };

    // Update Firestore document with merge option
    await userDocRef.set(updateData, SetOptions(merge: true));
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchUserProfileOnce(
      String email) async {
    // Reference to the user's document in Firestore
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(email);

    // Fetch the document once
    return await userDocRef.get();
  }

  // Update profile image only
  Future<void> updateProfileImage(String email, String localImagePath) async {
    try {
      // Upload the image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref();
      final profileImageRef =
          storageRef.child('users/$email/profile_image.jpg');
      await profileImageRef.putFile(File(localImagePath));

      // Get the download URL of the uploaded image
      final imageUrl = await profileImageRef.getDownloadURL();

      // Update the Firestore document with the new profileImagePath
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(email);
      await userDocRef.update({
        'profileImagePath': imageUrl,
      });
    } catch (e) {
      throw Exception('Failed to update profile image: $e');
    }
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

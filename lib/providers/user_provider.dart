import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/user_service.dart';
import 'auth_provider.dart'; // Ensure this import is correct based on your structure

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  DocumentSnapshot<Map<String, dynamic>>? _userProfile;

  DocumentSnapshot<Map<String, dynamic>>? get userProfile => _userProfile;

  // Fetch user profile data and listen for updates
  void fetchUserProfile(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = authProvider.user?.email;

    if (email != null) {
      _userService.fetchUserProfile(email).listen((snapshot) {
        _userProfile = snapshot;
        notifyListeners(); // Notify listeners to update UI
      });
    }
  }

  // Add a new user profile
  Future<void> addUserProfile(
    BuildContext context, {
    required String userName,
    String profileImagePath = '',
    String currencyCode = '',
  }) async {
    final email = Provider.of<AuthProvider>(context, listen: false).user?.email;
    if (email != null) {
      await _userService.addUserProfile(
        email: email,
        userName: userName,
        profileImagePath: profileImagePath,
        currencyCode: currencyCode,
      );
      notifyListeners();
    }
  }

  // Update user profile data
  Future<void> updateUserProfile(
    BuildContext context, {
    required String userName,
    String? profileImagePath,
    String? currencyCode,
  }) async {
    final email = Provider.of<AuthProvider>(context, listen: false).user?.email;
    if (email != null) {
      await _userService.updateUserProfile(
        email: email,
        userName: userName,
        profileImagePath: profileImagePath,
        currencyCode: currencyCode,
      );
      notifyListeners();
    }
  }

  // Update profile image only
  Future<void> updateProfileImage(
      BuildContext context, String profileImagePath) async {
    final email = Provider.of<AuthProvider>(context, listen: false).user?.email;
    if (email != null) {
      await _userService.updateProfileImage(email, profileImagePath);
      notifyListeners();
    }
  }

  // Clear all user history
  Future<void> clearAllHistory(BuildContext context) async {
    final email = Provider.of<AuthProvider>(context, listen: false).user?.email;
    if (email != null) {
      await _userService.clearAllHistory(email);
      notifyListeners();
    }
  }

  // Delete user profile and associated data
  Future<void> deleteUser(BuildContext context) async {
    final email = Provider.of<AuthProvider>(context, listen: false).user?.email;
    if (email != null) {
      await _userService.deleteUser(email);
      _userProfile = null;
      notifyListeners();
    }
  }
}

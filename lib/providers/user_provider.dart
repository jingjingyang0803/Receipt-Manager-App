import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/user_service.dart';
import 'authentication_provider.dart'; // Ensure this import is correct based on your structure

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  DocumentSnapshot<Map<String, dynamic>>? _userProfile;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileStream;

  DocumentSnapshot<Map<String, dynamic>>? get userProfile => _userProfile;

  // Getter for userName
  String? get userName => _userProfile?.data()?['userName'];
  // Getter for profileImagePath
  String? get profileImagePath => _userProfile?.data()?['profileImagePath'];
  // Getter for currencyCode
  String? get currencyCode => _userProfile?.data()?['currencyCode'];

  // Fetch user profile data and listen for updates
  void fetchUserProfile(BuildContext context) {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    final email = authProvider.user?.email;

    if (email != null) {
      // Cancel any existing stream before starting a new one
      _profileStream?.cancel();

      _profileStream = _userService.fetchUserProfile(email).listen((snapshot) {
        if (authProvider.isAuthenticated) {
          // Ensure user is still logged in
          _userProfile = snapshot;
          notifyListeners();
        }
      });
    }
  }

  // Add a method to cancel the profile stream and clear user data
  void clearUserProfile() {
    _profileStream?.cancel(); // Cancel any active Firestore listeners
    _profileStream = null;
    _userProfile = null;
    notifyListeners();
  }

  // Add a new user profile
  Future<void> addUserProfile(
    BuildContext context, {
    required String userName,
    String profileImagePath = '',
    String currencyCode = '',
  }) async {
    final email =
        Provider.of<AuthenticationProvider>(context, listen: false).user?.email;
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
    String? userName,
    String? profileImagePath,
    String? currencyCode,
  }) async {
    final email =
        Provider.of<AuthenticationProvider>(context, listen: false).user?.email;
    if (email != null) {
      // Provide default values for optional fields if they are null
      await _userService.updateUserProfile(
        email: email,
        userName:
            userName ?? this.userName ?? '', // Default to '' if both are null
        profileImagePath: profileImagePath ?? this.profileImagePath ?? '',
        currencyCode: currencyCode ?? this.currencyCode ?? '',
      );
      notifyListeners();
    }
  }

  // Update profile image only
  Future<void> updateProfileImage(
      BuildContext context, String profileImagePath) async {
    final email =
        Provider.of<AuthenticationProvider>(context, listen: false).user?.email;
    if (email != null) {
      await _userService.updateProfileImage(email, profileImagePath);
      notifyListeners();
    }
  }

  // Clear all user history
  Future<void> clearAllHistory(BuildContext context) async {
    final email =
        Provider.of<AuthenticationProvider>(context, listen: false).user?.email;
    if (email != null) {
      await _userService.clearAllHistory(email);
      notifyListeners();
    }
  }

  // Delete user profile and associated data
  Future<void> deleteUser(BuildContext context) async {
    final email =
        Provider.of<AuthenticationProvider>(context, listen: false).user?.email;
    if (email != null) {
      await _userService.deleteUser(email);
      _userProfile = null;
      notifyListeners();
    }
  }
}

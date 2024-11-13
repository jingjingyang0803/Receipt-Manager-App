// auth_manager.dart (new name for clarity)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthManager extends ChangeNotifier {
  User? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthManager() {
    _user = _auth.currentUser;
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;

  bool get isAuthenticated => _user != null;
}

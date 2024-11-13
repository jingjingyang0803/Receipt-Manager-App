import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  String? _userEmail;

  String? get userEmail => _userEmail;

  // Load userEmail from SharedPreferences
  Future<void> loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('userEmail');
    notifyListeners();
  }

  // Set and save userEmail to SharedPreferences
  Future<void> setUserEmail(String email) async {
    _userEmail = email;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', email);
    notifyListeners();
  }

  // Clear userEmail on logout
  Future<void> clearUserEmail() async {
    _userEmail = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
    notifyListeners();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/receipt_service.dart';
import 'authentication_provider.dart';

class ReceiptProvider extends ChangeNotifier {
  final ReceiptService _receiptService = ReceiptService();
  AuthenticationProvider? _authProvider;

  DocumentSnapshot<Map<String, dynamic>>? _receiptsSnapshot;
  Map<String, double>? _groupedReceiptsByCategory;
  Map<String, double>? _groupedReceiptsByInterval;
  Map<String, DateTime>? _oldestAndNewestDates;
  int? _receiptCount;

  DocumentSnapshot<Map<String, dynamic>>? get receiptsSnapshot =>
      _receiptsSnapshot;
  Map<String, double>? get groupedReceiptsByCategory =>
      _groupedReceiptsByCategory;
  Map<String, double>? get groupedReceiptsByInterval =>
      _groupedReceiptsByInterval;
  Map<String, DateTime>? get oldestAndNewestDates => _oldestAndNewestDates;
  int? get receiptCount => _receiptCount;

  // Inject AuthenticationProvider
  set authProvider(AuthenticationProvider authProvider) {
    _authProvider = authProvider;
    notifyListeners(); // Notify listeners if authProvider changes
  }

  // Helper to get user email from AuthenticationProvider
  String? get _userEmail => _authProvider?.user?.email;

  // Fetch receipts as a stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> fetchReceipts() {
    if (_userEmail != null) {
      return _receiptService.fetchReceipts(_userEmail!);
    } else {
      throw Exception("User email is null");
    }
  }

  // Fetch receipt count
  Future<void> loadReceiptCount() async {
    if (_userEmail != null) {
      _receiptCount = await _receiptService.getReceiptCount(_userEmail!);
      notifyListeners();
    }
  }

  // Add a new receipt
  Future<void> addReceipt({
    required Map<String, dynamic> receiptData,
    required String paymentMethod,
  }) async {
    if (_userEmail != null) {
      await _receiptService.addReceipt(
        email: _userEmail!,
        receiptData: receiptData,
        paymentMethod: paymentMethod,
      );
      await loadReceiptCount();
    }
  }

  // Update an existing receipt
  Future<void> updateReceipt({
    required String receiptId,
    required Map<String, dynamic> updatedData,
    String? paymentMethod,
  }) async {
    if (_userEmail != null) {
      await _receiptService.updateReceipt(
        email: _userEmail!,
        receiptId: receiptId,
        updatedData: updatedData,
        paymentMethod: paymentMethod,
      );
      await loadReceiptCount();
    }
  }

  // Delete a receipt
  Future<void> deleteReceipt(String receiptId) async {
    if (_userEmail != null) {
      await _receiptService.deleteReceipt(_userEmail!, receiptId);
      await loadReceiptCount();
    }
  }

  // Set category ID to null for receipts with a specific category ID
  Future<void> setReceiptsCategoryToNull(String categoryId) async {
    if (_userEmail != null) {
      await _receiptService.setReceiptsCategoryToNull(_userEmail!, categoryId);
      notifyListeners();
    }
  }

  // Group receipts by category within a date range
  Future<void> groupReceiptsByCategory(
    String selectedBaseCurrency,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (_userEmail != null) {
      _groupedReceiptsByCategory =
          await _receiptService.groupReceiptsByCategory(
        _userEmail!,
        selectedBaseCurrency,
        startDate,
        endDate,
      );
      notifyListeners();
    }
  }

  // Group receipts by interval within a date range
  Future<void> groupReceiptsByInterval(
    TimeInterval interval,
    String selectedBaseCurrency,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (_userEmail != null) {
      _groupedReceiptsByInterval =
          await _receiptService.groupReceiptsByInterval(
        _userEmail!,
        interval,
        selectedBaseCurrency,
        startDate,
        endDate,
      );
      notifyListeners();
    }
  }

  // Get oldest and newest dates of receipts
  Future<void> loadOldestAndNewestDates() async {
    if (_userEmail != null) {
      _oldestAndNewestDates =
          await _receiptService.getOldestAndNewestDates(_userEmail!);
      notifyListeners();
    }
  }
}

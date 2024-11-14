import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/receipt_service.dart';
import 'authentication_provider.dart';
import 'category_provider.dart';

class ReceiptProvider extends ChangeNotifier {
  final ReceiptService _receiptService = ReceiptService();
  AuthenticationProvider? _authProvider;
  CategoryProvider? _categoryProvider;

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

  // Inject AuthenticationProvider and CategoryProvider
  set authProvider(AuthenticationProvider authProvider) {
    _authProvider = authProvider;
    notifyListeners();
  }

  set categoryProvider(CategoryProvider categoryProvider) {
    _categoryProvider = categoryProvider;
    notifyListeners();
  }

  // Helper to get user email from AuthenticationProvider
  String? get _userEmail => _authProvider?.user?.email;

  // Fetch receipts as a stream and map category details
  Stream<List<Map<String, dynamic>>> fetchReceipts() async* {
    if (_userEmail != null && _categoryProvider != null) {
      Stream<DocumentSnapshot<Map<String, dynamic>>> receiptsStream =
          _receiptService.fetchReceipts(_userEmail!);

      await for (var snapshot in receiptsStream) {
        List<Map<String, dynamic>> receipts = snapshot.exists
            ? (snapshot.data()?['receipts'] as List<dynamic>).map((receipt) {
                final receiptMap = receipt as Map<String,
                    dynamic>; // Cast each item to Map<String, dynamic>

                // Map each receipt with category details
                final categoryId = receiptMap['categoryId'];
                final category = _categoryProvider?.categories.firstWhere(
                  (cat) => cat['id'] == categoryId,
                  orElse: () => {'name': 'Unknown', 'icon': '❓'},
                );

                return {
                  ...receiptMap, // Use the cast map
                  'categoryName': category?['name'] ?? 'Unknown',
                  'categoryIcon': category?['icon'] ?? '❓',
                };
              }).toList()
            : [];

        yield receipts;
      }
    } else {
      throw Exception("User email or category provider is null");
    }
  }

  // Fetch receipt count
  Future<void> loadReceiptCount() async {
    if (_userEmail != null) {
      _receiptCount = await _receiptService.getReceiptCount(_userEmail!);
      notifyListeners();
    }
  }

  // Add a new receipt with category details
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

  // Group receipts by category within a date range, including category details
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

      // Include category name and icon
      _groupedReceiptsByCategory =
          _groupedReceiptsByCategory?.map((key, value) {
        final category = _categoryProvider?.categories.firstWhere(
          (cat) => cat['id'] == key,
          orElse: () => {'name': 'Unknown', 'icon': '❓'},
        );
        return MapEntry(
          '${category?['name']} ${category?['icon']}',
          value,
        );
      });

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

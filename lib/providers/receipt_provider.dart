import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../logger.dart';
import '../services/receipt_service.dart';
import 'authentication_provider.dart';
import 'category_provider.dart';

class ReceiptProvider extends ChangeNotifier {
  final ReceiptService _receiptService = ReceiptService();
  AuthenticationProvider? _authProvider;
  CategoryProvider? _categoryProvider;

  // State properties
  String _sortOption = "Newest";
  List<String> _selectedPaymentMethods = [
    'Credit Card',
    'Debit Card',
    'Cash',
    'Others'
  ];
  List<String> _selectedCategoryIds = [];
  // Default date range: start date is one year ago, end date is today
  DateTime? _startDate = DateTime(
      DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
  DateTime? _endDate = DateTime.now();
  Map<String, double>? _groupedReceiptsByCategory;
  Map<String, double>? _groupedReceiptsByDate;
  List<Map<String, dynamic>> _allReceipts = [];
  List<Map<String, dynamic>> _filteredReceipts = [];
  int? _receiptCount;
  Map<String, DateTime>? _oldestAndNewestDates;

  String get sortOption => _sortOption;
  List<String> get selectedPaymentMethods => _selectedPaymentMethods;
  List<String> get selectedCategoryIds => _selectedCategoryIds;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  Map<String, double>? get groupedReceiptsByCategory =>
      _groupedReceiptsByCategory;
  Map<String, double>? get groupedReceiptsByDate => _groupedReceiptsByDate;
  List<Map<String, dynamic>> get allReceipts => _allReceipts;
  List<Map<String, dynamic>> get filteredReceipts => _filteredReceipts;

  Map<String, DateTime>? get oldestAndNewestDates => _oldestAndNewestDates;
  int? get receiptCount => _receiptCount;

  // Inject AuthenticationProvider and CategoryProvider
  set authProvider(AuthenticationProvider authProvider) {
    _authProvider = authProvider;
    notifyListeners();
  }

  set categoryProvider(CategoryProvider categoryProvider) {
    _categoryProvider = categoryProvider;
    _selectedCategoryIds = _categoryProvider!.categories
        .map((cat) => cat['id'] as String)
        .toList();
    _selectedCategoryIds.add('null');
    notifyListeners();
  }

  String? get _userEmail => _authProvider?.user?.email;

  // Update filters
  void updateFilters({
    required String sortOption,
    required List<String> paymentMethods,
    required List<String> categoryIds,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    _sortOption = sortOption;
    _selectedPaymentMethods = paymentMethods;
    _selectedCategoryIds = categoryIds;
    _startDate = startDate;
    _endDate = endDate;
    notifyListeners();
  }

  // Fetch and filter receipts
  Stream<List<Map<String, dynamic>>> fetchReceipts() async* {
    try {
      final userDoc =
          FirebaseFirestore.instance.collection('receipts').doc(_userEmail);
      await for (var snapshot in userDoc.snapshots()) {
        if (snapshot.data() == null) {
          yield [];
          continue;
        }

        _allReceipts = (snapshot.data()?['receiptlist'] ?? [])
            .cast<Map<String, dynamic>>();

        // Apply filters
        _filteredReceipts = _applyFilters(_allReceipts);
        yield _filteredReceipts;
      }
    } catch (e) {
      logger.e("Error fetching receipts: $e");
      yield [];
    }
  }

  // Apply filters to receipts
  List<Map<String, dynamic>> _applyFilters(
      List<Map<String, dynamic>> receipts) {
    const primaryMethods = ['Credit Card', 'Debit Card', 'Cash'];

    return receipts.where((receipt) {
      // Handle default values for missing fields
      final categoryId = receipt['categoryId'] ?? 'null';
      final paymentMethod = receipt['paymentMethod'] ?? '';
      final date = (receipt['date'] as Timestamp?)?.toDate() ?? DateTime.now();

      // Check if the category matches
      final matchesCategory = _selectedCategoryIds.contains(categoryId);

      // Check if the payment method matches
      bool matchesPaymentMethod;
      if (_selectedPaymentMethods.isEmpty ||
          _selectedPaymentMethods.contains(paymentMethod)) {
        matchesPaymentMethod = true;
      } else if (_selectedPaymentMethods.contains('Others')) {
        // If "Others" is selected, match any method not in primaryMethods
        matchesPaymentMethod = !primaryMethods.contains(paymentMethod);
      } else {
        matchesPaymentMethod = false;
      }

      // Check if the date falls within the selected range
      final matchesDate = (_startDate == null || date.isAfter(_startDate!)) &&
          (_endDate == null || date.isBefore(_endDate!));

      // Log for debugging
      logger.i("Category ID: $categoryId, Matches Category: $matchesCategory");
      logger.i(
          "Payment Method: $paymentMethod, Matches Payment: $matchesPaymentMethod");
      logger.i("Date: $date, Matches Date Range: $matchesDate");

      return matchesCategory && matchesPaymentMethod && matchesDate;
    }).map((receipt) {
      // Map category details if available
      final category = _categoryProvider?.categories.firstWhere(
        (cat) => cat['id'] == receipt['categoryId'],
        orElse: () => {'name': 'Unknown', 'icon': '❓'},
      );

      return {
        ...receipt,
        'categoryName': category?['name'],
        'categoryIcon': category?['icon'],
      };
    }).toList();
  }

  // Group receipts by category
  void groupByCategory() {
    _groupedReceiptsByCategory = {};
    for (var receipt in _filteredReceipts) {
      final categoryId = receipt['categoryId'] ?? 'null';
      final amount = (receipt['amount'] as num?)?.toDouble() ?? 0.0;
      _groupedReceiptsByCategory![categoryId] =
          (_groupedReceiptsByCategory![categoryId] ?? 0.0) + amount;
    }
    notifyListeners();
  }

  // Group receipts by date
  void groupByDate() {
    _groupedReceiptsByDate = {};
    for (var receipt in _filteredReceipts) {
      final date = (receipt['date'] as Timestamp?)?.toDate() ?? DateTime.now();
      final dateKey = "${date.year}-${date.month}-${date.day}";
      final amount = (receipt['amount'] as num?)?.toDouble() ?? 0.0;
      _groupedReceiptsByDate![dateKey] =
          (_groupedReceiptsByDate![dateKey] ?? 0.0) + amount;
    }
    notifyListeners();
  }

  // Search receipts by query
  void searchReceipts(String query) {
    if (_allReceipts.isEmpty) return;

    if (query.isEmpty) {
      _filteredReceipts = List.from(_allReceipts);
    } else {
      _filteredReceipts = _allReceipts.where((receipt) {
        final merchant = receipt['merchantName']?.toLowerCase() ?? '';
        final itemName = receipt['itemName']?.toLowerCase() ?? '';
        final description = receipt['description']?.toLowerCase() ?? '';
        final amount = receipt['amount']?.toString() ?? '';

        return merchant.contains(query.toLowerCase()) ||
            itemName.contains(query.toLowerCase()) ||
            description.contains(query.toLowerCase()) ||
            amount.contains(query);
      }).toList();
    }
    notifyListeners();
  }

  // Add receipt
  Future<void> addReceipt({required Map<String, dynamic> receiptData}) async {
    if (_userEmail != null) {
      await _receiptService.addReceipt(
          email: _userEmail!, receiptData: receiptData);
      notifyListeners();
    }
  }

  // Update receipt
  Future<void> updateReceipt({
    required String receiptId,
    required Map<String, dynamic> updatedData,
  }) async {
    if (_userEmail != null) {
      await _receiptService.updateReceipt(
        email: _userEmail!,
        receiptId: receiptId,
        updatedData: updatedData,
      );
      notifyListeners();
    }
  }

  // Delete receipt
  Future<void> deleteReceipt(String receiptId) async {
    if (_userEmail != null) {
      await _receiptService.deleteReceipt(_userEmail!, receiptId);
      notifyListeners();
    }
  }

  // Set receipts' category ID to null
  Future<void> setReceiptsCategoryToNull(String categoryId) async {
    if (_userEmail != null) {
      await _receiptService.setReceiptsCategoryToNull(_userEmail!, categoryId);
      notifyListeners();
    }
  }

  // Fetch receipt count
  Future<void> loadReceiptCount() async {
    if (_userEmail != null) {
      _receiptCount = await _receiptService.getReceiptCount(_userEmail!);
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

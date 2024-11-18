import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:receipt_manager/providers/user_provider.dart';
import 'package:receipt_manager/services/currency_service.dart';

import '../logger.dart';
import '../services/receipt_service.dart';
import 'authentication_provider.dart';
import 'category_provider.dart';

enum TimeInterval { day, week, month, year }

class ReceiptProvider extends ChangeNotifier {
  // Services and Providers
  final ReceiptService _receiptService = ReceiptService();
  AuthenticationProvider? _authProvider;
  UserProvider? _userProvider;
  CategoryProvider? _categoryProvider;
  final CurrencyService _currencyService = CurrencyService();

  // Date Range
  DateTime? _startDate = DateTime(
      DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
  DateTime? _endDate = DateTime.now();

  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  // Sorting and Filtering Options
  String _sortOption = "Newest";
  List<String> _selectedPaymentMethods = [
    'Credit Card',
    'Debit Card',
    'Cash',
    'Others'
  ];
  List<String> _selectedCategoryIds = [];

  String get sortOption => _sortOption;
  List<String> get selectedPaymentMethods => _selectedPaymentMethods;
  List<String> get selectedCategoryIds => _selectedCategoryIds;

  // Receipts Data
  List<Map<String, dynamic>> _allReceipts = [];
  List<Map<String, dynamic>> _filteredReceipts = [];
  int? _receiptCount;
  DateTime? _oldestDate;
  DateTime? _newestDate;

  List<Map<String, dynamic>> get allReceipts => _allReceipts;
  List<Map<String, dynamic>> get filteredReceipts => _filteredReceipts;
  int? get receiptCount => _receiptCount;
  DateTime? get oldestDate => _oldestDate;
  DateTime? get newestDate => _newestDate;

  // Grouped Receipts
  Map<String, Map<String, dynamic>>? _groupedReceiptsByCategory;
  late Map<String, Map<String, dynamic>>? _groupedReceiptsByInterval;
  late Map<String, Map<String, dynamic>>? _groupedReceiptsByCategoryOneMonth;

  Map<String, Map<String, dynamic>>? get groupedReceiptsByCategory =>
      _groupedReceiptsByCategory;
  Map<String, Map<String, dynamic>>? get groupedReceiptsByInterval =>
      _groupedReceiptsByInterval;
  Map<String, Map<String, dynamic>>? get groupedReceiptsByCategoryOneMonth =>
      _groupedReceiptsByCategoryOneMonth;

  // Spending and Currency
  double _totalSpending = 0.0;

  double get totalSpending => _totalSpending;

  // Time Interval
  TimeInterval _selectedInterval = TimeInterval.month;

  TimeInterval get selectedInterval => _selectedInterval;

  // User Email
  String? get _userEmail => _authProvider?.user?.email;

  // Inject AuthenticationProvider and CategoryProvider
  set authProvider(AuthenticationProvider authProvider) {
    _authProvider = authProvider;
    notifyListeners();
  }

  set userProvider(UserProvider userProvider) {
    _userProvider = userProvider;
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

// Fetch all receipts
  Future<void> fetchAllReceipts() async {
    print("fetchAllReceipts called");
    _categoryProvider?.loadUserCategories();

    try {
      final userDoc =
          FirebaseFirestore.instance.collection('receipts').doc(_userEmail);

      final snapshot = await userDoc.get();
      print('Fetched Snapshot Data: ${snapshot.data()}');

      if (snapshot.data() == null) {
        print('No receipts found.');
        _allReceipts = [];
        notifyListeners();
        return;
      }

      // Update _allReceipts and enrich with category data
      _allReceipts =
          (snapshot.data()?['receiptlist'] ?? []).cast<Map<String, dynamic>>();

      _allReceipts = _allReceipts.map((receipt) {
        final category = _categoryProvider?.categories.firstWhere(
          (cat) => cat['id'] == receipt['categoryId'],
          orElse: () => {'name': 'Unknown', 'icon': '❓'},
        );

        final currencyCode =
            _userProvider?.userProfile?.data()?['currencyCode'];
        // Get the currency symbol using intl
        final currencySymbol =
            NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;

        return {
          ...receipt,
          'categoryName': category?['name'],
          'categoryIcon': category?['icon'],
          'categoryColor': category?['color'],
          'currencySymbolToDisplay': currencySymbol,
          'amountToDisplay': 5,
          // 'amountToDisplay': receipt['amount'], //TODO: convert using rate
        };
      }).toList();

      print(
          "Receipts fetched and enriched (${_allReceipts.length}): $_allReceipts");

      // Notify listeners
      notifyListeners();
    } catch (e) {
      logger.e("Error fetching receipts: $e");
    }
  }

  void applyFilters() {
    print("applyFilters called");

    const primaryMethods = ['Credit Card', 'Debit Card', 'Cash'];
    logger.i(
        "Applying filters on Receipts (${_allReceipts.length}): $_allReceipts");

    // Apply filtering logic
    _filteredReceipts = _allReceipts.where((receipt) {
      final categoryId = receipt['categoryId'] ?? 'unknown';
      final paymentMethod = receipt['paymentMethod'] ?? 'unknown';
      final date = (receipt['date'] as Timestamp?)?.toDate() ?? DateTime(2000);

      final matchesCategory = _selectedCategoryIds.isEmpty ||
          _selectedCategoryIds.contains(categoryId);

      bool matchesPaymentMethod = _selectedPaymentMethods.isEmpty ||
          _selectedPaymentMethods.contains(paymentMethod) ||
          (_selectedPaymentMethods.contains('Others') &&
              !primaryMethods.contains(paymentMethod));

      final matchesDate = (_startDate == null || !date.isBefore(_startDate!)) &&
          (_endDate == null || !date.isAfter(_endDate!));

      logger.i(
          "Receipt: $receipt, Matches - Category: $matchesCategory, Payment: $matchesPaymentMethod, Date: $matchesDate");

      return matchesCategory && matchesPaymentMethod && matchesDate;
    }).toList();

    // Sort the filtered receipts
    _filteredReceipts.sort((a, b) {
      final dateA = (a['date'] as Timestamp).toDate();
      final dateB = (b['date'] as Timestamp).toDate();
      final amountA = (a['amount'] as num?)?.toDouble() ?? 0.0;
      final amountB = (b['amount'] as num?)?.toDouble() ?? 0.0;

      if (_sortOption == 'Newest') return dateB.compareTo(dateA);
      if (_sortOption == 'Oldest') return dateA.compareTo(dateB);
      if (_sortOption == 'Highest') return amountB.compareTo(amountA);
      if (_sortOption == 'Lowest') return amountA.compareTo(amountB);
      return 0;
    });

    logger.i(
        "Filtered and Sorted Receipts (${_filteredReceipts.length}): $_filteredReceipts");

    // Notify listeners
    notifyListeners();
  }

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

    // Apply filters after updating the filter criteria
    applyFilters();
  }

  // Group receipts by category
  void groupByCategory() {
    _groupedReceiptsByCategory = {};
    for (var receipt in _filteredReceipts) {
      final categoryId = receipt['categoryId'] ?? 'null';

      final amount = (receipt['amountToDisplay'] as num?)?.toDouble() ?? 0.0;
      // If the categoryId already exists, update the amount
      if (_groupedReceiptsByCategory!.containsKey(categoryId)) {
        _groupedReceiptsByCategory![categoryId]!['total'] += amount;
      } else {
        // If the categoryId does not exist, initialize with name, icon, and amount
        _groupedReceiptsByCategory![categoryId] = {
          'total': amount,
          'categoryName': receipt['categoryName'],
          'categoryIcon': receipt['categoryIcon'],
          'categoryColor': receipt['categoryColor'],
          'currencySymbolToDisplay': receipt['currencySymbolToDisplay'],
        };
      }
    }

    notifyListeners();
  }

  void updateInterval(TimeInterval interval) {
    _selectedInterval = interval;
    groupByInterval(interval); // Regroup receipts based on the new interval
    notifyListeners();
  }

  // Group receipts by interval
  void groupByInterval(TimeInterval interval) {
    _groupedReceiptsByInterval = {};
    for (var receipt in _filteredReceipts) {
      final date = (receipt['date'] as Timestamp?)?.toDate() ?? DateTime.now();
      final amount = (receipt['amountToDisplay'] as num?)?.toDouble() ?? 0.0;

      // Generate group key based on interval
      String groupKey;
      switch (interval) {
        case TimeInterval.day:
          groupKey = DateFormat('yyyy-MM-dd').format(date);
          break;
        case TimeInterval.week:
          groupKey = '${date.year}-W${getWeekNumber(date)}';
          break;
        case TimeInterval.month:
          groupKey = DateFormat('yyyy-MM').format(date);
          break;
        case TimeInterval.year:
          groupKey = DateFormat('yyyy').format(date);
          break;
      }

      _groupedReceiptsByInterval![groupKey] = {
        'total':
            ((_groupedReceiptsByInterval![groupKey]?['total'] ?? 0.0) + amount),
        'categoryName': receipt['categoryName'],
        'categoryIcon': receipt['categoryIcon'],
        'categoryColor': receipt['categoryColor'],
        'currencySymbolToDisplay': receipt['currencySymbolToDisplay'],
      };
    }

    notifyListeners();
  }

// Helper function to calculate the week number
  int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil();
  }

  void groupReceiptsByCategoryOneMonth(int month, int year) {
    final groupedReceiptsByCategoryOneMonth = <String, Map<String, dynamic>>{};

    // Filter receipts for the selected month and year
    final filteredReceipts = _allReceipts.where((receipt) {
      final date = (receipt['date'] as Timestamp?)?.toDate();
      return date?.month == month && date?.year == year;
    }).toList();

    // Log the selected month, year, and filtered receipts
    print("Selected Month: $month, Year: $year");
    print("Filtered Receipts for Month and Year: $filteredReceipts");

    // Group receipts by category
    for (var receipt in filteredReceipts) {
      final categoryId = receipt['categoryId'] ?? 'null';
      final amount = (receipt['amountToDisplay'] as num?)?.toDouble() ?? 0.0;

      if (groupedReceiptsByCategoryOneMonth.containsKey(categoryId)) {
        groupedReceiptsByCategoryOneMonth[categoryId]!['total'] += amount;
        // Update other fields if needed (e.g., overwrite or ensure they are set correctly)
        groupedReceiptsByCategoryOneMonth[categoryId]!['categoryName'] =
            receipt['categoryName'];
        groupedReceiptsByCategoryOneMonth[categoryId]!['categoryIcon'] =
            receipt['categoryIcon'];
        groupedReceiptsByCategoryOneMonth[categoryId]!['categoryColor'] =
            receipt['categoryColor'];
        groupedReceiptsByCategoryOneMonth[categoryId]![
            'currencySymbolToDisplay'] = receipt['currencySymbolToDisplay'];
      } else {
        groupedReceiptsByCategoryOneMonth[categoryId] = {
          'categoryId': receipt['categoryId'],
          'total': amount,
          'categoryName': receipt['categoryName'],
          'categoryIcon': receipt['categoryIcon'],
          'categoryColor': receipt['categoryColor'],
          'currencySymbolToDisplay': receipt['currencySymbolToDisplay'],
        };
      }
    }

    // Log grouped data
    print("Grouped Receipts by Category: $groupedReceiptsByCategoryOneMonth");

    _groupedReceiptsByCategoryOneMonth = groupedReceiptsByCategoryOneMonth;
    notifyListeners();
  }

  void calculateTotalSpending(Map<String, Map<String, dynamic>> groupedData) {
    double totalSpending = 0.0;

    groupedData.forEach((_, value) {
      totalSpending += value['total'] ?? 0.0;
    });

    // Update state and notify listeners
    _totalSpending = totalSpending;
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
}

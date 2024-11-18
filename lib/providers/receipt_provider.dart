import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:receipt_manager/providers/user_provider.dart';

import '../logger.dart';
import '../services/receipt_service.dart';
import 'authentication_provider.dart';
import 'category_provider.dart';
import 'currency_provider.dart';

enum TimeInterval { day, week, month, year }

class ReceiptProvider extends ChangeNotifier {
  // Services and Providers
  final ReceiptService _receiptService = ReceiptService();
  AuthenticationProvider? _authProvider;
  UserProvider? _userProvider;
  CategoryProvider? _categoryProvider;
  CurrencyProvider? _currencyProvider;

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

  set currencyProvider(CurrencyProvider currencyProvider) {
    _currencyProvider = currencyProvider;
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

        final userCurrencyCode =
            _userProvider?.userProfile?.data()?['currencyCode'];
        // Get the currency symbol using intl
        final currencySymbol =
            NumberFormat.simpleCurrency(name: userCurrencyCode).currencySymbol;

        final rates = {
          "AED": 3.672993,
          "AFN": 67.750012,
          "ALL": 92.919261,
          "AMD": 386.478229,
          "ANG": 1.794078,
          "AOA": 911.660667,
          "ARS": 998.532296,
          "AUD": 1.536803,
          "AWG": 1.7975,
          "AZN": 1.7,
          "BAM": 1.84675,
          "BBD": 2,
          "BDT": 118.955666,
          "BGN": 1.84601,
          "BHD": 0.376922,
          "BIF": 2922.909691,
          "BMD": 1,
          "BND": 1.338288,
          "BOB": 6.878806,
          "BRL": 5.7479,
          "BSD": 1,
          "BTC": 0.00001095826,
          "BTN": 84.001401,
          "BWP": 13.581168,
          "BYN": 3.25729,
          "BZD": 2.00661,
          "CAD": 1.40189,
          "CDF": 2870,
          "CHF": 0.883407,
          "CLF": 0.035257,
          "CLP": 972.059515,
          "CNH": 7.229197,
          "CNY": 7.2367,
          "COP": 4406.373693,
          "CRC": 506.968701,
          "CUC": 1,
          "CUP": 25.75,
          "CVE": 104.290134,
          "CZK": 23.86715,
          "DJF": 177.316787,
          "DKK": 7.037833,
          "DOP": 60.207315,
          "DZD": 133.398467,
          "EGP": 49.4457,
          "ERN": 15,
          "ETB": 122.736291,
          "EUR": 0.943515,
          "FJD": 2.26815,
          "FKP": 0.788653,
          "GBP": 0.788653,
          "GEL": 2.735,
          "GGP": 0.788653,
          "GHS": 15.910462,
          "GIP": 0.788653,
          "GMD": 71,
          "GNF": 8599.414674,
          "GTQ": 7.690855,
          "GYD": 208.262166,
          "HKD": 7.78375,
          "HNL": 25.129083,
          "HRK": 7.116363,
          "HTG": 130.769368,
          "HUF": 383.6715,
          "IDR": 15845.176485,
          "ILS": 3.73932,
          "IMP": 0.788653,
          "INR": 84.403749,
          "IQD": 1310.5,
          "IRR": 42092.5,
          "ISK": 136.34,
          "JEP": 0.788653,
          "JMD": 157.99216,
          "JOD": 0.7091,
          "JPY": 154.647,
          "KES": 129.162936,
          "KGS": 86.5,
          "KHR": 4033.893966,
          "KMF": 464.75016,
          "KPW": 900,
          "KRW": 1391.912542,
          "KWD": 0.307486,
          "KYD": 0.829525,
          "KZT": 496.694873,
          "LAK": 21950,
          "LBP": 89600,
          "LKR": 290.02681,
          "LRD": 182.672335,
          "LSL": 18.085,
          "LYD": 4.871281,
          "MAD": 10.002,
          "MDL": 18.103695,
          "MGA": 4657.960896,
          "MKD": 58.059012,
          "MMK": 2098,
          "MNT": 3398,
          "MOP": 7.982058,
          "MRU": 39.925,
          "MUR": 47.045,
          "MVR": 15.455,
          "MWK": 1735,
          "MXN": 20.2116,
          "MYR": 4.4705,
          "MZN": 63.924991,
          "NAD": 18.085,
          "NGN": 1662.683481,
          "NIO": 36.688175,
          "NOK": 11.008475,
          "NPR": 134.397176,
          "NZD": 1.697451,
          "OMR": 0.38498,
          "PAB": 1,
          "PEN": 3.795,
          "PGK": 4.00457,
          "PHP": 58.644994,
          "PKR": 277.8,
          "PLN": 4.076623,
          "PYG": 7759.250026,
          "QAR": 3.6405,
          "RON": 4.6956,
          "RSD": 110.381,
          "RUB": 99.750629,
          "RWF": 1370,
          "SAR": 3.753934,
          "SBD": 8.390419,
          "SCR": 14.014926,
          "SDG": 601.5,
          "SEK": 10.91669,
          "SGD": 1.339345,
          "SHP": 0.788653,
          "SLL": 20969.5,
          "SOS": 571,
          "SRD": 35.405,
          "SSP": 130.26,
          "STD": 22281.8,
          "STN": 23.134159,
          "SVC": 8.710719,
          "SYP": 2512.53,
          "SZL": 18.085,
          "THB": 34.636903,
          "TJS": 10.592163,
          "TMT": 3.505,
          "TND": 3.16,
          "TOP": 2.39966,
          "TRY": 34.584861,
          "TTD": 6.758007,
          "TWD": 32.470801,
          "TZS": 2650.381657,
          "UAH": 41.227244,
          "UGX": 3655.17998,
          "USD": 1,
          "UYU": 42.924219,
          "UZS": 12786.647399,
          "VES": 45.733164,
          "VND": 25416.193807,
          "VUV": 118.722,
          "WST": 2.8,
          "XAF": 618.905212,
          "XAG": 0.03208503,
          "XAU": 0.00038287,
          "XCD": 2.70255,
          "XDR": 0.75729,
          "XOF": 618.905212,
          "XPD": 0.0009963,
          "XPF": 112.591278,
          "XPT": 0.00103494,
          "YER": 249.850133,
          "ZAR": 17.94915,
          "ZMW": 27.451369,
          "ZWL": 322
        };

        // Calculate the converted amount
        final baseCurrency = receipt['currencyCode'];
        final amount = receipt['amount'] as double? ?? 0.0;

        double amountToDisplay = amount; // Default is the same amount
        if (rates.containsKey(baseCurrency) &&
            rates.containsKey(userCurrencyCode)) {
          print(rates[baseCurrency]);
          print(rates[userCurrencyCode]);
          final rate = rates[baseCurrency]! / rates[userCurrencyCode]!;
          amountToDisplay = amount / rate;
        } else {
          print("Currency code not found: $baseCurrency or $userCurrencyCode");
        }

        return {
          ...receipt,
          'categoryName': category?['name'],
          'categoryIcon': category?['icon'],
          'categoryColor': category?['color'],
          'currencySymbolToDisplay': currencySymbol,
          'amountToDisplay': amountToDisplay,
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

  // Filter receipts by a specific category
  List<Map<String, dynamic>> filterReceiptsByCategory(String categoryId) {
    // Ensure categoryId is valid
    if (categoryId.isEmpty) {
      print("Invalid categoryId provided.");
      return [];
    }

    // Filter receipts by the given categoryId
    final filteredByCategory = _filteredReceipts.where((receipt) {
      return receipt['categoryId'] == categoryId;
    }).toList();

    print("Filtered Receipts for Category ($categoryId): $filteredByCategory");
    return filteredByCategory;
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

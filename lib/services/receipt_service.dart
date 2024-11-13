import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'currency_service.dart';

final _firestore = FirebaseFirestore.instance;

enum TimeInterval { day, week, month, year }

class ReceiptService {
  // Fetch receipts for a specific user by email
  Stream<DocumentSnapshot<Map<String, dynamic>>> fetchReceipts(String email) {
    return _firestore
        .collection('receipts')
        .doc(email) // Use provided email for user identification
        .snapshots();
  }

  // Get the count of receipts for a specific user
  Future<int> getReceiptCount(String email) async {
    try {
      DocumentReference userDocRef =
          _firestore.collection('receipts').doc(email);

      DocumentSnapshot userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        return 0; // Return 0 if no document is found
      }

      // Get the receipt list from Firestore
      List<dynamic> receiptList = userDoc['receiptlist'] ?? [];
      return receiptList.length;
    } catch (e) {
      throw Exception('Failed to fetch receipt count: $e');
    }
  }

  // Add a new receipt for a specific user
  Future<void> addReceipt({
    required String email,
    required Map<String, dynamic> receiptData,
    required String paymentMethod,
  }) async {
    // Generate a unique ID for each receipt
    String receiptId =
        FirebaseFirestore.instance.collection('receipts').doc().id;

    // Add the receipt ID and payment method to the receipt data
    receiptData['id'] = receiptId;
    receiptData['paymentMethod'] = paymentMethod;

    DocumentReference userDocRef = _firestore.collection('receipts').doc(email);

    await userDocRef.set({
      'receiptlist': FieldValue.arrayUnion([receiptData])
    }, SetOptions(merge: true));
  }

  // Update an existing receipt for a specific user
  Future<void> updateReceipt({
    required String email,
    required String receiptId,
    required Map<String, dynamic> updatedData,
    String? paymentMethod,
  }) async {
    DocumentReference userDocRef = _firestore.collection('receipts').doc(email);

    DocumentSnapshot userDoc = await userDocRef.get();

    if (!userDoc.exists) {
      throw Exception('User document not found');
    }

    // Get the current receipt list
    List<dynamic> receiptList = userDoc['receiptlist'] ?? [];

    // Find the index of the receipt to update by its ID
    int receiptIndex =
        receiptList.indexWhere((receipt) => receipt['id'] == receiptId);

    if (receiptIndex != -1) {
      // Preserve the original ID and add/update the paymentMethod if provided
      updatedData['id'] = receiptId;
      if (paymentMethod != null) {
        updatedData['paymentMethod'] = paymentMethod;
      }

      // Replace the old receipt with the updated data
      receiptList[receiptIndex] = updatedData;

      // Update the receipt list in the document
      await userDocRef.update({'receiptlist': receiptList});
    } else {
      throw Exception('Receipt not found');
    }
  }

  // Delete a receipt for a specific user by its ID
  Future<void> deleteReceipt(String email, String receiptId) async {
    DocumentReference userDocRef = _firestore.collection('receipts').doc(email);

    // First, get the current receipt list
    DocumentSnapshot doc = await userDocRef.get();
    if (doc.exists) {
      List<dynamic> receiptList = doc['receiptlist'] ?? [];

      // Find the receipt and remove it
      receiptList.removeWhere((receipt) => receipt['id'] == receiptId);

      // Update the document with the new list
      await userDocRef.update({'receiptlist': receiptList});
    }
  }

  // Set categoryId to null for all receipts that match the given categoryId
  Future<void> setReceiptsCategoryToNull(
      String email, String categoryId) async {
    DocumentReference userDocRef = _firestore.collection('receipts').doc(email);

    // Fetch the user's receipts
    DocumentSnapshot doc = await userDocRef.get();
    if (doc.exists) {
      List<dynamic> receiptList = doc['receiptlist'] ?? [];

      // Iterate over the receipts and set categoryId to null for those with matching categoryId
      List<dynamic> updatedReceiptList = receiptList.map((receipt) {
        if (receipt['categoryId'] == categoryId) {
          receipt['categoryId'] = null; // Set the categoryId to null
        }
        return receipt;
      }).toList();

      // Update the Firestore document with the modified receipts
      await userDocRef.update({'receiptlist': updatedReceiptList});
    } else {
      throw Exception('No receipts found for the current user');
    }
  }

// Group receipts by category with date filtering
  Future<Map<String, double>> groupReceiptsByCategory(
    String email,
    String selectedBaseCurrency,
    DateTime startDate,
    DateTime endDate,
  ) async {
    DocumentReference userDocRef = _firestore.collection('receipts').doc(email);

    DocumentSnapshot userDoc = await userDocRef.get();

    if (!userDoc.exists) {
      throw Exception('User document not found');
    }

    List<dynamic> receiptList = userDoc['receiptlist'] ?? [];

    Map<String, double> groupedExpenses = {};
    CurrencyService currencyService = CurrencyService();

    for (var receipt in receiptList) {
      Map<String, dynamic> receiptData = receipt as Map<String, dynamic>;
      String category = receiptData['categoryId'] ?? 'Uncategorized';
      String currency = receiptData['currency'];
      double amount = (receiptData['amount'] as num).toDouble();
      DateTime receiptDate = (receiptData['date'] as Timestamp).toDate();

      if (receiptDate.isBefore(startDate) || receiptDate.isAfter(endDate)) {
        continue; // Skip receipts outside the date range
      }

      double convertedAmount = await currencyService.convertToBaseCurrency(
          amount, currency, selectedBaseCurrency);

      groupedExpenses[category] =
          (groupedExpenses[category] ?? 0) + convertedAmount;
    }

    return groupedExpenses;
  }

  // Helper method to calculate the week number
  int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    int daysSinceFirstDay = date.difference(firstDayOfYear).inDays + 1;
    return (daysSinceFirstDay / 7).ceil();
  }

  // Group receipts by day, week, month, or year
  Future<Map<String, double>> groupReceiptsByInterval(
    String email,
    TimeInterval interval,
    String selectedBaseCurrency,
    DateTime startDate,
    DateTime endDate,
  ) async {
    DocumentReference userDocRef = _firestore.collection('receipts').doc(email);

    DocumentSnapshot userDoc = await userDocRef.get();

    if (!userDoc.exists) {
      throw Exception('User document not found');
    }

    List<dynamic> receiptList = userDoc['receiptlist'] ?? [];
    Map<String, double> groupedExpenses = {};
    CurrencyService currencyService = CurrencyService();

    for (var receipt in receiptList) {
      Map<String, dynamic> receiptData = receipt as Map<String, dynamic>;
      String currency = receiptData['currency'];
      double amount = (receiptData['amount'] as num).toDouble();
      DateTime receiptDate = (receiptData['date'] as Timestamp).toDate();

      if (receiptDate.isBefore(startDate) || receiptDate.isAfter(endDate)) {
        continue; // Skip receipts outside the date range
      }

      String groupKey;
      switch (interval) {
        case TimeInterval.day:
          groupKey = DateFormat('yyyy-MM-dd').format(receiptDate);
          break;
        case TimeInterval.week:
          int weekNumber = getWeekNumber(receiptDate);
          groupKey = '${receiptDate.year}-W$weekNumber';
          break;
        case TimeInterval.month:
          groupKey = DateFormat('yyyy-MM').format(receiptDate);
          break;
        case TimeInterval.year:
          groupKey = DateFormat('yyyy').format(receiptDate);
          break;
      }

      double convertedAmount = await currencyService.convertToBaseCurrency(
          amount, currency, selectedBaseCurrency);

      groupedExpenses[groupKey] =
          (groupedExpenses[groupKey] ?? 0) + convertedAmount;
    }

    return groupedExpenses;
  }

  // Method to get the oldest and newest receipt dates
  Future<Map<String, DateTime>> getOldestAndNewestDates(String email) async {
    DocumentReference userDocRef = _firestore.collection('receipts').doc(email);

    DocumentSnapshot userDoc = await userDocRef.get();

    if (!userDoc.exists) {
      throw Exception('User document not found');
    }

    List<dynamic> receiptList = userDoc['receiptlist'] ?? [];

    if (receiptList.isEmpty) {
      throw Exception('No receipts found');
    }

    DateTime? oldestDate;
    DateTime? newestDate;

    for (var receipt in receiptList) {
      DateTime receiptDate = (receipt['date'] as Timestamp).toDate();

      if (oldestDate == null || receiptDate.isBefore(oldestDate)) {
        oldestDate = receiptDate;
      }
      if (newestDate == null || receiptDate.isAfter(newestDate)) {
        newestDate = receiptDate;
      }
    }

    return {
      'oldest': oldestDate!,
      'newest': newestDate!,
    };
  }
}

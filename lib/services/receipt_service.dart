import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final _firestore = FirebaseFirestore.instance;

enum TimeInterval { day, week, month, year }

class ReceiptService {
  Stream<DocumentSnapshot<Map<String, dynamic>>> fetchReceipts(String email) {
    return _firestore.collection('receipts').doc(email).snapshots();
  }

  Future<int> getReceiptCount(String email) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('receipts').doc(email).get();
      return userDoc.exists ? (userDoc['receiptCount'] ?? 0) : 0;
    } catch (e) {
      throw Exception('Failed to fetch receipt count: $e');
    }
  }

  Future<void> addReceipt({
    required String email,
    required Map<String, dynamic> receiptData,
    required String paymentMethod,
  }) async {
    String receiptId = _firestore.collection('receipts').doc().id;
    receiptData['id'] = receiptId;
    receiptData['paymentMethod'] = paymentMethod;

    DocumentReference userDocRef = _firestore.collection('receipts').doc(email);
    await userDocRef.set({
      'receiptlist': FieldValue.arrayUnion([receiptData]),
      'receiptCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  Future<void> updateReceipt({
    required String email,
    required String receiptId,
    required Map<String, dynamic> updatedData,
    String? paymentMethod,
  }) async {
    DocumentReference userDocRef = _firestore.collection('receipts').doc(email);
    DocumentSnapshot userDoc = await userDocRef.get();

    if (!userDoc.exists) throw Exception('User document not found');

    List<dynamic> receiptList = userDoc['receiptlist'] ?? [];
    int receiptIndex =
        receiptList.indexWhere((receipt) => receipt['id'] == receiptId);

    if (receiptIndex != -1) {
      updatedData['id'] = receiptId;
      if (paymentMethod != null) updatedData['paymentMethod'] = paymentMethod;

      receiptList[receiptIndex] = updatedData;
      await userDocRef.update({'receiptlist': receiptList});
    } else {
      throw Exception('Receipt not found');
    }
  }

  Future<void> deleteReceipt(String email, String receiptId) async {
    DocumentReference userDocRef = _firestore.collection('receipts').doc(email);
    DocumentSnapshot doc = await userDocRef.get();

    if (doc.exists) {
      List<dynamic> receiptList = doc['receiptlist'] ?? [];
      receiptList.removeWhere((receipt) => receipt['id'] == receiptId);
      await userDocRef.update({
        'receiptlist': receiptList,
        'receiptCount': FieldValue.increment(-1)
      });
    }
  }

  Future<void> setReceiptsCategoryToNull(
      String email, String categoryId) async {
    DocumentReference userDocRef = _firestore.collection('receipts').doc(email);
    DocumentSnapshot doc = await userDocRef.get();

    if (doc.exists) {
      List<dynamic> receiptList = doc['receiptlist'] ?? [];
      List<dynamic> updatedReceipts = [];

      for (var receipt in receiptList) {
        if (receipt['categoryId'] == categoryId) receipt['categoryId'] = null;
        updatedReceipts.add(receipt);
      }

      if (updatedReceipts.isNotEmpty) {
        await userDocRef.update({'receiptlist': updatedReceipts});
      }
    }
  }

  // Group receipts by category within a date range
  Future<Map<String, double>> groupReceiptsByCategory(
    String email,
    DateTime startDate,
    DateTime endDate,
  ) async {
    DocumentReference userDocRef = _firestore.collection('receipts').doc(email);
    DocumentSnapshot userDoc = await userDocRef.get();

    if (!userDoc.exists) throw Exception('User document not found');

    List<dynamic> receiptList = userDoc['receiptlist'] ?? [];
    Map<String, double> groupedExpenses = {};

    for (var receipt in receiptList) {
      Map<String, dynamic> receiptData = receipt as Map<String, dynamic>;
      String category = receiptData['categoryId'] ?? 'Uncategorized';
      double amount = (receiptData['amount'] as num).toDouble();
      DateTime receiptDate = (receiptData['date'] as Timestamp).toDate();

      // Filter receipts by the specified date range
      if (receiptDate.isBefore(startDate) || receiptDate.isAfter(endDate)) {
        continue;
      }

      // Aggregate amount by category
      groupedExpenses[category] = (groupedExpenses[category] ?? 0) + amount;
    }

    return groupedExpenses;
  }

  int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    int daysSinceFirstDay = date.difference(firstDayOfYear).inDays + 1;
    return (daysSinceFirstDay / 7).ceil();
  }

  // Group receipts by specified time interval within a date range
  Future<Map<String, double>> groupReceiptsByInterval(
    String email,
    TimeInterval interval,
    DateTime startDate,
    DateTime endDate,
  ) async {
    DocumentReference userDocRef = _firestore.collection('receipts').doc(email);
    DocumentSnapshot userDoc = await userDocRef.get();

    if (!userDoc.exists) throw Exception('User document not found');

    List<dynamic> receiptList = userDoc['receiptlist'] ?? [];
    Map<String, double> groupedExpenses = {};

    for (var receipt in receiptList) {
      Map<String, dynamic> receiptData = receipt as Map<String, dynamic>;
      double amount = (receiptData['amount'] as num).toDouble();
      DateTime receiptDate = (receiptData['date'] as Timestamp).toDate();

      // Filter receipts by the specified date range
      if (receiptDate.isBefore(startDate) || receiptDate.isAfter(endDate)) {
        continue;
      }

      // Generate a grouping key based on the selected interval
      String groupKey;
      switch (interval) {
        case TimeInterval.day:
          groupKey = DateFormat('yyyy-MM-dd').format(receiptDate);
          break;
        case TimeInterval.week:
          groupKey = '${receiptDate.year}-W${getWeekNumber(receiptDate)}';
          break;
        case TimeInterval.month:
          groupKey = DateFormat('yyyy-MM').format(receiptDate);
          break;
        case TimeInterval.year:
          groupKey = DateFormat('yyyy').format(receiptDate);
          break;
      }

      // Aggregate amount by interval
      groupedExpenses[groupKey] = (groupedExpenses[groupKey] ?? 0) + amount;
    }

    return groupedExpenses;
  }

  Future<Map<String, DateTime>> getOldestAndNewestDates(String email) async {
    DocumentReference userDocRef = _firestore.collection('receipts').doc(email);
    DocumentSnapshot userDoc = await userDocRef.get();

    if (!userDoc.exists) throw Exception('User document not found');

    List<dynamic> receiptList = userDoc['receiptlist'] ?? [];
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

    return {'oldest': oldestDate!, 'newest': newestDate!};
  }
}

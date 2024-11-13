import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/receipt_service.dart';

class ReceiptProvider extends ChangeNotifier {
  final ReceiptService _receiptService = ReceiptService();
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

  // Fetch receipts as a stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> fetchReceipts(String email) {
    return _receiptService.fetchReceipts(email);
  }

  // Fetch receipt count
  Future<void> loadReceiptCount(String email) async {
    _receiptCount = await _receiptService.getReceiptCount(email);
    notifyListeners();
  }

  // Add a new receipt
  Future<void> addReceipt({
    required String email,
    required Map<String, dynamic> receiptData,
    required String paymentMethod,
  }) async {
    await _receiptService.addReceipt(
      email: email,
      receiptData: receiptData,
      paymentMethod: paymentMethod,
    );
    await loadReceiptCount(email);
  }

  // Update an existing receipt
  Future<void> updateReceipt({
    required String email,
    required String receiptId,
    required Map<String, dynamic> updatedData,
    String? paymentMethod,
  }) async {
    await _receiptService.updateReceipt(
      email: email,
      receiptId: receiptId,
      updatedData: updatedData,
      paymentMethod: paymentMethod,
    );
    await loadReceiptCount(email);
  }

  // Delete a receipt
  Future<void> deleteReceipt(String email, String receiptId) async {
    await _receiptService.deleteReceipt(email, receiptId);
    await loadReceiptCount(email);
  }

  // Set category ID to null for receipts with a specific category ID
  Future<void> setReceiptsCategoryToNull(
      String email, String categoryId) async {
    await _receiptService.setReceiptsCategoryToNull(email, categoryId);
    notifyListeners();
  }

  // Group receipts by category within a date range
  Future<void> groupReceiptsByCategory(
    String email,
    String selectedBaseCurrency,
    DateTime startDate,
    DateTime endDate,
  ) async {
    _groupedReceiptsByCategory = await _receiptService.groupReceiptsByCategory(
      email,
      selectedBaseCurrency,
      startDate,
      endDate,
    );
    notifyListeners();
  }

  // Group receipts by interval within a date range
  Future<void> groupReceiptsByInterval(
    String email,
    TimeInterval interval,
    String selectedBaseCurrency,
    DateTime startDate,
    DateTime endDate,
  ) async {
    _groupedReceiptsByInterval = await _receiptService.groupReceiptsByInterval(
      email,
      interval,
      selectedBaseCurrency,
      startDate,
      endDate,
    );
    notifyListeners();
  }

  // Get oldest and newest dates of receipts
  Future<void> loadOldestAndNewestDates(String email) async {
    _oldestAndNewestDates =
        await _receiptService.getOldestAndNewestDates(email);
    notifyListeners();
  }
}

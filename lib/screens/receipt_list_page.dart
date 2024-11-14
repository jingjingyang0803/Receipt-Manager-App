import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:receipt_manager/constants/app_colors.dart';
import 'package:receipt_manager/providers/receipt_provider.dart';
import 'package:receipt_manager/screens/financial_report_page.dart';

import '../components/expense_item_card.dart';

class ReceiptListPage extends StatelessWidget {
  static const String id = 'expense_list_page';

  const ReceiptListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Expense', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFinancialReportBar(context),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<ReceiptProvider>(
                builder: (context, receiptProvider, _) {
                  return StreamBuilder<List<Map<String, dynamic>>>(
                    stream: receiptProvider.fetchReceipts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No expenses found.'),
                        );
                      }

                      List<Map<String, dynamic>> receipts = snapshot.data!;
                      List<Map<String, dynamic>> todayReceipts = receipts
                          .where((receipt) =>
                              _isToday((receipt['date'] as Timestamp).toDate()))
                          .toList();
                      List<Map<String, dynamic>> yesterdayReceipts = receipts
                          .where((receipt) => _isYesterday(
                              (receipt['date'] as Timestamp).toDate()))
                          .toList();
                      List<Map<String, dynamic>> otherReceipts = receipts
                          .where((receipt) =>
                              !_isToday(
                                  (receipt['date'] as Timestamp).toDate()) &&
                              !_isYesterday(
                                  (receipt['date'] as Timestamp).toDate()))
                          .toList();

                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (todayReceipts.isNotEmpty) ...[
                              const Text(
                                'Today',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              for (var receipt in todayReceipts)
                                ExpenseItem(
                                  categoryIcon: receipt['categoryIcon'],
                                  categoryName: receipt['categoryName'],
                                  merchantName: receipt['merchantName'],
                                  amount:
                                      '${receipt['amount'] >= 0 ? '+' : '-'} \$${receipt['amount'].abs().toStringAsFixed(2)}',
                                  paymentMethod: receipt['paymentMethod'],
                                ),
                              const SizedBox(height: 16),
                            ],
                            if (yesterdayReceipts.isNotEmpty) ...[
                              const Text(
                                'Yesterday',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              for (var receipt in yesterdayReceipts)
                                ExpenseItem(
                                  categoryIcon: receipt['categoryIcon'],
                                  categoryName: receipt['categoryName'],
                                  merchantName: receipt['merchantName'],
                                  amount:
                                      '${receipt['amount'] >= 0 ? '+' : '-'} \$${receipt['amount'].abs().toStringAsFixed(2)}',
                                  paymentMethod: receipt['paymentMethod'],
                                ),
                              const SizedBox(height: 16),
                            ],
                            if (otherReceipts.isNotEmpty) ...[
                              for (var receipt
                                  in _groupReceiptsByDate(otherReceipts)
                                      .entries) ...[
                                Text(
                                  receipt.key, // Date as section header
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                for (var entry in receipt.value)
                                  ExpenseItem(
                                    categoryIcon: entry['categoryIcon'],
                                    categoryName: entry['categoryName'],
                                    merchantName: entry['merchantName'],
                                    amount:
                                        '${entry['amount'] >= 0 ? '+' : '-'} \$${entry['amount'].abs().toStringAsFixed(2)}',
                                    paymentMethod: entry['paymentMethod'],
                                  ),
                                const SizedBox(height: 16),
                              ]
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final receiptProvider =
              Provider.of<ReceiptProvider>(context, listen: false);

          // Dummy data for new receipt
          final dummyReceipt = {
            'categoryId': '1f8G7NcXiXAfm4sJ18P5',
            'merchantName': 'Dummy Store',
            'amount': -50.0,
            'date': Timestamp.now(),
            'paymentMethod': 'Credit Card',
          };

          receiptProvider.addReceipt(receiptData: dummyReceipt);
        },
        backgroundColor: purple100,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFinancialReportBar(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, FinancialReportPage.id);
        },
        style: TextButton.styleFrom(
          backgroundColor: purple20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.all(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "See your financial report",
              style: TextStyle(
                color: purple100,
                fontSize: 16,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: purple100,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    DateTime now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  // Helper function to group receipts by date
  Map<String, List<Map<String, dynamic>>> _groupReceiptsByDate(
      List<Map<String, dynamic>> receipts) {
    Map<String, List<Map<String, dynamic>>> groupedReceipts = {};

    for (var receipt in receipts) {
      DateTime date = (receipt['date'] as Timestamp).toDate();
      String formattedDate = DateFormat('MMMM dd, yyyy').format(date);

      if (groupedReceipts.containsKey(formattedDate)) {
        groupedReceipts[formattedDate]!.add(receipt);
      } else {
        groupedReceipts[formattedDate] = [receipt];
      }
    }

    return groupedReceipts;
  }
}

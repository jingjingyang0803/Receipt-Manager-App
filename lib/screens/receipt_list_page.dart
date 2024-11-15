import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:receipt_manager/constants/app_colors.dart';
import 'package:receipt_manager/providers/receipt_provider.dart';
import 'package:receipt_manager/screens/financial_report_page.dart';

import '../components/expense_item_card.dart';
import '../components/filter_popup.dart';
import 'add_update_receipt_page.dart';

//implement a search bar that updates dynamically
class ReceiptListPage extends StatefulWidget {
  static const String id = 'receipt_list_page';

  ReceiptListPage({Key? key}) : super(key: key);

  @override
  _ReceiptListPageState createState() => _ReceiptListPageState();
}

class _ReceiptListPageState extends State<ReceiptListPage> {
  // Added State Variables for Search
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

// check this later
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }


  // Method to open the filter popup
  void _openFilterPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterPopup(
        onApply: (paymentMethods, sortOrder, categoryIds) {
          Provider.of<ReceiptProvider>(context, listen: false).updateFilters(
            paymentMethods: paymentMethods,
            sortOrder: sortOrder,
            categoryIds: categoryIds,
          );
        },
      ),
    );
  }

  // Search method: filters receipts by matching the query
  List<Map<String, dynamic>> _filterReceipts(
      List<Map<String, dynamic>> receipts, String query) {
    if (query.isEmpty) return receipts;
    return receipts
        .where((receipt) =>
    (receipt['merchantName']?.toLowerCase().contains(query) ?? false) ||
        (receipt['itemName']?.toLowerCase().contains(query) ?? false) ||
        (receipt['description']?.toLowerCase().contains(query) ?? false) ||
        (receipt['amount']?.toString().contains(query) ?? false))
        .toList();
  }

  // Builds each receipt section
  Widget _buildReceiptSection(
      BuildContext context, {
        required String sectionTitle,
        required List<Map<String, dynamic>> receipts,
      }) {
    return receipts.isNotEmpty
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style:
          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...receipts.map((receipt) => ExpenseItem(
          categoryIcon: receipt['categoryIcon'] ?? Icons.category,
          categoryName: receipt['categoryName'] ?? 'Unknown Category',
          merchantName: receipt['merchantName'] ?? 'Unknown Merchant',
          amount:
          '${(receipt['amount'] ?? 0) >= 0 ? '+' : '-'} \$${(receipt['amount'] ?? 0).abs().toStringAsFixed(2)}',
          paymentMethod:
          receipt['paymentMethod'] ?? 'Unknown Payment Method',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddOrUpdateReceiptPage(
                  existingReceipt: receipt,
                  receiptId: receipt['id'],
                ),
              ),
            ).then((_) {
              Provider.of<ReceiptProvider>(context, listen: false)
                  .fetchReceipts();
            });
          },
        )),
        const SizedBox(height: 16),
      ],
    )
        : const SizedBox.shrink();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _isSearching //When _isSearching is true, a TextField (search bar) appears in place
            ? TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.black),
          onChanged: (query) { //listens to changes in the text input
            setState(() {}); // Trigger rebuild on search query change
          },
        )
            : const Text('Expense', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              //When _isSearching is false, a search icon (Icons.search) is shown
              _isSearching ? Icons.close : Icons.search,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                } else {
                  _isSearching = true;
                  _searchFocusNode.requestFocus();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: Colors.black),
            onPressed: () => _openFilterPopup(context),
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
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No entries found.'),
                        );
                      }

                      // Filter receipts based on the search query
                      String query = _searchController.text.toLowerCase();
                      List<Map<String, dynamic>> receipts =
                      _filterReceipts(snapshot.data!, query); //f query is empty, it returns the full list

                      List<Map<String, dynamic>> todayReceipts = receipts
                          .where((receipt) => _isToday(
                          (receipt['date'] as Timestamp?)?.toDate() ??
                              DateTime.now()))
                          .toList();
                      List<Map<String, dynamic>> yesterdayReceipts = receipts
                          .where((receipt) => _isYesterday(
                          (receipt['date'] as Timestamp?)?.toDate() ??
                              DateTime.now()))
                          .toList();
                      List<Map<String, dynamic>> otherReceipts = receipts
                          .where((receipt) =>
                      !_isToday(
                          (receipt['date'] as Timestamp?)?.toDate() ??
                              DateTime.now()) &&
                          !_isYesterday(
                              (receipt['date'] as Timestamp?)?.toDate() ??
                                  DateTime.now()))
                          .toList();

                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildReceiptSection(context,
                                sectionTitle: 'Today', receipts: todayReceipts),
                            _buildReceiptSection(context,
                                sectionTitle: 'Yesterday',
                                receipts: yesterdayReceipts),
                            for (var entry
                            in _groupReceiptsByDate(otherReceipts).entries)
                              _buildReceiptSection(context,
                                  sectionTitle: entry.key,
                                  receipts: entry.value),
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
          Navigator.pushNamed(context, AddOrUpdateReceiptPage.id);
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
      DateTime date =
          (receipt['date'] as Timestamp?)?.toDate() ?? DateTime.now();
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

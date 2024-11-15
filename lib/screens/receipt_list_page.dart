import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:receipt_manager/constants/app_colors.dart';
import 'package:receipt_manager/providers/receipt_provider.dart';
import 'package:receipt_manager/screens/financial_report_page.dart';

import '../components/custom_app_bar.dart';
import '../components/expense_item_card.dart';
import 'add_update_receipt_page.dart';

//implement a search bar that updates dynamically
class ReceiptListPage extends StatefulWidget {
  static const String id = 'receipt_list_page';

  const ReceiptListPage({super.key});

  @override
  ReceiptListPageState createState() => ReceiptListPageState();
}

class ReceiptListPageState extends State<ReceiptListPage> {
  // Added State Variables for Search
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _suggestions = []; // To hold search suggestions

  @override
  void initState() {
    super.initState();
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
    required List<Map<String, dynamic>> receipts,
  }) {
    return receipts.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Receipts',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...receipts.map((receipt) => ExpenseItem(
                    categoryIcon: receipt['categoryIcon'] ?? Icons.category,
                    categoryName: receipt['categoryName'] ?? 'Unknown Category',
                    merchantName: receipt['merchant'] ?? 'Unknown Merchant',
                    receiptDate: receipt['date'] != null
                        ? DateFormat('MMM d, yyyy')
                            .format((receipt['date'] as Timestamp).toDate())
                        : 'Unknown',
                    amount: receipt['amount'].toStringAsFixed(2),
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

  // check this later
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Method to filter receipts and provide suggestions
  void _performSearch(String query) {
    final receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);

    setState(() {
      receiptProvider
          .searchReceipts(query); // Delegate the search to the provider
      _suggestions = receiptProvider.filteredReceipts; // Get filtered results
    });
  }

  Widget buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 80,
            color: purple80,
          ),
          const SizedBox(height: 20),
          const Text(
            'No results found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Try adjusting your search to find what you are looking for.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: light90,
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.black),
                  onChanged: (query) {
                    _performSearch(query); // Call search on each text change
                  },
                ),
              ],
            ),
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
                        return buildNoResultsFound();
                      }

                      String query = _searchController.text.toLowerCase();
                      List<Map<String, dynamic>> receipts =
                          _filterReceipts(snapshot.data!, query);

                      debugPrint(
                          "Building receipt section with ${receipts.length} receipts.");

                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildReceiptSection(context, receipts: receipts),
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

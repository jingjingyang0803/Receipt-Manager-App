import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:receipt_manager/constants/app_colors.dart';
import 'package:receipt_manager/providers/receipt_provider.dart';

import '../components/custom_app_bar.dart';
import '../components/expense_item_card.dart';
import 'add_update_receipt_page.dart';
import 'extract_page.dart';

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
  // Inside ReceiptListPageState
  List<Map<String, dynamic>> _searchedReceipts =
      []; // Local list for search results

  List<Map<String, dynamic>> _suggestions = []; // To hold search suggestions

  String currencySymbol = '€';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final receiptProvider =
          Provider.of<ReceiptProvider>(context, listen: false);
      receiptProvider.fetchAllReceipts();
      receiptProvider.applyFilters();
      print("Calling fetchReceipts");

      setState(() {
        currencySymbol = receiptProvider.currencySymbol ?? '€';
        _searchedReceipts =
            receiptProvider.filteredReceipts; // Initialize search results
      });
    });
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
                    merchantName: receipt['merchant'] ?? 'Unknown Merchant',
                    receiptDate: receipt['date'] != null
                        ? DateFormat('MMM d, yyyy')
                            .format((receipt['date'] as Timestamp).toDate())
                        : 'Unknown',
                    currencySymbol: currencySymbol,
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
                            .fetchAllReceipts();
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
  // Inside ReceiptListPageState
  void _performSearch(String query) {
    final lowerCaseQuery = query.toLowerCase();

    setState(() {
      final receiptProvider =
          Provider.of<ReceiptProvider>(context, listen: false);
      final lowerCaseQuery = query
          .toLowerCase(); // Replace `searchQuery` with your actual query variable.

      _searchedReceipts = receiptProvider.filteredReceipts.where((receipt) {
        print("Checking receipt: $receipt");

        final matches = receipt.entries.any((entry) {
          final key = entry.key;
          final value = entry.value;

          // Handle specific keys together
          const relevantKeys = {
            'amount',
            'merchant',
            'itemName',
            'paymentMethod',
            'categoryName',
            'categoryIcon',
            'description'
          };

          if (relevantKeys.contains(key)) {
            var stringValue = value?.toString().toLowerCase() ?? '';
            if (key == 'amount') {
              // Format numeric value to two decimal places
              stringValue = value.toStringAsFixed(2);
            }
            print(
                "Key: $key, Value: $stringValue, Matches: ${stringValue.contains(lowerCaseQuery)}");
            return stringValue.contains(lowerCaseQuery);
          }

          // Special case for date
          if (key == 'date' && value is Timestamp) {
            final date = value.toDate();
            final formattedDate =
                "${date.day} ${DateFormat.MMMM().format(date)} ${date.year}";
            final formattedMonthNumber =
                "${date.month}"; // Get numeric month representation

            print(
                "Formatted Date: $formattedDate (${formattedMonthNumber}), Query: $lowerCaseQuery");
            return formattedDate.toLowerCase().contains(lowerCaseQuery) ||
                formattedMonthNumber
                    .contains(lowerCaseQuery); // Match both formats
          }

          // Ignore other fields:
          // - id: Unique identifier, not relevant for searching.
          // - imageUrl: Typically contains a URL, not text to match user queries.
          // - categoryId: Internal identifier, not meaningful to users.
          // - categoryColor: A Color object, not searchable by text.
          return false;
        });

        print("Receipt matches: $matches");
        return matches;
      }).toList();

      print("Search results: $_searchedReceipts");
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
              'Try adjusting your search and filters to find what you are looking for.',
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

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            Colors.white, // Same background color as the financial report bar
        borderRadius: BorderRadius.circular(8.0), // Same rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14), // Adjust padding
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: purple80), // Optional: hint color
              ),
              style: const TextStyle(color: purple80),
              onChanged: (query) {
                _performSearch(query); // Call search on each text change
              },
            ),
          ),
          Icon(
            Icons.search,
            color: purple80, // Match the icon color with the report bar text
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
            _buildSearchBar(context), // The search bar at the top
            const SizedBox(height: 16), // Add space after the search bar
            Expanded(
              child: Consumer<ReceiptProvider>(
                builder: (context, receiptProvider, _) {
                  if (_searchedReceipts.isEmpty) {
                    return buildNoResultsFound(); // Show "No results" message if empty
                  }

                  // Display the filtered receipts
                  return ListView(
                    children: [
                      _buildReceiptSection(
                        context,
                        sectionTitle: 'Receipts',
                        receipts:
                            _searchedReceipts, // Use the local searched list
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add, // Main FAB icon
        activeIcon: Icons.close, // Icon when the menu is expanded
        backgroundColor: purple100,
        foregroundColor: Colors.white,
        activeBackgroundColor: Colors.red,
        activeForegroundColor: Colors.white,
        tooltip: 'Add Entry',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        children: [
          SpeedDialChild(
            child: Icon(Icons.camera_alt), // Icon for extracting text
            backgroundColor: Colors.blue,
            label: 'Extract from Image',
            labelStyle: TextStyle(fontSize: 16),
            onTap: () {
              // Handle extracting text from image
              Navigator.pushNamed(context, ExtractPage.id);
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.edit), // Icon for manual input
            backgroundColor: Colors.green,
            label: 'Manual Input',
            labelStyle: TextStyle(fontSize: 16),
            onTap: () {
              // Handle manual input
              Navigator.pushNamed(context, AddOrUpdateReceiptPage.id);
            },
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:receipt_manager/constants/app_colors.dart';
import 'package:receipt_manager/providers/receipt_provider.dart';
import 'package:receipt_manager/screens/financial_report_page.dart';

import '../components/date_range_container.dart';
import '../components/date_roller_picker.dart';
import '../components/expense_item_card.dart';
import '../components/filter_popup.dart';
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
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _suggestions = []; // To hold search suggestions

  // Set default dates
  DateTime? _startDate =
      DateTime(DateTime.now().year, 1, 1); // Start date: first day of the year
  DateTime? _endDate = DateTime.now(); // End date: today

  // Method to open the filter popup
  void _openFilterPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterPopup(
        onApply: (paymentMethods, sortOrder, categoryIds) {
          Provider.of<ReceiptProvider>(context, listen: false).updateFilters(
            paymentMethods: paymentMethods,
            sortOption: sortOrder,
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
                    merchantName: receipt['merchant'] ?? 'Unknown Merchant',
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
    final allReceipts =
        receiptProvider.allReceipts; // Assume you get all receipts here

    setState(() {
      // Update suggestions based on partial match in any of the fields
      _suggestions = allReceipts.where((receipt) {
        return (receipt['merchantName']
                    ?.toLowerCase()
                    .startsWith(query.toLowerCase()) ??
                false) ||
            (receipt['itemName']
                    ?.toLowerCase()
                    .startsWith(query.toLowerCase()) ??
                false) ||
            (receipt['paymentMethod']
                    ?.toLowerCase()
                    .startsWith(query.toLowerCase()) ??
                false) ||
            (receipt['amount']?.toString().startsWith(query) ?? false) ||
            (receipt['description']
                    ?.toLowerCase()
                    .contains(query.toLowerCase()) ??
                false);
      }).toList();
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

  Future<void> _showCalendarFilterDialog() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return CalendarFilterWidget(
          initialStartDate: _startDate!,
          initialEndDate: _endDate!,
          onApply: (start, end) {
            setState(() {
              _startDate = start;
              _endDate = end;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: light90,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the default back arrow
        backgroundColor: light90,
        elevation: 0,
        centerTitle: true,
        actions: [
          DateRangeContainer(
            startDate: _startDate!,
            endDate: _endDate!,
            onCalendarPressed:
                _showCalendarFilterDialog, // Pass the calendar callback
          ),
          SizedBox(width: 8),
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
                // Display the search suggestions dynamically
                if (_suggestions.isNotEmpty)
                  Container(
                    color: Colors.white,
                    height: 150, // Adjust height for suggestions display
                    child: ListView.builder(
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        final displayText =
                            "${suggestion['merchantName'] ?? 'Unknown'} - "
                            "${suggestion['itemName'] ?? ''} "
                            "\$${suggestion['amount']?.toStringAsFixed(2) ?? '0.00'}";

                        return ListTile(
                          title: Text(displayText),
                          onTap: () {
                            _searchController.text = displayText;
                            _performSearch(displayText);
                            setState(() {
                              _suggestions
                                  .clear(); // Clear suggestions on selection
                            });
                          },
                        );
                      },
                    ),
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

                      // Sort option check
                      bool isSortNewest =
                          receiptProvider.sortOption == "Newest";

                      List<Map<String, dynamic>> todayReceipts = isSortNewest
                          ? receipts
                              .where((receipt) => _isToday(
                                  (receipt['date'] as Timestamp?)?.toDate() ??
                                      DateTime.now()))
                              .toList()
                          : [];
                      List<Map<String, dynamic>> yesterdayReceipts =
                          isSortNewest
                              ? receipts
                                  .where((receipt) => _isYesterday(
                                      (receipt['date'] as Timestamp?)
                                              ?.toDate() ??
                                          DateTime.now()))
                                  .toList()
                              : [];
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
                            if (isSortNewest)
                              _buildReceiptSection(context,
                                  sectionTitle: 'Today',
                                  receipts: todayReceipts),
                            if (isSortNewest)
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
    DateTime date = (receipt['date'] as Timestamp?)?.toDate() ?? DateTime.now();
    String formattedDate = DateFormat('MMMM dd, yyyy').format(date);

    if (groupedReceipts.containsKey(formattedDate)) {
      groupedReceipts[formattedDate]!.add(receipt);
    } else {
      groupedReceipts[formattedDate] = [receipt];
    }
  }

  return groupedReceipts;
}

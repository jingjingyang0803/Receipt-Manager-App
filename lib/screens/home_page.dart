import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:receipt_manager/providers/category_provider.dart';
import 'package:receipt_manager/screens/report_page.dart';
import 'package:receipt_manager/screens/summary_page.dart';

import '../constants/app_colors.dart';
import '../providers/receipt_provider.dart';
import 'add_update_receipt_page.dart';
import 'budget_page.dart';

class HomePage extends StatefulWidget {
  static const String id = 'home_page';

  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    categoryProvider.loadUserCategories();

    final receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);
    receiptProvider.fetchAllReceipts(); // Call once during initialization
    receiptProvider.loadReceiptCount();
    receiptProvider.loadOldestAndNewestDates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: light90,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: light90,
        elevation: 0,
        title: const Text(
          'Welcome',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 26),
            _buildQuickActions(context),
            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<ReceiptProvider>(
      builder: (context, receiptProvider, child) {
        final receiptCount = receiptProvider.receiptCount ?? 0;
        final oldestDate = receiptProvider.oldestDate ?? DateTime.now();
        final newestDate = receiptProvider.newestDate ?? DateTime.now();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Total Receipts Section
            Text(
              'Total Receipts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              receiptCount.toString(),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Tracking Period Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTrackingCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'From',
                  date: DateFormat.yMMMd().format(oldestDate),
                  backgroundColor: Colors.blue.shade100,
                  iconColor: Colors.blue.shade600,
                ),
                _buildTrackingCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'To',
                  date: DateFormat.yMMMd().format(newestDate),
                  backgroundColor: Colors.orange.shade100,
                  iconColor: Colors.orange.shade600,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrackingCard({
    required IconData icon,
    required String label,
    required String date,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      width: 150, // Explicitly set the width
      height: 140, // Explicitly set the height
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 150, // Explicitly set the same width as the tracking cards
        height: 120, // Explicitly set the same height as the tracking cards
        padding: const EdgeInsets.all(16), // Internal padding for the content
        decoration: BoxDecoration(
          color: purple20, // Light purple background
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: purple100, // Icon color
              size: 32, // Icon size
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center, // Center align the text
              style: const TextStyle(
                color: purple100,
                fontSize: 16,
                fontWeight: FontWeight.w600, // Slightly bold text
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: Icons.add,
              label: "Add Expense",
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddOrUpdateReceiptPage(),
                    ));
              },
            ),
            _buildActionButton(
              icon: Icons.bar_chart,
              label: "View Reports",
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportPage(),
                    ));
              },
            ),
          ],
        ),
        const SizedBox(height: 26), // Spacing between rows
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: Icons.attach_money,
              label: "Set Budget",
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BudgetPage(),
                    ));
              },
            ),
            _buildActionButton(
              icon: Icons.analytics,
              label: "View Summary",
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SummaryPage(),
                    ));
              },
            ),
          ],
        ),
      ],
    );
  }
}

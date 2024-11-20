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
          'Home',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 20),
            _buildQuickActions(context),
            const SizedBox(height: 20),
            _buildMonthlySummary(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<ReceiptProvider>(
      builder: (context, receiptProvider, child) {
        final receiptCount = receiptProvider.receiptCount ?? 0;
        final oldestDate = receiptProvider.oldestDate;
        final newestDate = receiptProvider.newestDate;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              receiptCount > 0
                  ? 'Here’s a quick snapshot of your finances:\n'
                      '- Total Receipts: $receiptCount\n'
                      '- Tracking Period: ${DateFormat.yMMMd().format(oldestDate ?? DateTime.now())} to ${DateFormat.yMMMd().format(newestDate ?? DateTime.now())}'
                  : 'You haven\'t created any expenses yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.add,
          label: "Add Expense",
          onPressed: () {
            Navigator.pushNamed(context, AddOrUpdateReceiptPage.id);
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
        _buildActionButton(
          icon: Icons.attach_money,
          label: "Set Budget",
          onPressed: () {
            Navigator.pushNamed(context, BudgetPage.id);
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.white,
          ),
          onPressed: onPressed,
          child: Icon(icon, color: purple80),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMonthlySummary(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spending vs. Budget',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
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
    );
  }
}

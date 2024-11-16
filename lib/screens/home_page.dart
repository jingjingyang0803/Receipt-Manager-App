import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:receipt_manager/screens/add_update_receipt_page.dart';
import 'package:receipt_manager/screens/budget_page.dart';
import 'package:receipt_manager/screens/report_page.dart';
import 'package:receipt_manager/screens/summary_page.dart';

import '../constants/app_colors.dart';
import '../providers/receipt_provider.dart';

class HomePage extends StatelessWidget {
  static const String id = 'home_page';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: light90,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the default back arrow
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
        final oldestDate = receiptProvider.oldestAndNewestDates?['oldestDate'];
        final newestDate = receiptProvider.oldestAndNewestDates?['newestDate'];

        print(receiptCount);
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
            // Handle add expense action
            Navigator.pushNamed(context, AddOrUpdateReceiptPage.id);
          },
        ),
        _buildActionButton(
          icon: Icons.bar_chart,
          label: "View Reports",
          onPressed: () {
            // Handle view reports action
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
            // Handle set budget action
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
            backgroundColor: purple20,
          ),
          onPressed: onPressed,
          child: Icon(icon, color: purple100),
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
              // Handle view summary action
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

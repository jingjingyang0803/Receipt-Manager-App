import 'package:flutter/material.dart';

import '../components/expense_item.dart';

class ExpenseListPage extends StatelessWidget {
  static const String id = 'expense_list_page';

  const ExpenseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Transaction', style: TextStyle(color: Colors.black)),
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
            _buildFinancialReportButton(),
            const SizedBox(height: 16),
            const Text('Today',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ExpenseItem(
                icon: Icons.shopping_bag,
                title: "Shopping",
                subtitle: "Buy some grocery",
                amount: "- \$120",
                time: "10:00 AM"),
            ExpenseItem(
                icon: Icons.subscriptions,
                title: "Subscription",
                subtitle: "Disney+ Annual",
                amount: "- \$80",
                time: "03:30 PM"),
            const SizedBox(height: 16),
            const Text('Yesterday',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ExpenseItem(
                icon: Icons.monetization_on,
                title: "Salary",
                subtitle: "Salary for July",
                amount: "+ \$5000",
                time: "04:30 PM"),
            ExpenseItem(
                icon: Icons.directions_car,
                title: "Transportation",
                subtitle: "Charging Tesla",
                amount: "- \$18",
                time: "08:30 PM"),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialReportButton() {
    return TextButton(
      onPressed: () {
        // Handle financial report navigation
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.purple.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      child: Text("See your financial report",
          style: TextStyle(color: Colors.purple.shade700)),
    );
  }
}

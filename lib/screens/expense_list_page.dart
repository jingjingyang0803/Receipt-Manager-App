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
              categoryIcon: Icons.shopping_bag,
              categoryName: "Shopping",
              merchantName: "Buy some grocery",
              amount: "- \$120",
              paymentMethod: "Credit Card",
            ),
            ExpenseItem(
              categoryIcon: Icons.subscriptions,
              categoryName: "Subscription",
              merchantName: "Disney+ Annual",
              amount: "- \$80",
              paymentMethod: "Debit Card",
            ),
            const SizedBox(height: 16),
            const Text(
              'Yesterday',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ExpenseItem(
              categoryIcon: Icons.monetization_on,
              categoryName: "Salary",
              merchantName: "Salary for July",
              amount: "+ \$5000",
              paymentMethod: "Bank Transfer",
            ),
            ExpenseItem(
              categoryIcon: Icons.directions_car,
              categoryName: "Transportation",
              merchantName: "Charging Tesla",
              amount: "- \$18",
              paymentMethod: "Cash",
            ),
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

import 'package:flutter/material.dart';
import 'package:receipt_manager/constants/app_colors.dart';
import 'package:receipt_manager/screens/financial_report_page.dart';

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
            _buildFinancialReportButton(context),
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

  Widget _buildFinancialReportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Make the button take full width
      child: TextButton(
        onPressed: () {
          // Handle financial report navigation
          Navigator.pushNamed(context, FinancialReportPage.id);
        },
        style: TextButton.styleFrom(
          backgroundColor: purple20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
          ),
          padding: const EdgeInsets.all(14), // Adjusted padding for height
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Space text and icon to edges
          children: [
            Text(
              "See your financial report",
              style: TextStyle(
                color: purple100,
                fontSize: 16,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios, // Thinner right arrow icon
              color: purple100,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

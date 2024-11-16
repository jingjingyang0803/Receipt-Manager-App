import 'package:flutter/material.dart';
import 'package:receipt_manager/screens/add_update_receipt_page.dart';
import 'package:receipt_manager/screens/budget_page.dart';
import 'package:receipt_manager/screens/report_page.dart';
import 'package:receipt_manager/screens/summary_page.dart';

import '../constants/app_colors.dart';

class HomePage extends StatefulWidget {
  static const String id = 'home_page';

  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: light90,
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Removes the default back arrowbackgroundColor: Colors.white,
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
            _buildQuickActions(),
            const SizedBox(height: 20),
            _buildMonthlySummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Welcome back!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Here’s a quick overview of your finances this month.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
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

  Widget _buildMonthlySummary() {
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
              // Handle view reports action
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

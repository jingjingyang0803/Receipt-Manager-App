import 'package:flutter/material.dart';

import '../components/custom_bottom_nav_bar.dart';
import 'expense_list_page.dart';
import 'home_page.dart';

class BasePage extends StatefulWidget {
  static const String id = 'base_page';
  const BasePage({super.key});

  @override
  BasePageState createState() => BasePageState();
}

class BasePageState extends State<BasePage> {
  int _selectedIndex = 1; // Default to the "Transaction" tab

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFabPressed() {
    // Handle action for FAB, e.g., navigate to add new transaction page
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return HomePage();
      case 1:
        return ExpenseListPage();
      case 2:
      // return BudgetPage();
      case 3:
      // return ProfilePage();
      default:
        return ExpenseListPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedPage(),
      bottomNavigationBar: CustomBottomNavBar(
        initialIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
        onFabPressed: _onFabPressed,
      ),
    );
  }
}
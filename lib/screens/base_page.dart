import 'package:flutter/material.dart';
import 'package:receipt_manager/constants/app_colors.dart';
import 'package:receipt_manager/screens/add_update_receipt_screen.dart';
import 'package:receipt_manager/screens/profile_screen.dart';

import '../components/custom_bottom_nav_bar.dart';
import 'budget_screen.dart';
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
    // Handle action for FAB, navigate to add new expense page
    Navigator.pushNamed(context, AddOrUpdateReceiptScreen.id);
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return HomePage();
      case 1:
        return ExpenseListPage();
      case 2:
        return BudgetScreen();
      case 3:
        return ProfileScreen();
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 20), // Move the button up by adding bottom padding
        child: GestureDetector(
          onTap: _onFabPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: purple100,
              borderRadius:
                  BorderRadius.circular(30), // Rounded rectangle shape
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.add, color: backgroundBaseColor), // FAB icon
                SizedBox(width: 8), // Space between icon and text
                Text(
                  "Add new",
                  style: TextStyle(color: backgroundBaseColor, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

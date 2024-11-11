import 'package:flutter/material.dart';
import 'package:receipt_manager/screens/add_update_receipt_screen.dart';
import 'package:receipt_manager/screens/profile_screen.dart';

import '../components/custom_bottom_nav_bar.dart';
import '../constants/app_colors.dart';
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
      floatingActionButton: Container(
        width: 75, // Larger white circle size
        height: 75,
        decoration: BoxDecoration(
          color: Color(0xFFF6F6F6), // Light gray background for the circle
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          // Center the FAB inside the white circle
          child: FloatingActionButton(
            onPressed: _onFabPressed,
            backgroundColor: mainPurpleColor,
            shape: const CircleBorder(),
            elevation: 0,
            child: const Icon(
              Icons.add,
              color: backgroundBaseColor,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerDocked, // Centers the FAB above the BottomAppBar
    );
  }
}

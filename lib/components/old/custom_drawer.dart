import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:receipt_manager/screens/old/dashboard_screen.dart';
import 'package:receipt_manager/screens/old/expense_chart_screen.dart';

import '../../screens/budget_screen.dart';
import '../../screens/category_screen.dart';
import '../../screens/old/setting_screen.dart';
import '../../screens/old/summary_screen.dart';
import '../../screens/receipt_list_screen.dart';
import '../../services/user_service_old.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  CustomDrawerState createState() => CustomDrawerState();
}

class CustomDrawerState extends State<CustomDrawer> {
  final UserService _userService = UserService();
  String? userName;
  String? city;
  String? country;
  File? profileImage;

  @override
  void initState() {
    super.initState();
    _userService.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userService.fetchUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error fetching user data');
        }

        return Drawer(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Dashboard'),
                  onTap: () {
                    Navigator.pushNamed(context, DashboardScreen.id);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.receipt),
                  title: Text('My Receipts'),
                  onTap: () {
                    Navigator.pushNamed(context, ReceiptListScreen.id);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.category),
                  title: Text('Manage Categories'),
                  onTap: () {
                    Navigator.pushNamed(context, CategoryScreen.id);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.savings),
                  title: Text('Budget Planner'),
                  onTap: () {
                    Navigator.pushNamed(context, BudgetScreen.id);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('Monthly Overview'),
                  onTap: () {
                    Navigator.pushNamed(context, SummaryScreen.id);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.bar_chart),
                  title: Text('Expense Analytics'),
                  onTap: () {
                    Navigator.pushNamed(context, ExpenseChartScreen.id);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () {
                    Navigator.pushNamed(context, SettingScreen.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

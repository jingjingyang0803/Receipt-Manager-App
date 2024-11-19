import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receipt_manager/providers/user_provider.dart';
import 'package:receipt_manager/screens/report_page.dart';
import 'package:receipt_manager/screens/settings_page.dart';

import '../components/custom_bottom_nav_bar.dart';
import '../providers/category_provider.dart';
import '../providers/receipt_provider.dart';
import 'home_page.dart';
import 'receipt_list_page.dart';

class BasePage extends StatefulWidget {
  static const String id = 'base_page';
  const BasePage({super.key});

  @override
  BasePageState createState() => BasePageState();
}

class BasePageState extends State<BasePage> {
  int _selectedIndex = 1; // Default to the "Transaction" tab
  late Future<void> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _preloadData();
  }

  Future<void> _preloadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.fetchUserProfile();

    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    categoryProvider.loadUserCategories();

    final receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);
    await receiptProvider.fetchAllReceipts();
    receiptProvider.applyFilters(); // Preload filters if needed
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return HomePage();
      case 1:
        return ReceiptListPage();
      case 2:
        return ReportPage();
      case 3:
        return SettingsPage();
      default:
        return ReceiptListPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error loading data: ${snapshot.error}')),
          );
        }

        return Scaffold(
          body: _getSelectedPage(),
          bottomNavigationBar: CustomBottomNavBar(
            initialIndex: _selectedIndex,
            onTabSelected: _onTabSelected,
          ),
        );
      },
    );
  }
}

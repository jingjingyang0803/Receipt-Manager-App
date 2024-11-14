import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:receipt_manager/screens/category_page.dart';

import 'screens/add_update_receipt_screen.dart';
import 'screens/base_page.dart';
import 'screens/budget_screen.dart';
import 'screens/email_sent_page.dart';
import 'screens/expense_list_page.dart';
import 'screens/financial_report_page.dart';
import 'screens/forgot_password_page.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/old/category_screen.dart';
import 'screens/old/dashboard_screen.dart';
import 'screens/old/expense_chart_screen.dart';
import 'screens/old/scan_screen.dart';
import 'screens/old/setting_screen.dart';
import 'screens/old/summary_screen.dart';
import 'screens/profile_page.dart';
import 'screens/receipt_list_screen.dart';
import 'screens/set_budget_page.dart';
import 'screens/signup_page.dart';
import 'screens/verification_link_page.dart';
import 'screens/welcome_page.dart';

Map<String, WidgetBuilder> appRoutes = {
  WelcomePage.id: (context) => WelcomePage(),
  SignUpPage.id: (context) => SignUpPage(),
  VerificationLinkPage.id: (context) => VerificationLinkPage(
        user: FirebaseAuth.instance.currentUser!,
      ),
  LogInPage.id: (context) => LogInPage(),
  ForgotPasswordPage.id: (context) => ForgotPasswordPage(),
  EmailSentPage.id: (context) => EmailSentPage(email: ''),
  BasePage.id: (context) => BasePage(),
  HomePage.id: (context) => HomePage(),
  ExpenseListPage.id: (context) => ExpenseListPage(),
  ProfilePage.id: (context) => ProfilePage(),
  CategoryPage.id: (context) => CategoryPage(),
  FinancialReportPage.id: (context) => FinancialReportPage(),

  ////
  ScanScreen.id: (context) => ScanScreen(),
  AddOrUpdateReceiptScreen.id: (context) => AddOrUpdateReceiptScreen(),
  ReceiptListScreen.id: (context) => ReceiptListScreen(),
  CategoryScreen.id: (context) => CategoryScreen(),
  BudgetScreen.id: (context) => BudgetScreen(),
  SummaryScreen.id: (context) => SummaryScreen(),
  ExpenseChartScreen.id: (context) => ExpenseChartScreen(),
  DashboardScreen.id: (context) => DashboardScreen(),
  SettingScreen.id: (context) => SettingScreen(),
  SetBudgetPage.id: (context) => SetBudgetPage(),
};

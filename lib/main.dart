import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receipt_manager/providers/currency_provider.dart';
import 'package:receipt_manager/providers/receipt_provider.dart';

import 'firebase_options.dart';
import 'providers/authentication_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/category_provider.dart';
import 'providers/user_provider.dart';
import 'routes.dart';
import 'screens/base_page.dart';
import 'screens/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(
            create: (_) =>
                CurrencyProvider()), // Ensure CurrencyProvider is initialized before ReceiptProvider
        ChangeNotifierProxyProvider<AuthenticationProvider, UserProvider>(
          create: (_) => UserProvider(),
          update: (context, authProvider, userProvider) {
            userProvider!.authProvider = authProvider;
            return userProvider;
          },
        ),
        // Make sure CategoryProvider comes before BudgetProvider
        ChangeNotifierProxyProvider<AuthenticationProvider, CategoryProvider>(
          create: (_) => CategoryProvider(),
          update: (context, authProvider, categoryProvider) {
            categoryProvider!.authProvider = authProvider;
            return categoryProvider;
          },
        ),
        ChangeNotifierProxyProvider2<AuthenticationProvider, CategoryProvider,
            BudgetProvider>(
          create: (_) => BudgetProvider(),
          update: (context, authProvider, categoryProvider, budgetProvider) {
            budgetProvider!.authProvider = authProvider;
            budgetProvider.categoryProvider = categoryProvider;
            budgetProvider
                .updateCategories(); // Call a method to update categories in BudgetProvider
            return budgetProvider;
          },
        ),
        ChangeNotifierProxyProvider4<AuthenticationProvider, UserProvider,
            CategoryProvider, CurrencyProvider, ReceiptProvider>(
          create: (_) => ReceiptProvider(),
          update: (context, authProvider, userProvider, categoryProvider,
              currencyProvider, receiptProvider) {
            receiptProvider ??= ReceiptProvider();
            receiptProvider.authProvider = authProvider;
            receiptProvider.userProvider = userProvider;
            receiptProvider.categoryProvider = categoryProvider;
            receiptProvider.currencyProvider = currencyProvider;
            return receiptProvider;
          },
        ),
      ],

    );
  }
}

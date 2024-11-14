import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

        // Inject AuthenticationProvider into other Provider
        ChangeNotifierProxyProvider<AuthenticationProvider, UserProvider>(
          create: (_) => UserProvider(),
          update: (context, authProvider, userProvider) {
            userProvider!.authProvider = authProvider;
            return userProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthenticationProvider, BudgetProvider>(
          create: (_) => BudgetProvider(),
          update: (context, authProvider, budgetProvider) {
            budgetProvider!.authProvider = authProvider;
            return budgetProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthenticationProvider, CategoryProvider>(
          create: (_) => CategoryProvider(),
          update: (context, authProvider, categoryProvider) {
            categoryProvider!.authProvider = authProvider;
            return categoryProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthenticationProvider, ReceiptProvider>(
          create: (_) => ReceiptProvider(),
          update: (context, authProvider, receiptProvider) {
            receiptProvider!.authProvider = authProvider;
            return receiptProvider;
          },
        ),
      ],
      child: Consumer<AuthenticationProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            initialRoute:
                authProvider.isAuthenticated ? BasePage.id : WelcomePage.id,
            routes: appRoutes,
          );
        },
      ),
    );
  }
}

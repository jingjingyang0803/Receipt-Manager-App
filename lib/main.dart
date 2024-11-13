import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receipt_manager/auth_manager.dart';
import 'package:receipt_manager/routes.dart';
import 'package:receipt_manager/screens/base_page.dart';
import 'package:receipt_manager/screens/welcome_page.dart';

import 'firebase_options.dart'; // Updated import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthManager()), // Updated here
      ],
      child: Consumer<AuthManager>(
        // Updated here
        builder: (context, authManager, child) {
          return MaterialApp(
            initialRoute:
                authManager.isAuthenticated ? BasePage.id : WelcomePage.id,
            routes: appRoutes,
          );
        },
      ),
    );
  }
}

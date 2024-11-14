import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receipt_manager/providers/authentication_provider.dart';
import 'package:receipt_manager/providers/user_provider.dart';
import 'package:receipt_manager/routes.dart';
import 'package:receipt_manager/screens/base_page.dart';
import 'package:receipt_manager/screens/welcome_page.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // other providers if necessary
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthenticationProvider()), // Updated here
      ],
      child: Consumer<AuthenticationProvider>(
        // Updated here
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

import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  static const String id = 'terms_of_service_page';

  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms of Service"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          // Terms of Service content
          "xiaosi   xxxxxxxxxxxx",
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}




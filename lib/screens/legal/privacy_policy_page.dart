import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  static const String id = 'privacy_policy_page';

  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          //  Privacy Policy content
          "xiaosi  xxxxxxxxxxx",
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Privacy Policy",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "Lightspeed Oy respects your privacy and is committed to protecting your personal data. "
                  "This Privacy Policy explains how we collect, use, and share your information when you use the Receipt Manager application.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "1. Information We Collect",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "- Account Data: Name, email address, and password provided during registration.\n"
                  "- Financial Data: Data related to receipts and expense tracking.\n"
                  "- Device Information: Details about the device, such as operating system and IP address.\n"
                  "- Usage Data: Interaction with the app, including preferences and feature usage.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "2. How We Use Your Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "- Provide and improve the Receipt Manager application.\n"
                  "- Personalize your experience and offer tailored features.\n"
                  "- Comply with legal obligations.\n"
                  "- Respond to user inquiries and provide customer support.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "3. Sharing Your Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "We do not sell your personal information. However, we may share your data with third parties under these circumstances:\n"
                  "- With your explicit consent.\n"
                  "- To comply with legal requirements in Finland.\n"
                  "- With trusted service providers (e.g., cloud hosting providers).\n"
                  "- During mergers, acquisitions, or similar transactions.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "4. Your Rights",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Under Finnish law, you have the following rights:\n"
                  "- Access and review your data.\n"
                  "- Request corrections to incorrect or outdated information.\n"
                  "- Request deletion of your data (right to be forgotten).\n"
                  "- Withdraw consent at any time for processing of your data.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "5. Contact Us",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "If you have questions or concerns about your privacy, please contact us at:\n"
                  "Lightspeed Oy\n"
                  "Address: Kuntokatu 3, 33520 Tampere, Finland\n"
                  "Phone: +358 123456789\n"
                  "Email: privacy@lightspeed.fi",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

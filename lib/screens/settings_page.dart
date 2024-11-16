import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:receipt_manager/screens/budget_page.dart';

import '../components/currency_roller_picker_popup.dart';
import '../components/logout_popup.dart';
import '../constants/app_colors.dart';
import '../logger.dart';
import '../providers/authentication_provider.dart';
import '../providers/user_provider.dart';
import 'category_page.dart';

class SettingsPage extends StatefulWidget {
  static const String id = 'settings_page';

  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final _picker = ImagePicker();
  XFile? _profileImage;
  late TextEditingController _nameController;
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();

    userProvider = Provider.of<UserProvider>(context, listen: false);

    // Initialize the controller with the current user name from provider
    _nameController = TextEditingController(text: userProvider.userName);

    // Initialize _profileImage with the saved profile image path, if available
    final profileImagePath = userProvider.profileImagePath;
    if (profileImagePath != null && profileImagePath.isNotEmpty) {
      _profileImage =
          XFile(profileImagePath); // Wrap the path in XFile for consistency
    }

    // Fetch the user profile when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userProvider.fetchUserProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose(); // Dispose controller when the widget is disposed
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = image;
      });

      // Update profile image in provider
      userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.updateProfileImage(image.path);
    }
  }

  Future<void> _saveUserName() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final newName = _nameController.text.trim();

    // Proceed with the update if the new name is different from the current name, even if empty
    if (newName != userProvider.userName) {
      await userProvider.updateUserProfile(userName: newName);
    }
  }

  Future<void> _showCurrencyPicker(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return CurrencyPicker(
          selectedCurrencyCode: 'EUR', // Provide a default,
          onCurrencyCodeSelected: (String newCurrencyCode) async {
            userProvider = Provider.of<UserProvider>(context, listen: false);

            // Proceed with the update if the new name is different from the current name, even if empty
            if (newCurrencyCode != userProvider.currencyCode) {
              logger.i("Updating currency to $newCurrencyCode");
              await userProvider.updateUserProfile(
                  currencyCode: newCurrencyCode);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    final userEmail = authProvider.user?.email;

    return Scaffold(
      backgroundColor: light90,
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Removes the default back arrowbackgroundColor: light90,
        backgroundColor: light90,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final profileImagePath = userProvider.profileImagePath;

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 80,
                            height: 80,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: purple80,
                                width: 2.0,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage: _profileImage != null
                                  ? FileImage(File(_profileImage!.path))
                                  : profileImagePath != null
                                      ? NetworkImage(profileImagePath)
                                      : null,
                              radius: 45.0,
                              child: profileImagePath == null
                                  ? Icon(Icons.person,
                                      size: 50, color: Colors.grey)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userEmail ?? "Email not available",
                            style: TextStyle(color: purple200, fontSize: 16),
                          ),
                          TextFormField(
                            controller: _nameController,
                            style: TextStyle(
                              color: dark75,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              hintText: 'Your Name',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            onFieldSubmitted: (_) => _saveUserName(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        color: light80,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          SettingsMenuItem(
                            icon: Icons.category_outlined,
                            text: "Manage Categories",
                            iconBackgroundColor: purple20,
                            iconColor: purple100,
                            onTap: () {
                              Navigator.pushNamed(context, CategoryPage.id);
                            },
                          ),
                          Divider(thickness: 1, color: light90),
                          SettingsMenuItem(
                            icon: Icons.savings_outlined,
                            text: "Manage Budgets",
                            iconBackgroundColor: purple20,
                            iconColor: purple100,
                            onTap: () {
                              Navigator.pushNamed(context, BudgetPage.id);
                            },
                          ),
                          Divider(thickness: 1, color: light90),
                          SettingsMenuItem(
                            icon: Icons.attach_money,
                            text: "Choose Currency",
                            iconBackgroundColor: purple20,
                            iconColor: purple100,
                            onTap: () => _showCurrencyPicker(context),
                          ),
                          Divider(thickness: 1, color: light90),
                          SettingsMenuItem(
                            icon: Icons.file_download_outlined,
                            text: "Export Data",
                            iconBackgroundColor: purple20,
                            iconColor: purple100,
                            onTap: () {},
                          ),
                          Divider(thickness: 1, color: light90),
                          SettingsMenuItem(
                            icon: Icons.logout,
                            text: "Logout",
                            iconBackgroundColor: red20,
                            iconColor: red100,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (BuildContext context) {
                                  return LogoutPopup(
                                    onConfirm: () {
                                      Navigator.of(context).pop();
                                    },
                                    onCancel: () {
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Widget for Profile Menu Item
class SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconBackgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const SettingsMenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(fontSize: 18, color: dark75),
            ),
          ],
        ),
      ),
    );
  }
}

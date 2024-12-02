import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:receipt_manager/screens/budget_page.dart';

import '../components/currency_roller_picker_popup.dart';
import '../components/feedback_popup.dart';
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
  bool _isEditingName =
      false; // Track whether the "Your Name" field is in edit mode

  String? currencyCode;
  String? currencySymbol;

  @override
  void initState() {
    super.initState();

    // Access the UserProvider instance
    userProvider = Provider.of<UserProvider>(context, listen: false);

    // Fetch the user profile data
    userProvider.fetchUserProfile();

    // Initialize the name controller
    _nameController = TextEditingController(text: userProvider.userName);

    // Initialize currency code and symbol
    currencyCode = userProvider.currencyCode;
    if (currencyCode != null && currencyCode!.isNotEmpty) {
      currencySymbol =
          NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;
    } else {
      currencySymbol = '€'; // Default symbol
    }

    // Wait for user profile to fetch and reflect updates after widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // Fetch updated profile image from Firestore
        final profileImagePath = userProvider.profileImagePath;
        if (profileImagePath != null && profileImagePath.isNotEmpty) {
          _profileImage = null; // Ensure local path is not used
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose(); // Dispose controller when the widget is disposed
    debugPrint('Disposing SettingsPage widget...');
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      if (!mounted) return;
      setState(() {
        _profileImage = image; // Temporarily show the image
      });

      try {
        // Upload the image and update the profile image path
        await userProvider.updateProfileImage(image.path);
        if (mounted) { // Check again before showing the Snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile image updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile image: $e')),
          );
        }
      }
    }
  }

  Future<void> _saveUserName() async {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty && newName != userProvider.userName) {
      // Save the updated name to the UserProvider
      await userProvider.updateUserProfile(userName: newName);
    }
    if (mounted) {
      setState(() {
        _isEditingName = false;
      });
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
            // Proceed with the update if the new name is different from the current name, even if empty
            if (newCurrencyCode != userProvider.currencyCode) {
              logger.i("Updating currency to $newCurrencyCode");
              await userProvider.updateUserProfile(
                  currencyCode: newCurrencyCode);
              // Update the state to reflect the new currency immediately
              setState(() {
                currencyCode = newCurrencyCode;
                currencySymbol =
                    NumberFormat.simpleCurrency(name: newCurrencyCode)
                        .currencySymbol;
              });
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    final userEmail = authProvider.user?.email;


    return Scaffold(
      backgroundColor: light90,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the default back arrow
        backgroundColor: light90,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [



          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 26), // Increased vertical padding
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    GestureDetector(
                      onTap: _pickImage, // Opens the image picker for changing the profile picture
                      child: Container(
                        width: 100, // Increased size
                        height: 100, // Increased size
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: purple80, width: 3.0), // Thicker border
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: _profileImage != null
                              ? FileImage(File(_profileImage!.path))
                              : userProvider.profileImagePath != null
                              ? NetworkImage(userProvider.profileImagePath!) as ImageProvider
                              : null,
                          radius: 45, // Increased radius
                          child: userProvider.profileImagePath == null
                              ? Icon(Icons.person, size: 50, color: Colors.grey) // Larger icon
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16), // Increased spacing
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userEmail ?? "Email not available",
                        style: TextStyle(color: purple200, fontSize: 18), // Larger font size
                      ),
                      _isEditingName
                          ? TextFormField(
                        controller: _nameController,
                        style: TextStyle(
                          color: dark75,
                          fontSize: 24, // Increased font size
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          hintText: 'Your Name',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      )
                          : Text(
                        _nameController.text.isEmpty ? 'Your Name' : _nameController.text,
                        style: TextStyle(
                          color: dark75,
                          fontSize: 24, // Increased font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                _isEditingName
                    ? Row(
                  mainAxisSize: MainAxisSize.min, // Shrink row to fit content
                  crossAxisAlignment: CrossAxisAlignment.center, // Align buttons in center
                  children: [
                    // Check Button
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.green,
                          elevation: 3,
                        ),
                        onPressed: () async {
                          await _saveUserName();
                          setState(() {
                            _isEditingName = false;
                          });
                        },
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    // Cross Button
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.red,
                          elevation: 3,
                        ),
                        onPressed: () {
                          setState(() {
                            _isEditingName = false;
                            _nameController.text = userProvider.userName ?? '';
                          });
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                )
                    : Container(
                  decoration: BoxDecoration(
                    color: purple100,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  width: 50,
                  height: 50,
                  child: IconButton(
                    icon: Icon(Icons.edit, color: Colors.white, size: 22), // Larger icon
                    onPressed: () {
                      setState(() {
                        _isEditingName = true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),



          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8), // Adjust padding to move the section up
              child: Container(
                decoration: BoxDecoration(
                  color: light80,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20), // Rounded corners
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                        SettingsMenuItem(
                          icon: Icons.category_outlined,
                          text: "Manage Categories",
                          iconBackgroundColor: purple20,
                          iconColor: purple100,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CategoryPage()),
                            ).then((_) {
                              if (mounted) {
                                setState(() {
                                  // Perform updates only if the widget is still active
                                });
                              }
                            });
                          },
                        ),
                        SizedBox(height: 15), // Adjusted spacing
                        SettingsMenuItem(
                          icon: Icons.savings_outlined,
                          text: "Manage Budgets",
                          iconBackgroundColor: purple20,
                          iconColor: purple100,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BudgetPage()),
                            ).then((_) {
                              if (mounted) {
                                setState(() {
                                  // Perform updates only if the widget is still active
                                });
                              }
                            });
                          },
                        ),
                      SizedBox(height: 15), // Adjusted spacing
                      SettingsMenuItem(
                        icon: Icons.attach_money,
                        text: "Choose Currency",
                        iconBackgroundColor: purple20,
                        iconColor: purple100,
                        onTap: () {
                          _showCurrencyPicker(context);
                        },
                        trailingTextBuilder: () => "$currencyCode $currencySymbol", // Add the trailing text for currency
                      ),

                      SizedBox(height: 15), // Adjusted spacing
                        SettingsMenuItem(
                          icon: Icons.feedback_outlined,
                          text: "Feedback",
                          iconBackgroundColor: purple20,
                          iconColor: purple100,
                          onTap: () {
                            FeedbackDialog.showFeedbackDialog(context);
                          },
                        ),
                        SizedBox(height: 15), // Adjusted spacing
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
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2, // Dynamic bottom spacing
                        ),
                      ]

                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}


class SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconBackgroundColor;
  final Color iconColor;
  final VoidCallback onTap;
  final String Function()? trailingTextBuilder;

  const SettingsMenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.onTap,
    this.trailingTextBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust spacing
        child: Container(
          height: screenHeight * 0.08, // Dynamic height based on screen size
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16), // Inner padding
            child: Row(
              children: [
                // Icon Section
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                SizedBox(width: 12),
                // Text Section
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: screenHeight * 0.021, // Dynamic text size
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Trailing Text or Icon
                trailingTextBuilder != null
                    ? Text(
                  trailingTextBuilder!(),
                  style: TextStyle(
                    fontSize: screenHeight * 0.018, // Slightly smaller text for trailing
                    color: Colors.grey.shade600,
                  ),
                )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

}


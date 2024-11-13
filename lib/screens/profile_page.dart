import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../components/logout_popup.dart';
import '../constants/app_colors.dart';

class ProfilePage extends StatefulWidget {
  static const String id = 'profile_page';

  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final _picker = ImagePicker();
  final String _userEmail = "jingjing.yang@tuni.fi";
  String _userName = "Iriana Saliha";
  XFile? _profileImage;

  // Function to pick an image from gallery
  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  // Function to edit the username
  void _editUserName() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller =
            TextEditingController(text: _userName);
        return AlertDialog(
          title: Text("Edit Username"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter new username"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _userName = controller.text;
                });
                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: light90,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Row(
              children: [
                // Profile Picture with Border
                // Profile Picture with Border
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    GestureDetector(
                      onTap:
                          _pickImage, // Add the image picker function if needed
                      child: Container(
                        width: 80,
                        height: 80,
                        padding: const EdgeInsets.all(3), // Border thickness
                        decoration: BoxDecoration(
                          color: Colors
                              .transparent, // Border color, transparent if needed
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: purple100, // Set your preferred border color
                            width: 2.0, // Border width
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: _profileImage != null
                              ? AssetImage('assets/images/plan.png')
                              : null,
                          radius: 45.0,
                          child: _profileImage == null
                              ? Icon(Icons.person, size: 50, color: Colors.grey)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Username and Edit
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: TextStyle(
                          color: dark75,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _userEmail,
                      style: TextStyle(color: light20, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(width: 66),
                GestureDetector(
                  onTap: _editUserName,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: light80, // Background color
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      border: Border.all(
                        color: purple10, // Border color
                        width: 1, // Border width
                      ),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      color: dark50,
                      size: 30, // Icon size
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: light80, // Background color for the entire container
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      ProfileMenuItem(
                        icon: Icons.category_outlined,
                        text: "Manage categories",
                        iconBackgroundColor: purple20,
                        iconColor: purple100,
                        onTap: () {},
                      ),
                      Divider(thickness: 1, color: light90),
                      ProfileMenuItem(
                        icon: Icons.attach_money,
                        text: "Choose currency",
                        iconBackgroundColor: purple20,
                        iconColor: purple100,
                        onTap: () {},
                      ),
                      // Divider(thickness: 1, color: light90),
                      // ProfileMenuItem(
                      //   icon: Icons.language,
                      //   text: "Choose language",
                      //   iconBackgroundColor: purple20,
                      //   iconColor: purple100,
                      // ),
                      // Divider(thickness: 1, color: light90),
                      // ProfileMenuItem(
                      //   icon: Icons.help_outline,
                      //   text: "Frequently asked questions",
                      //   iconBackgroundColor: purple20,
                      //   iconColor: purple100,
                      // ),
                      Divider(thickness: 1, color: light90),
                      ProfileMenuItem(
                        icon: Icons.settings_outlined,
                        text: "Settings",
                        iconBackgroundColor: purple20,
                        iconColor: purple100,
                        onTap: () {},
                      ),
                      Divider(thickness: 1, color: light90),
                      ProfileMenuItem(
                        icon: Icons.file_download_outlined,
                        text: "Export Data",
                        iconBackgroundColor: purple20,
                        iconColor: purple100,
                        onTap: () {},
                      ),
                      Divider(thickness: 1, color: light90),
                      ProfileMenuItem(
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
                                  // Perform logout action
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
      ),
    );
  }
}

// Widget for Profile Menu Item
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconBackgroundColor;
  final Color iconColor;
  final VoidCallback onTap; // Add onTap as a parameter

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.onTap, // Make onTap required
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Trigger onTap when the item is tapped
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8), // Adjust padding for icon size
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

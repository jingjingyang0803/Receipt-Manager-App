import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../components/logout_popup.dart';
import '../components/user_edit_popup.dart';
import '../constants/app_colors.dart';
import '../providers/authentication_provider.dart';
import '../providers/user_provider.dart';

class ProfilePage extends StatefulWidget {
  static const String id = 'profile_page';

  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final _picker = ImagePicker();
  XFile? _profileImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Trigger fetchUserProfile to load data
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.fetchUserProfile(context);
    });
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = image;
      });

      // Update profile image in provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.updateProfileImage(context, image.path);
    }
  }

  // Function to show edit profile popup
  void _showEditPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return const UserEditPopup();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    final userEmail = authProvider.user?.email;

    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.userName ?? "Your Name";
    final profileImagePath = userProvider.profileImagePath;

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
                            color: purple100,
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
                              ? Icon(Icons.person, size: 50, color: Colors.grey)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Username and Email
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userEmail!,
                      style: TextStyle(color: light20, fontSize: 16),
                    ),
                    Text(
                      userName,
                      style: TextStyle(
                          color: dark75,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(width: 60),
                TextButton(
                  onPressed: () => _showEditPopup(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: light80,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: purple10,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      color: dark50,
                      size: 30,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: light80,
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
  final VoidCallback onTap;

  const ProfileMenuItem({
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

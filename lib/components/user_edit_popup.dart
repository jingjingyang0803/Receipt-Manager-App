import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/user_provider.dart';
import 'custom_button.dart';

class UserEditPopup extends StatefulWidget {
  const UserEditPopup({super.key});

  @override
  UserEditPopupState createState() => UserEditPopupState();
}

class UserEditPopupState extends State<UserEditPopup> {
  final _nameController = TextEditingController();
  XFile? _selectedImage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(
            thickness: 3,
            color: purple40,
            endIndent: 165,
            indent: 165,
          ),
          const SizedBox(height: 8),
          const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Username',
              labelStyle: TextStyle(color: purple40),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _selectedImage != null
                  ? CircleAvatar(
                      radius: 30,
                      backgroundImage: FileImage(File(_selectedImage!.path)),
                    )
                  : const CircleAvatar(
                      radius: 30,
                      backgroundColor: light20,
                      child: Icon(Icons.person, color: purple40),
                    ),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image, color: purple100),
                label: const Text(
                  'Choose Image',
                  style: TextStyle(color: purple100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: CustomButton(
                    text: "Cancel",
                    backgroundColor: purple20,
                    textColor: purple100,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: CustomButton(
                    text: "Save",
                    backgroundColor: purple100,
                    textColor: light80,
                    onPressed: () async {
                      final userProvider =
                          Provider.of<UserProvider>(context, listen: false);
                      final userName = _nameController.text.trim();
                      final profileImagePath = _selectedImage?.path;

                      if (userName.isNotEmpty || profileImagePath != null) {
                        await userProvider.updateUserProfile(
                          context,
                          userName: userName.isNotEmpty ? userName : null,
                          profileImagePath: profileImagePath,
                          currencyCode: '',
                        );
                      }

                      // Ensure widget is still mounted before popping context
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

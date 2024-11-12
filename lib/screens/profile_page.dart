import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  static const String id = 'profile_page';

  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final _picker = ImagePicker();
  final String _useremail = "jingjing.yang@tuni.fi";
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
      backgroundColor: Colors.grey.shade100,
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
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: _profileImage == null
                          ? AssetImage(
                              'assets/images/plan.png') // Default image path
                          : AssetImage('assets/images/control.png'),
                      backgroundColor: Colors.transparent,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.grey.shade300, width: 2),
                          ),
                          child: const Icon(Icons.edit,
                              color: Colors.grey, size: 16),
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text(
                          _useremail,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _editUserName,
                          child: Icon(Icons.edit,
                              color: Colors.grey.shade600, size: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Profile Menu Items
            ProfileMenuItem(
              icon: Icons.account_balance_wallet_outlined,
              text: "My Wallet",
              iconBackgroundColor: Colors.purple.shade100,
              iconColor: Colors.purple,
            ),
            ProfileMenuItem(
              icon: Icons.settings,
              text: "Settings",
              iconBackgroundColor: Colors.purple.shade200,
              iconColor: Colors.deepPurple,
            ),
            ProfileMenuItem(
              icon: Icons.download,
              text: "Export Data",
              iconBackgroundColor: Colors.purple.shade100,
              iconColor: Colors.purple,
            ),
            ProfileMenuItem(
              icon: Icons.logout,
              text: "Logout",
              iconBackgroundColor: Colors.red.shade100,
              iconColor: Colors.red,
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

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.iconBackgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Text(text, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

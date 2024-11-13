import 'package:flutter/material.dart';

class LogoutPopup extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const LogoutPopup(
      {required this.onConfirm, required this.onCancel, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Column(
        children: [
          Divider(
            thickness: 2,
            color: Color(0xFFEEE5FF), // You can use purple20 here if defined
          ),
          SizedBox(height: 8),
          Text(
            'Logout?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to logout?',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            backgroundColor:
                Color(0xFFFDD5D7), // Use red20 for cancel button background
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'No',
            style: TextStyle(
              color: Color(0xFFFD3C4A), // Use red100 for text color
              fontSize: 16,
            ),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          style: TextButton.styleFrom(
            backgroundColor: Color(
                0xFF7F3DFF), // Use purple100 for confirm button background
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Yes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF6C63FF), // Default background color
    this.textColor = Colors.white, // Default text color
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,

        child: Text(
    text,
    style: TextStyle(
    color: textColor,
    fontSize: 18,
    fontWeight: FontWeight.w600,
        ),
    maxLines: 1, // Ensure text stays in one line
    overflow: TextOverflow.ellipsis, // Handle overflow gracefully
      ),
    ),
    );
  }
}
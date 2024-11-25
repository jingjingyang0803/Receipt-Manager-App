import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'custom_button.dart';
import 'custom_divider.dart';

class FeedbackDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final TextEditingController feedbackController;

  const FeedbackDialog({
    required this.onCancel,
    required this.onSubmit,
    required this.feedbackController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom +
              12, // Adjust for keyboard
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomDivider(),
            SizedBox(height: 8),
            Text(
              'Submit Feedback',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We value your feedback! Please share your thoughts below.',
              style: TextStyle(
                fontSize: 16,
                color: purple200,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            TextField(
              controller: feedbackController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey, // Default border color
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors
                        .grey, // Border color when enabled but not focused
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: purple80, // Border color when the field is focused
                    width: 2.0,
                  ),
                ),
                hintText: 'Enter your feedback here...',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            SizedBox(height: 20),
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
                      onPressed: onCancel,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: CustomButton(
                      text: "Submit",
                      backgroundColor: purple100,
                      textColor: light80,
                      onPressed: onSubmit,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

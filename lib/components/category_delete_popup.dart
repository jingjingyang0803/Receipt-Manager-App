import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receipt_manager/constants/app_colors.dart';

import '../providers/category_provider.dart';
import 'custom_button.dart';

class CategoryDeletePopup extends StatelessWidget {
  final String categoryId;
  final VoidCallback onCancel;

  const CategoryDeletePopup({
    required this.categoryId,
    required this.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
          Divider(
            thickness: 3,
            color: purple40,
            endIndent: 165,
            indent: 165,
          ),
          SizedBox(height: 8),
          Text(
            'Delete Category?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'If you delete this category, the receipts belonging to it will have a null category value. Are you sure you want to delete this category?',
            style: TextStyle(
              fontSize: 18,
              color: light20,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: CustomButton(
                    text: "No",
                    backgroundColor: purple20,
                    textColor: purple100,
                    onPressed: onCancel, // Use the onCancel callback
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: CustomButton(
                    text: "Yes",
                    backgroundColor: purple100,
                    textColor: light80,
                    onPressed: () async {
                      // Access CategoryProvider and delete the category
                      final categoryProvider =
                          Provider.of<CategoryProvider>(context, listen: false);
                      await categoryProvider.deleteCategory(categoryId);
                      Navigator.of(context)
                          .pop(true); // Close the popup and confirm deletion
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
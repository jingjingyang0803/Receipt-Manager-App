import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/category_provider.dart';

class CategorySelectPopup extends StatefulWidget {
  const CategorySelectPopup({super.key});

  @override
  CategorySelectPopupState createState() => CategorySelectPopupState();
}

class CategorySelectPopupState extends State<CategorySelectPopup> {
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Load categories when the popup opens
    Provider.of<CategoryProvider>(context, listen: false).loadUserCategories();
  }

  // Show dialog to add a new category
  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          // child: AddCategoryWidget(
          //   onCategoryAdded: () {
          //     Provider.of<CategoryProvider>(context, listen: false)
          //         .loadUserCategories(); // Reload categories
          //   },
          // ),
        );
      },
    );
  }

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
      child: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, _) {
          final userCategories = categoryProvider.categories;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                thickness: 3,
                color: purple40,
                endIndent: 165,
                indent: 165,
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: userCategories.length,
                  itemBuilder: (context, index) {
                    String categoryId = userCategories[index]['id'] ?? '';
                    String categoryName =
                        userCategories[index]['name']?.trim() ?? '';
                    bool isSelected = categoryId == selectedCategoryId;

                    return Container(
                      color: isSelected
                          ? Colors.lightBlue.withOpacity(0.2)
                          : null, // Highlight selected row
                      child: ListTile(
                        leading: Text(
                          userCategories[index]['icon'] ?? '',
                          style: TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          categoryName,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            selectedCategoryId = categoryId;
                          });
                          Navigator.pop(context, selectedCategoryId);
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

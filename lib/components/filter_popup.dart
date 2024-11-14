import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/category_provider.dart';
import 'custom_button.dart';

class FilterPopup extends StatefulWidget {
  const FilterPopup({super.key});

  @override
  FilterPopupState createState() => FilterPopupState();
}

class FilterPopupState extends State<FilterPopup> {
  String selectedFilter = 'Credit Card';
  String selectedSort = 'Newest';
  List<String> selectedCategoryIds = [];
  bool isCategorySelectionVisible =
      false; // To toggle category selection visibility

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final userCategories = categoryProvider.categories;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            thickness: 3,
            color: purple40,
            endIndent: 165,
            indent: 165,
          ),
          const SizedBox(height: 16),
          const Text(
            'Filter By',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children:
                ['Credit Card', 'Debit Card', 'Cash', 'Other'].map((filter) {
              return _buildFilterOption(filter, selectedFilter == filter);
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sort By',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['Highest', 'Lowest', 'Newest', 'Oldest'].map((sort) {
              return _buildFilterOption(sort, selectedSort == sort,
                  isSort: true);
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Category',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Choose Category',
                style: TextStyle(fontSize: 16),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isCategorySelectionVisible = !isCategorySelectionVisible;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      '${selectedCategoryIds.length} Selected',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      isCategorySelectionVisible
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isCategorySelectionVisible)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: userCategories.map((category) {
                  final categoryId = category['id'] ?? '';
                  final categoryName = category['name'] ?? 'Unknown';
                  final isSelected = selectedCategoryIds.contains(categoryId);

                  return CheckboxListTile(
                    title: Text(categoryName),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedCategoryIds.add(categoryId);
                        } else {
                          selectedCategoryIds.remove(categoryId);
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: CustomButton(
                    text: "Reset",
                    backgroundColor: purple20,
                    textColor: purple100,
                    onPressed: () {
                      setState(() {
                        selectedFilter = 'Credit Card';
                        selectedSort = 'Newest';
                        selectedCategoryIds.clear();
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: CustomButton(
                    text: "Apply",
                    backgroundColor: purple100,
                    textColor: light80,
                    onPressed: () {
                      // Implement apply filter logic
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String label, bool isSelected,
      {bool isSort = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSort) {
            selectedSort = label;
          } else {
            selectedFilter = label;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? purple100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

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
  String selectedSort = 'Highest';
  List<String> selectedCategoryIds = [];
  bool isCategoryExpanded = false; // To control category dropdown visibility

  @override
  void initState() {
    super.initState();
    // Initialize all categories as selected, including "Uncategorized"
    _selectAllCategories(); // Ensure all categories are selected by default
  }

  void _selectAllCategories() {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    // Add all category IDs and 'uncategorized' for null IDs to selectedCategoryIds
    selectedCategoryIds = categoryProvider.categories
        .map<String>((category) => category['id'] ?? 'invalid')
        .toList();
    selectedCategoryIds.add('null');
  }

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
          Wrap(
            spacing: 8,
            children: ['Credit Card', 'Debit Card', 'Cash', 'Other']
                .map((filter) =>
                    _buildFilterOption(filter, selectedFilter == filter))
                .toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sort By',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Highest', 'Lowest', 'Newest', 'Oldest']
                .map((sort) => _buildFilterOption(sort, selectedSort == sort,
                    isSort: true))
                .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Choose Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isCategoryExpanded = !isCategoryExpanded;
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
                      isCategoryExpanded
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      size: 24,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isCategoryExpanded)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...userCategories.map((category) {
                  final categoryId = category['id'] ?? 'invalid';
                  final categoryName = category['name'] ?? 'unknown';
                  final isSelected = selectedCategoryIds.contains(categoryId);
                  return _buildCategoryButton(
                    categoryName,
                    categoryId,
                    isSelected,
                  );
                }),
                // Add "Uncategorized" option if not already in the list
                if (!userCategories.any((category) => category['id'] == null))
                  _buildCategoryButton(
                    'Uncategorized',
                    'null',
                    selectedCategoryIds.contains('null'),
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
                    text: "Reset",
                    backgroundColor: purple20,
                    textColor: purple100,
                    onPressed: () {
                      setState(() {
                        selectedFilter = 'Credit Card';
                        selectedSort = 'Highest';
                        // Reset selectedCategoryIds to include all categories and "Uncategorized"
                        _selectAllCategories(); // Ensure all categories are re-selected on reset
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
                      // Apply filter action
                    },
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildCategoryButton(
      String categoryName, String categoryId, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedCategoryIds
                .remove(categoryId); // Deselect if already selected
          } else {
            selectedCategoryIds.add(categoryId); // Select if not selected
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? purple100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          categoryName,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

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
  List<String> selectedPaymentMethods = [
    'Credit Card',
    'Debit Card',
    'Cash',
    'Other'
  ];
  String selectedSort = 'Newest';
  List<String> selectedCategoryIds = [];
  bool isCategoryExpanded = false; // To control category dropdown visibility

  @override
  void initState() {
    super.initState();
    _selectAllCategories(); // Ensure all categories are selected by default
  }

  void _selectAllCategories() {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    selectedCategoryIds = categoryProvider.categories
        .map<String>((category) =>
            category['id'] ?? 'null') // Include "null" for Uncategorized
        .toList();
    if (!selectedCategoryIds.contains('null'))
      selectedCategoryIds.add('null'); // Add 'Uncategorized' if missing
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
          Divider(thickness: 3, color: purple40, endIndent: 165, indent: 165),
          const SizedBox(height: 16),
          const Text('Choose Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Credit Card', 'Debit Card', 'Cash', 'Other']
                .map((filter) => _buildFilterOption(
                      label: filter,
                      isSelected: selectedPaymentMethods.contains(filter),
                      onSelected: (isSelected) {
                        setState(() {
                          if (isSelected) {
                            selectedPaymentMethods.remove(filter);
                          } else {
                            selectedPaymentMethods.add(filter);
                          }
                        });
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          const Text('Sort By',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Highest', 'Lowest', 'Newest', 'Oldest']
                .map((sort) => _buildFilterOption(
                      label: sort,
                      isSelected: selectedSort == sort,
                      onSelected: (_) {
                        setState(() {
                          selectedSort = sort;
                        });
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Choose Category',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
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
                  final categoryId = category['id'] ?? 'null';
                  final categoryName = category['name'] ?? 'Unknown';
                  final isSelected = selectedCategoryIds.contains(categoryId);
                  return _buildFilterOption(
                    label: categoryName,
                    isSelected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedCategoryIds.remove(categoryId);
                        } else {
                          selectedCategoryIds.add(categoryId);
                        }
                      });
                    },
                  );
                }),
                if (!userCategories.any((category) => category['id'] == null))
                  _buildFilterOption(
                    label: 'Uncategorized',
                    isSelected: selectedCategoryIds.contains('null'),
                    onSelected: (isSelected) {
                      setState(() {
                        if (isSelected) {
                          selectedCategoryIds.remove('null');
                        } else {
                          selectedCategoryIds.add('null');
                        }
                      });
                    },
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
                        selectedPaymentMethods = [
                          'Credit Card',
                          'Debit Card',
                          'Cash',
                          'Other'
                        ];
                        selectedSort = 'Newest';
                        _selectAllCategories();
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
                      // Implement filter application logic here
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

  Widget _buildFilterOption({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return GestureDetector(
      onTap: () {
        onSelected(isSelected);
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
}

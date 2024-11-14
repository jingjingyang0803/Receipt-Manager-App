import 'package:flutter/material.dart';
import 'package:receipt_manager/constants/app_colors.dart';

class FilterPopup extends StatefulWidget {
  const FilterPopup({super.key});

  @override
  FilterPopupState createState() => FilterPopupState();
}

class FilterPopupState extends State<FilterPopup> {
  String selectedFilter = 'Expense';
  String selectedSort = 'Highest';
  int selectedCategories = 0;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            thickness: 3,
            color: purple40,
            endIndent: 165,
            indent: 165,
          ),
          const SizedBox(height: 8),
          const Text(
            'Filter Transaction',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  selectedFilter = 'Expense';
                  selectedSort = 'Highest';
                  selectedCategories = 0;
                });
              },
              child: Text(
                'Reset',
                style: TextStyle(color: purple100),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Filter By',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['Income', 'Expense', 'Transfer'].map((filter) {
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
                  // Implement category selection dialog here
                },
                child: Row(
                  children: [
                    Text(
                      '$selectedCategories Selected',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Apply filters
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: purple100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
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

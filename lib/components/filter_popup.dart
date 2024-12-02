import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receipt_manager/components/custom_divider.dart';

import '../constants/app_colors.dart';
import '../providers/category_provider.dart';
import 'custom_button.dart';
import 'custom_option_widget.dart';

class FilterPopup extends StatefulWidget {
  final String initialSortOption;
  final List<String> initialPaymentMethods;
  final List<String> initialCategories;
  final Function(String, List<String>, List<String>) onApply;

  const FilterPopup({
    super.key,
    required this.initialSortOption,
    required this.initialPaymentMethods,
    required this.initialCategories,
    required this.onApply,
  });

  @override
  FilterPopupState createState() => FilterPopupState();
}

class FilterPopupState extends State<FilterPopup> {
  late String selectedSort;
  late List<String> selectedPaymentMethods;
  late List<String> selectedCategoryIds;
  bool isCategoryExpanded = false;

  @override
  void initState() {
    super.initState();
    // Remove duplicates by converting to Set and back to List
    selectedSort = widget.initialSortOption;
    selectedPaymentMethods = widget.initialPaymentMethods.toSet().toList();
    selectedCategoryIds = widget.initialCategories.toSet().toList();

    debugPrint("Initialized Payment Methods: $selectedPaymentMethods");
    debugPrint("Initialized Categories: $selectedCategoryIds");
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
          const CustomDivider(),
          const SizedBox(height: 16),
          const Text('Sort By',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Highest', 'Lowest', 'Newest', 'Oldest']
                .map((sort) => CustomOptionWidget(
                      label: sort,
                      isSelected: selectedSort == sort,
                      onSelected: (_) {
                        setState(() {
                          selectedSort = sort;
                          debugPrint("Selected Sort Option: $selectedSort");
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
                  return CustomOptionWidget(
                    label: categoryName,
                    isSelected: selectedCategoryIds.contains(categoryId),
                    onSelected: (_) {
                      setState(() {
                        if (selectedCategoryIds.contains(categoryId)) {
                          // If already selected, remove it
                          selectedCategoryIds.remove(categoryId);
                          debugPrint("Removed Category: $categoryName");
                        } else {
                          // If not selected, add it
                          selectedCategoryIds.add(categoryId);
                          debugPrint("Added Category: $categoryName");
                        }
                      });
                      // Log the updated state
                      debugPrint("Updated Categories: $selectedCategoryIds");
                    },
                  );
                }),
                CustomOptionWidget(
                  label: 'Uncategorized',
                  isSelected: selectedCategoryIds.contains('null'),
                  onSelected: (_) {
                    setState(() {
                      if (selectedCategoryIds.contains('null')) {
                        selectedCategoryIds.remove('null');
                        debugPrint("Removed 'Uncategorized'");
                      } else {
                        selectedCategoryIds.add('null');
                        debugPrint("Added 'Uncategorized'");
                      }
                    });
                    // Log the updated state
                    debugPrint("Updated Categories: $selectedCategoryIds");
                  },
                ),
              ],
            ),
          const SizedBox(height: 8),
          const Text('Choose Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Credit Card', 'Debit Card', 'Cash', 'Others']
                .map((filter) => CustomOptionWidget(
                      label: filter,
                      isSelected: selectedPaymentMethods.contains(filter),
                      onSelected: (_) {
                        debugPrint(
                            "selectedPaymentMethods: $selectedPaymentMethods");
                        setState(() {
                          if (selectedPaymentMethods.contains(filter)) {
                            // If already selected, remove it
                            selectedPaymentMethods.remove(filter);
                            debugPrint("Removed Payment Method: $filter");
                          } else {
                            // If not selected, add it
                            selectedPaymentMethods.add(filter);
                            debugPrint("Added Payment Method: $filter");
                          }
                        });
                        // Log the updated state
                        debugPrint(
                            "Updated Payment Methods: $selectedPaymentMethods");
                      },
                    ))
                .toList(),
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
                        selectedSort = widget.initialSortOption;
                        selectedPaymentMethods =
                            List.from(widget.initialPaymentMethods);
                        selectedCategoryIds =
                            List.from(widget.initialCategories);
                        debugPrint("Reset filters to initial values");
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
                      widget.onApply(
                        selectedSort,
                        selectedPaymentMethods,
                        selectedCategoryIds,
                      );
                      debugPrint(
                          "Applying filter: SortOption: $selectedSort, PaymentMethods: $selectedPaymentMethods, Categories: $selectedCategoryIds");
                      Navigator.pop(context);
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
}

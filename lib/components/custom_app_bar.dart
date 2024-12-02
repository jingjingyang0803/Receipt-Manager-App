import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/date_range_container.dart';
import '../constants/app_colors.dart';
import '../logger.dart'; // Import the logger
import '../providers/category_provider.dart';
import '../providers/receipt_provider.dart';
import 'date_range_picker_popup.dart';
import 'filter_popup.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  CustomAppBarState createState() => CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomAppBarState extends State<CustomAppBar> {
  @override
  void initState() {
    super.initState();
    // Load user categories when the app bar is initialized
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    categoryProvider.loadUserCategories();
    logger.i('User categories loaded');
  }

  @override
  Widget build(BuildContext context) {
    final receiptProvider = Provider.of<ReceiptProvider>(context);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: light90,
      elevation: 0,
      centerTitle: true,
      actions: [
        // Date Range Picker Button
        DateRangeContainer(
          startDate:
              receiptProvider.startDate ?? DateTime(DateTime.now().year, 1, 1),
          endDate: receiptProvider.endDate ?? DateTime.now(),
          onCalendarPressed: () => _showCalendarFilterDialog(context),
        ),

        const SizedBox(width: 8),

        Container(
          decoration: BoxDecoration(
            border: Border.all(color: purple80), // Add border color
            borderRadius: BorderRadius.circular(8), // Rounded borders
          ),
          padding: EdgeInsets.all(0), // Add padding
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.start, // Align items at the start
            mainAxisSize: MainAxisSize
                .min, // Ensure Row takes only as much space as its children
            children: [
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  _openFilterPopup(context);
                },
                child: Icon(
                  Icons.sort,
                  color: purple80,
                  size: 24, // Adjust icon size as needed
                ),
              ),
              IconButton(
                icon: Icon(Icons.filter_alt_outlined, color: purple80),
                onPressed: () {
                  _openFilterPopup(context);
                },
                padding: EdgeInsets
                    .zero, // Remove internal padding from the IconButton
                constraints:
                    BoxConstraints(), // Ensure no additional constraints or space
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // Show Calendar Filter Dialog
  void _showCalendarFilterDialog(BuildContext context) {
    final receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return CalendarFilterWidget(
          initialStartDate:
              receiptProvider.startDate ?? DateTime(DateTime.now().year, 1, 1),
          initialEndDate: receiptProvider.endDate ?? DateTime.now(),
          onApply: (start, end) {
            logger.i('Applying date range filter: Start: $start, End: $end');
            receiptProvider.updateFilters(
              startDate: start,
              endDate: end,
              sortOption: receiptProvider.sortOption,
              paymentMethods: receiptProvider.selectedPaymentMethods,
              categoryIds: receiptProvider.selectedCategoryIds,
            );
          },
        );
      },
    );
  }

  // Open Filter Popup
  void _openFilterPopup(BuildContext context) {
    final receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return FilterPopup(
          initialSortOption: receiptProvider.sortOption,
          initialPaymentMethods: receiptProvider.selectedPaymentMethods,
          initialCategories: receiptProvider.selectedCategoryIds,
          onApply: (sortOption, paymentMethods, categories) {
            logger.i(
                'Applying filter: SortOption: $sortOption, PaymentMethods: $paymentMethods, Categories: $categories');
            receiptProvider.updateFilters(
              sortOption: sortOption,
              paymentMethods: paymentMethods,
              categoryIds: categories.toSet().toList(), // Avoid duplicates
              startDate: receiptProvider.startDate,
              endDate: receiptProvider.endDate,
            );
          },
        );
      },
    );
  }
}

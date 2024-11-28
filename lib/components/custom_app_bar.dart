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

        // Filter and Sort Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // Match background
            elevation: 0, // Flat style
            side: BorderSide(color: purple80), // Border style
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Match corners
            ),
            padding: EdgeInsets.symmetric(
                horizontal: 16, vertical: 8), // Match padding
            minimumSize: Size(
                0, 48), // Explicitly set height to match DateRangeContainer
          ),
          onPressed: () {
            _openFilterPopup(context);
          },
          icon: Icon(
            Icons.tune,
            color: purple80, // Match icon color
          ),
          label: Text(
            'Filter & Sort',
            style: TextStyle(
              color: purple80,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
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

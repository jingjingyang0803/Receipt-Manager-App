import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/date_range_container.dart';
import '../constants/app_colors.dart';
import '../logger.dart'; // Import the logger
import '../providers/receipt_provider.dart';
import 'date_roller_picker.dart';
import 'filter_popup.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

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

        // Filter Button
        IconButton(
          icon: const Icon(Icons.filter_list_rounded, color: Colors.black),
          onPressed: () => _openFilterPopup(context),
        ),
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

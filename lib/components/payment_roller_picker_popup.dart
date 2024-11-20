import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'custom_button.dart';
import 'custom_divider.dart';

class PaymentMethodPicker extends StatelessWidget {
  final String selectedPaymentMethod;
  final ValueChanged<String> onPaymentMethodSelected;

  const PaymentMethodPicker({
    super.key,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Define the list of payment methods
    final List<String> paymentMethods = [
      'Credit Card',
      'Debit Card',
      'Cash',
      'PayPal',
      'MobilePay',
      'Apple Pay',
      'Google Pay',
      'Bank Transfer',
      'Others',
    ];

    // Get the initial index
    int initialIndex = paymentMethods.indexOf(selectedPaymentMethod);
    if (initialIndex == -1) initialIndex = 0;

    // Track the selected payment method locally
    String currentSelectedMethod = paymentMethods[initialIndex];

    return Container(
      padding: EdgeInsets.all(16),
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomDivider(),
          SizedBox(height: 8),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: initialIndex,
                    ),
                    itemExtent: 32.0,
                    onSelectedItemChanged: (int index) {
                      currentSelectedMethod = paymentMethods[index];
                    },
                    children: paymentMethods
                        .map((method) => Center(
                              child: Text(
                                method,
                                style: TextStyle(color: Colors.black),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                SizedBox(height: 20),
                CustomButton(
                  text: "Confirm",
                  backgroundColor: purple100,
                  textColor: light80,
                  onPressed: () {
                    onPaymentMethodSelected(currentSelectedMethod);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

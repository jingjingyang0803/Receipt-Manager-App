import 'package:flutter/material.dart';

class ExpenseItem extends StatelessWidget {
  final IconData categoryIcon;
  final String categoryName;
  final String merchantName;
  final String amount;
  final String paymentMethod;

  const ExpenseItem({
    super.key,
    required this.categoryIcon,
    required this.categoryName,
    required this.merchantName,
    required this.amount,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Color(0xFFFCFCFC),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3), // Shadow position
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon with background
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade100, // Background color for the icon
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(categoryIcon, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 16),
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  merchantName,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Amount and time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: amount.startsWith('-') ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                paymentMethod,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

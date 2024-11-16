import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/budget_provider.dart';
import '../providers/receipt_provider.dart';

class SummaryPage extends StatefulWidget {
  static const String id = 'summary_page';

  const SummaryPage({super.key});

  @override
  SummaryPageState createState() => SummaryPageState();
}

class SummaryPageState extends State<SummaryPage> {
  DateTime selectedDate = DateTime(DateTime.now().year, DateTime.now().month);

  String currencySymbol = '€';

  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  final List<int> years =
      List<int>.generate(20, (index) => 2020 + index); // From 2020 to 2039

  @override
  void initState() {
    super.initState();
    // Load initial data when the screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final budgetProvider =
          Provider.of<BudgetProvider>(context, listen: false);
      final receiptProvider =
          Provider.of<ReceiptProvider>(context, listen: false);

      budgetProvider.loadUserBudgets();
      receiptProvider.updateFilters(
        sortOption: "Newest",
        categoryIds: budgetProvider.budgets
            .map((e) => e['categoryId'] as String)
            .toList(),
        startDate: DateTime(selectedDate.year, selectedDate.month, 1),
        endDate: DateTime(selectedDate.year, selectedDate.month + 1, 0),
        paymentMethods: receiptProvider.selectedPaymentMethods,
      );
      receiptProvider.groupByCategory();

      currencySymbol =
          receiptProvider.currencySymbol ?? '€'; // Fetch the symbol
    });
  }

  void _showMonthPicker() {
    int initialMonthIndex = selectedDate.month - 1;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        int tempSelectedMonth = initialMonthIndex + 1;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              child: CupertinoPicker(
                scrollController:
                    FixedExtentScrollController(initialItem: initialMonthIndex),
                itemExtent: 36.0,
                onSelectedItemChanged: (int index) {
                  tempSelectedMonth = index + 1;
                },
                children: months
                    .map((month) => Text(month, style: TextStyle(fontSize: 24)))
                    .toList(),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    selectedDate =
                        DateTime(selectedDate.year, tempSelectedMonth);
                  });
                  _loadDataForSelectedDate();
                  Navigator.pop(context);
                },
                child: Text('DONE'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showYearPicker() {
    int initialYearIndex = years.indexOf(selectedDate.year);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        int tempSelectedYear = selectedDate.year;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              child: CupertinoPicker(
                scrollController:
                    FixedExtentScrollController(initialItem: initialYearIndex),
                itemExtent: 36.0,
                onSelectedItemChanged: (int index) {
                  tempSelectedYear = years[index];
                },
                children: years
                    .map((year) =>
                        Text(year.toString(), style: TextStyle(fontSize: 24)))
                    .toList(),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    selectedDate =
                        DateTime(tempSelectedYear, selectedDate.month);
                  });
                  _loadDataForSelectedDate();
                  Navigator.pop(context);
                },
                child: Text('DONE'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _loadDataForSelectedDate() {
    final receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);
    receiptProvider.updateFilters(
      sortOption: "Newest",
      startDate: DateTime(selectedDate.year, selectedDate.month, 1),
      endDate: DateTime(selectedDate.year, selectedDate.month + 1, 0),
      categoryIds: receiptProvider.selectedCategoryIds,
      paymentMethods: receiptProvider.selectedPaymentMethods,
    );
    receiptProvider.groupByCategory();
  }

  Color getColor(double ratio) {
    if (ratio < 0.75) return Colors.green;
    if (ratio < 1.0) return Color(0xFFF0C808); // Softer yellow
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final receiptProvider = Provider.of<ReceiptProvider>(context);

    final budgets = budgetProvider.budgets;
    final expenses = receiptProvider.groupedReceiptsByCategory ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Spending'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: [
          // Month and Year Picker
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Month Picker Button
                TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.lightBlue),
                    ),
                  ),
                  onPressed: _showMonthPicker,
                  child: Text(
                    DateFormat.MMMM().format(selectedDate),
                    style: TextStyle(fontSize: 16, color: Colors.lightBlue),
                  ),
                ),
                SizedBox(width: 16),
                // Year Picker Button
                TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.lightBlue),
                    ),
                  ),
                  onPressed: _showYearPicker,
                  child: Text(
                    selectedDate.year.toString(),
                    style: TextStyle(fontSize: 16, color: Colors.lightBlue),
                  ),
                ),
              ],
            ),
          ),
          // Budget and Expense List
          Expanded(
            child: ListView.builder(
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final budget = budgets[index];
                final categoryId = budget['categoryId'];
                final categoryName = budget['categoryName'];
                final categoryIcon = budget['categoryIcon'];
                final budgetAmount = budget['amount'];
                final spent = expenses[categoryId]?['total'] ?? 0.0;

                double ratio = budgetAmount == 0
                    ? (spent > 0 ? 1.0 : 0.0)
                    : spent / budgetAmount;
                String ratioText = budgetAmount == 0
                    ? (spent > 0 ? '∞%' : '0.0%')
                    : '${(ratio * 100).toStringAsFixed(1)}%';

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    leading: Container(
                      width: 8,
                      height: double.infinity,
                      color: getColor(ratio),
                    ),
                    title: Row(
                      children: [
                        Text(categoryIcon, style: TextStyle(fontSize: 26)),
                        SizedBox(width: 8),
                        Text(categoryName,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Budget:',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[700])),
                            Text(
                              '$currencySymbol ${budgetAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey[800]),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Spent:',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[700])),
                            Text(
                              '$currencySymbol ${spent.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 15,
                                color: getColor(ratio),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Percentage:',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[700])),
                            Text(
                              ratioText,
                              style: TextStyle(
                                fontSize: 15,
                                color: getColor(ratio),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

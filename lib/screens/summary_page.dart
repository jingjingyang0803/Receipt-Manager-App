import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../logger.dart';
import '../providers/budget_provider.dart';
import '../providers/receipt_provider.dart';

class SummaryPage extends StatefulWidget {
  static const String id = 'summary_page';

  const SummaryPage({super.key});

  @override
  SummaryPageState createState() => SummaryPageState();
}

class SummaryPageState extends State<SummaryPage> {
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;
  String _currencySymbolToDisplay = ' ';

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
      List<int>.generate(20, (index) => 2000 + index); // From 2020 to 2039

  @override
  void initState() {
    super.initState();
    // Load data when the widget is initialized
    Future.microtask(() {
      final budgetProvider =
          Provider.of<BudgetProvider>(context, listen: false);
      budgetProvider.loadUserBudgets();

      final receiptProvider =
          Provider.of<ReceiptProvider>(context, listen: false);
      receiptProvider.fetchAllReceipts();
      setState(() {
        _currencySymbolToDisplay = receiptProvider.currencySymbolToDisplay!;
      });

      receiptProvider.groupReceiptsByCategoryOneMonth(_month, _year);
      receiptProvider.calculateTotalSpending(
          receiptProvider.groupedReceiptsByCategoryOneMonth!);
    });
  }

  void _loadDataForSelectedDate() {
    final receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);

    logger.i("Loading data for Month: $_month, Year: $_year");

    receiptProvider.groupReceiptsByCategoryOneMonth(_month, _year);
    receiptProvider.calculateTotalSpending(
        receiptProvider.groupedReceiptsByCategoryOneMonth!);
  }

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        int tempSelectedMonth = _month;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              child: CupertinoPicker(
                scrollController:
                    FixedExtentScrollController(initialItem: _month - 1),
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
                    _month = tempSelectedMonth;
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
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        int tempSelectedYear = _year;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                    initialItem: years.indexOf(_year)),
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
                    _year = tempSelectedYear;
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

  Color getColor(double ratio) {
    if (ratio < 0.75) return Colors.green;
    if (ratio < 1.0) return Color(0xFFF0C808); // Softer yellow
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: light90,
      appBar: AppBar(
        title: Text('Monthly Summary', style: TextStyle(color: Colors.black)),
        backgroundColor: light90,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Consumer2<ReceiptProvider, BudgetProvider>(
        builder: (context, receiptProvider, budgetProvider, _) {
          final budgets = budgetProvider.budgets;
          final expenses = receiptProvider.groupedReceiptsByCategoryOneMonth;
          final totalSpending = receiptProvider.totalSpending;

          return Column(
            children: [
              Divider(
                color: Colors.grey.shade300,
                thickness: 1,
                height: 1,
              ),
              // Month and Year Picker
              Container(
                color: light90,
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: purple60),
                        ),
                      ),
                      onPressed: _showMonthPicker,
                      child: Text(
                        months[_month - 1],
                        style: TextStyle(fontSize: 16, color: purple60),
                      ),
                    ),
                    SizedBox(width: 16),
                    TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: purple60),
                        ),
                      ),
                      onPressed: _showYearPicker,
                      child: Text(
                        _year.toString(),
                        style: TextStyle(fontSize: 16, color: purple60),
                      ),
                    ),
                  ],
                ),
              ),
              // Display total spending
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total Spending: ',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$_currencySymbolToDisplay ${totalSpending.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Note: Total includes uncategorized expenses.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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

                    final spent = expenses![categoryId]?['total'] ?? 0.0;

                    double ratio = budgetAmount == 0
                        ? (spent > 0 ? 1.0 : 0.0)
                        : spent / budgetAmount;
                    String ratioText = budgetAmount == 0
                        ? (spent > 0 ? '∞%' : '0.0%')
                        : '${(ratio * 100).toStringAsFixed(1)}%';

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
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
                                  '$_currencySymbolToDisplay ${budgetAmount.toStringAsFixed(2)}',
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
                                  '$_currencySymbolToDisplay ${spent.toStringAsFixed(2)}',
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
          );
        },
      ),
    );
  }
}

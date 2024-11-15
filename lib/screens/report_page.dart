import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/date_range_container.dart';
import '../../logger.dart'; // Import your logger
import '../../providers/receipt_provider.dart';

class ReportPage extends StatefulWidget {
  static const String id = 'report_page';

  const ReportPage({super.key});

  @override
  ReportPageState createState() => ReportPageState();
}

class ReportPageState extends State<ReportPage> {
  @override
  void initState() {
    super.initState();
    final receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);

    logger.i("Initializing ReportPage...");
    logger.i("Fetching receipt count, dates, and grouped receipts.");

    // Fetch initial data
    receiptProvider.loadReceiptCount();
    receiptProvider.loadOldestAndNewestDates();
    receiptProvider
        .fetchDailyGroupedReceipts(
      DateTime(DateTime.now().year, 1, 1), // Start date: first day of the year
      DateTime.now(), // End date: today
    )
        .then((_) {
      logger.i("Fetched daily grouped receipts successfully.");
    }).catchError((error) {
      logger.e("Error fetching daily grouped receipts: $error");
    });
  }

  Widget buildPieChart(Map<String, double> groupedReceiptsByCategory) {
    logger.i(
        "Building PieChart. GroupedReceiptsByCategory: $groupedReceiptsByCategory");
    if (groupedReceiptsByCategory.isEmpty) {
      logger.i("No data available for PieChart.");
      return Center(child: Text('No data available.'));
    }

    return PieChart(
      PieChartData(
        sections: groupedReceiptsByCategory.entries.map((entry) {
          return PieChartSectionData(
            color:
                Colors.primaries[entry.key.hashCode % Colors.primaries.length],
            value: entry.value,
            title: '',
            radius: 70,
          );
        }).toList(),
        centerSpaceRadius: 60,
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget buildBarChart(Map<String, double> groupedReceiptsByInterval) {
    logger.i(
        "Building BarChart. GroupedReceiptsByInterval: $groupedReceiptsByInterval");
    if (groupedReceiptsByInterval.isEmpty) {
      logger.i("No data available for BarChart.");
      return Center(child: Text('No data available.'));
    }

    return BarChart(
      BarChartData(
        barGroups: groupedReceiptsByInterval.entries.map((entry) {
          return BarChartGroupData(
            x: entry.key.hashCode,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: Colors
                    .primaries[entry.key.hashCode % Colors.primaries.length],
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(show: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receiptProvider = Provider.of<ReceiptProvider>(context);

    logger.i("Building ReportPage...");
    logger.i(
        "ReceiptProvider state: ReceiptSnapshot: ${receiptProvider.receiptsSnapshot}, "
        "GroupedReceiptsByCategory: ${receiptProvider.groupedReceiptsByCategory}, "
        "GroupedReceiptsByInterval: ${receiptProvider.groupedReceiptsByInterval}");

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Graphs'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: receiptProvider.receiptsSnapshot == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DateRangeContainer(
                          startDate: receiptProvider
                                  .oldestAndNewestDates?['startDate'] ??
                              DateTime.now(),
                          endDate: receiptProvider
                                  .oldestAndNewestDates?['endDate'] ??
                              DateTime.now(),
                          onCalendarPressed: () async {
                            logger.i("Date range container clicked.");
                            // Open calendar filter dialog
                          },
                        ),
                        TextButton(
                          onPressed: () {
                            logger.i("Currency picker button clicked.");
                            // Show currency picker
                          },
                          child: Text(
                              receiptProvider.groupedReceiptsByCategory != null
                                  ? 'EUR'
                                  : ''),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Expenses by Category',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 10),
                    buildPieChart(
                        receiptProvider.groupedReceiptsByCategory ?? {}),
                    SizedBox(height: 20),
                    Text(
                      'Expenses by Interval',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 10),
                    buildBarChart(
                        receiptProvider.groupedReceiptsByInterval ?? {}),
                  ],
                ),
              ),
            ),
    );
  }
}

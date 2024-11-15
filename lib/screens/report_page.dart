import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/date_range_container.dart';
import '../../logger.dart';
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
    logger.i("Fetching initial data.");

    // Set default date range to the current year
    final startDate = DateTime(DateTime.now().year, 1, 1);
    final endDate = DateTime.now();

    receiptProvider.updateFilters(
      sortOption: 'Newest',
      paymentMethods: receiptProvider.selectedPaymentMethods,
      categoryIds: receiptProvider.selectedCategoryIds,
      startDate: startDate,
      endDate: endDate,
    );

    // Fetch initial receipts and grouping
    receiptProvider.fetchReceipts();
    receiptProvider.groupByCategory();
    receiptProvider.groupByDate();
  }

  Widget buildPieChart(Map<String, double>? groupedReceiptsByCategory) {
    if (groupedReceiptsByCategory == null ||
        groupedReceiptsByCategory.isEmpty) {
      return const Center(child: Text('No data available.'));
    }

    return SizedBox(
      height: 200, // Set a fixed height for the chart
      child: PieChart(
        PieChartData(
          sections: groupedReceiptsByCategory.entries.map((entry) {
            return PieChartSectionData(
              color: Colors
                  .primaries[entry.key.hashCode % Colors.primaries.length],
              value: entry.value,
              title: '${entry.value.toStringAsFixed(2)}',
              radius: 70,
            );
          }).toList(),
          centerSpaceRadius: 60,
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget buildBarChart(Map<String, double>? groupedReceiptsByInterval) {
    if (groupedReceiptsByInterval == null ||
        groupedReceiptsByInterval.isEmpty) {
      return const Center(child: Text('No data available.'));
    }

    return SizedBox(
      height: 300, // Set a fixed height for the bar chart
      child: BarChart(
        BarChartData(
          barGroups: groupedReceiptsByInterval.entries.map((entry) {
            return BarChartGroupData(
              x: groupedReceiptsByInterval.keys.toList().indexOf(entry.key),
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: Colors
                      .primaries[entry.key.hashCode % Colors.primaries.length],
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toString(),
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < groupedReceiptsByInterval.keys.length) {
                    final dateKey = groupedReceiptsByInterval.keys
                        .elementAt(index)
                        .substring(0, 10); // Show short date
                    return Text(
                      dateKey,
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receiptProvider = Provider.of<ReceiptProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Graphs'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: receiptProvider.allReceipts.isEmpty
          ? const Center(child: CircularProgressIndicator())
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
                          startDate: receiptProvider.startDate ??
                              DateTime(DateTime.now().year, 1, 1),
                          endDate: receiptProvider.endDate ?? DateTime.now(),
                          onCalendarPressed: () async {
                            final pickedDates = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                              initialDateRange: DateTimeRange(
                                start: receiptProvider.startDate ??
                                    DateTime(DateTime.now().year, 1, 1),
                                end: receiptProvider.endDate ?? DateTime.now(),
                              ),
                            );

                            if (pickedDates != null) {
                              receiptProvider.updateFilters(
                                sortOption: receiptProvider.sortOption,
                                paymentMethods:
                                    receiptProvider.selectedPaymentMethods,
                                categoryIds:
                                    receiptProvider.selectedCategoryIds,
                                startDate: pickedDates.start,
                                endDate: pickedDates.end,
                              );
                              receiptProvider.fetchReceipts();
                              receiptProvider.groupByCategory();
                              receiptProvider.groupByDate();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Expenses by Category',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    buildPieChart(receiptProvider.groupedReceiptsByCategory),
                    const SizedBox(height: 20),
                    Text(
                      'Expenses by Interval',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    buildBarChart(receiptProvider.groupedReceiptsByDate),
                  ],
                ),
              ),
            ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logger.dart';
import '../../providers/receipt_provider.dart';
import '../components/custom_app_bar.dart';
import '../constants/app_colors.dart';

class ReportPage extends StatefulWidget {
  static const String id = 'report_page';

  const ReportPage({super.key});

  @override
  ReportPageState createState() => ReportPageState();
}

class ReportPageState extends State<ReportPage> {
  final List<Color> availableColors = [
    Color(0xFF42A5F5), // Soft Blue
    Color(0xFF66BB6A), // Soft Green
    Color(0xFFEF5350), // Soft Red
    Color(0xFFFFCA28), // Soft Yellow
    Color(0xFFAB47BC), // Soft Purple
    Color(0xFFFF7043), // Soft Orange
    Color(0xFF26C6DA), // Soft Cyan
    Color(0xFF8D6E63), // Soft Brown
  ];
  Map<String, Color> categoryColors = {};

  TimeInterval selectedInterval =
      TimeInterval.day; // Default time interval (day)

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

    // Generate colors for each category
    categoryColors = generateTemporaryColorMapping(
      receiptProvider.groupedReceiptsByCategory?.keys.toList() ?? [],
    );
  }

  // Generate a unique color mapping for categories
  Map<String, Color> generateTemporaryColorMapping(List<String> categoryIds) {
    Map<String, Color> tempColors = {};
    int colorIndex = 0;

    for (var categoryId in categoryIds) {
      tempColors[categoryId] =
          availableColors[colorIndex % availableColors.length];
      colorIndex++;
    }

    return tempColors;
  }

  List<PieChartSectionData> getPieSections(
      Map<String, double>? groupedReceiptsByCategory) {
    return groupedReceiptsByCategory!.entries.map((entry) {
      final categoryId = entry.key;
      final total = entry.value;

      return PieChartSectionData(
        color: categoryColors[categoryId] ?? Colors.grey,
        value: total,
        title: '', // Set the title to empty
        radius: 70,
        titleStyle:
            TextStyle(fontSize: 0), // Set title style font size to 0 to hide it
      );
    }).toList();
  }

// Method to build the pie chart
  Widget buildPieChart(BuildContext context) {
    final receiptProvider = Provider.of<ReceiptProvider>(context);

    // Ensure data is grouped before building the chart
    receiptProvider.groupByCategory();

    final groupedReceipts = receiptProvider.groupedReceiptsByCategory ?? {};

    if (groupedReceipts.isEmpty) {
      return const Center(child: Text('No data available.'));
    }

    final totalAmount = groupedReceipts.values.fold(
      0.0,
      (sum, item) => sum + (item['total'] as double? ?? 0.0),
    );

    return Column(
      children: [
        SizedBox(
          height: 300, // Fixed height for the pie chart
          child: PieChart(
            PieChartData(
              sections: groupedReceipts.entries.map((entry) {
                final categoryId = entry.key;
                final total = entry.value['total'] as double? ??
                    0.0; // Access the total field
                final percentage = (total / totalAmount) * 100;

                return PieChartSectionData(
                  color: categoryColors[categoryId] ??
                      Colors.grey, // Use grey if no color
                  value: total,
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: 70,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
              centerSpaceRadius: 60,
              borderData: FlBorderData(show: false),
              sectionsSpace: 0,
              startDegreeOffset: -90,
            ),
          ),
        ),
        const SizedBox(height: 20), // Space between chart and legend
        Wrap(
          spacing: 10,
          children: groupedReceipts.entries.map((entry) {
            final categoryId = entry.key;
            final categoryData = entry.value;

            // Extract total, name, and icon from the category data
            final total = categoryData['total'] as double? ?? 0.0;
            final percentage = (total / totalAmount) * 100;

            final categoryName = categoryData['name'] ?? 'Uncategorized';
            final categoryIcon = categoryData['icon'] ?? '❓';

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: categoryColors[entry.key],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        '$categoryIcon $categoryName: ${total.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<BarChartGroupData> getBarChartGroups(BuildContext context) {
    final receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);
    final groupedReceipts = receiptProvider.groupedReceiptsByInterval ?? {};

    return groupedReceipts.entries.map((entry) {
      final index = groupedReceipts.keys.toList().indexOf(entry.key);
      final total = entry.value;

      // Cycle through available colors for each bar
      final color = availableColors[index % availableColors.length];

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: total,
            color: color,
            width: 22,
            borderRadius: BorderRadius.circular(1),
            // Add a label for the value above the bar
            rodStackItems: [
              BarChartRodStackItem(0, total, color),
            ],
          ),
        ],
        // Show tooltip or indicator with value above the bar
        showingTooltipIndicators: [0],
      );
    }).toList();
  }

  Widget buildBarChart(BuildContext context, TimeInterval interval) {
    final receiptProvider = Provider.of<ReceiptProvider>(context);

    // Ensure data is grouped by interval before building the chart
    receiptProvider.groupByInterval(interval);

    final groupedReceipts = receiptProvider.groupedReceiptsByInterval ?? {};

    if (groupedReceipts.isEmpty) {
      return const Center(child: Text('No data available.'));
    }

    final chartWidth = groupedReceipts.length * 100.0;
    final maxY = groupedReceipts.values
            .fold(0.0, (prev, next) => prev > next ? prev : next) *
        1.1;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 350, // Set the minimum width
          maxWidth: double.infinity, // You can set the maximum width as needed
        ),
        child: SizedBox(
          width: chartWidth,
          height: 300,
          child: BarChart(BarChartData(
            maxY: maxY, // Set maxY based on calculated max value
            alignment: BarChartAlignment.spaceEvenly,
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false, // Hide the top axis titles
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    // Display the interval (day, week, month, or year) as the title

                    final key = groupedReceipts.keys.elementAt(value.toInt());
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        key, // Display the grouped interval as the label
                        style: TextStyle(fontSize: 12),
                      ),
                    );
                  },
                  reservedSize: 42,
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false, // Hide the left axis values
                ),
              ),
            ),

            barGroups: getBarChartGroups(context),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    rod.toY.toStringAsFixed(1), // Format the value displayed
                    const TextStyle(
                      color: Colors.black, // Tooltip text color
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  );
                },
                getTooltipColor: (group) =>
                    Colors.transparent, // Set background color
                tooltipPadding:
                    const EdgeInsets.all(0), // Padding inside the tooltip
                tooltipMargin: 0, // Margin from the bar
              ),
            ),
          )),
        ),
      ),
    );
  }

// Method to build a customizable card with dynamic content
  Widget buildCard({
    required BuildContext context,
    required String title,
    required Widget content, // Dynamic content to display inside the card
    double elevation = 4, // Card elevation
    EdgeInsets padding = const EdgeInsets.all(10.0), // Padding inside the card
    double borderRadius = 10.0, // Border radius
  }) {
    return Card(
      color: Colors.white, // Set the background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius), // Rounded corners
      ),
      elevation: elevation, // Shadow effect
      child: Padding(
        padding: padding, // Add customizable padding inside the card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16), // Space between title and content
            content, // Display dynamic content (e.g., chart, text, etc.)
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return GestureDetector(
      onTap: () {
        onSelected(!isSelected);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receiptProvider = Provider.of<ReceiptProvider>(context);

    return Scaffold(
      backgroundColor: light90,
      appBar: CustomAppBar(),
      body: receiptProvider.allReceipts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    buildCard(
                      context: context,
                      title: 'Expenses by Category',
                      content: buildPieChart(context),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Wrap(
                        spacing: 8,
                        children: ['Day', 'Week', 'Month', 'Year']
                            .map((interval) => _buildFilterOption(
                                  label: interval,
                                  isSelected: selectedInterval.name ==
                                      interval.toLowerCase(),
                                  onSelected: (_) {
                                    setState(() {
                                      selectedInterval = TimeInterval.values
                                          .firstWhere((e) =>
                                              e.name.toLowerCase() ==
                                              interval.toLowerCase());
                                      debugPrint(
                                          "Selected Interval: ${selectedInterval.name}");
                                    });
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildCard(
                      context: context,
                      title: 'Expenses by Month',
                      content: buildBarChart(context, TimeInterval.month),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

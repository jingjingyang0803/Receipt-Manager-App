import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  String _currencySymbolToDisplay = ' ';

  TimeInterval selectedInterval =
      TimeInterval.day; // Default time interval (day)

  @override
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final receiptProvider =
          Provider.of<ReceiptProvider>(context, listen: false);

      receiptProvider.fetchAllReceipts();
      receiptProvider.applyFilters();
      receiptProvider.groupByCategory();
      receiptProvider.groupByInterval(selectedInterval);
      receiptProvider.groupByMonthAndCategory();

      if (mounted) {
        setState(() {
          _currencySymbolToDisplay = receiptProvider.currencySymbolToDisplay!;
          selectedInterval = receiptProvider.selectedInterval;
        });
      }
    });
  }

  List<PieChartSectionData> getPieSections(
      Map<String, Map<String, dynamic>> groupedReceiptsByCategory) {
    if (groupedReceiptsByCategory.isEmpty) return [];

    return groupedReceiptsByCategory.entries.map((entry) {
      final total = entry.value['total'] as double? ?? 0.0;
      final categoryColor =
          entry.value['categoryColor'] as Color? ?? Colors.grey.shade200;

      return PieChartSectionData(
        color: categoryColor,
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

    // Get the grouped receipts by category
    final groupedReceipts = receiptProvider.groupedReceiptsByCategory ?? {};

    // Debug print for grouped receipts
    logger.i(groupedReceipts);

    // Check if groupedReceipts is empty
    if (groupedReceipts.isEmpty) {
      return const Center(child: Text('No data available.'));
    }

    // Calculate the total amount
    final totalAmount = groupedReceipts.values.fold(
      0.0,
      (sum, item) => sum + (item['total'] as double? ?? 0.0), // Access 'total'
    );

    // Build the pie chart
    return Column(
      children: [
        SizedBox(
          height: 300, // Fixed height for the pie chart
          child: PieChart(
            PieChartData(
              sections: groupedReceipts.entries.map((entry) {
                // Extract fields for each category
                final total = entry.value['total'] as double? ?? 0.0;
                final percentage = (total / totalAmount) * 100;
                final categoryColor = entry.value['categoryColor'] as Color? ??
                    Colors.grey.shade200;

                return PieChartSectionData(
                  color: categoryColor, // Use grey if no color
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
          spacing: 8,
          runSpacing: 8,
          children: groupedReceipts.entries.map((entry) {
            final categoryData = entry.value;

            final total = categoryData['total'] as double? ?? 0.0;
            final percentage = (total / totalAmount) * 100;

            final categoryName =
                categoryData['categoryName'] ?? 'Uncategorized';
            final categoryIcon = categoryData['categoryIcon'] ?? '❓';
            final categoryColor =
                categoryData['categoryColor'] ?? Colors.grey.shade200;

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Icon with background color
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: categoryColor, // Background color
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              categoryIcon, // Use emoji/icon string
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(
                            width: 8), // Spacing between icon and text
                        // Category name and details
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              '$categoryName: $_currencySymbolToDisplay ${total.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
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
      final total = entry.value['total'];
      final color = Color(0xFF66BB6A);

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

    final groupedReceipts = receiptProvider.groupedReceiptsByInterval ?? {};

    if (groupedReceipts.isEmpty) {
      return const Center(child: Text('No data available.'));
    }

    final chartWidth = groupedReceipts.length * 100.0;
    final maxY = groupedReceipts.values
            .map((entry) =>
                entry['total'] as double) // Extract the 'total' field
            .fold(0.0, (prev, next) => prev > next ? prev : next) *
        1.1; // Find max and add 10%

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
                    '$_currencySymbolToDisplay ${rod.toY.toStringAsFixed(1)}', // Add the currency symbol
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

  List<LineChartBarData> getLineChartData(BuildContext context) {
    final receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);
    final groupedData = receiptProvider.groupedReceiptsByMonthAndCategory;

    if (groupedData == null || groupedData.isEmpty) {
      return [];
    }

    final Map<String, List<FlSpot>> categorySpots = {};
    final Map<String, Color> categoryColors = {};

    // Collect all category IDs
    final allCategoryIds =
        groupedData.values.expand((categories) => categories.keys).toSet();

    // Determine start and end date
    final allDates = groupedData.keys
        .map((key) =>
            DateTime.parse('$key-01')) // Convert `yyyy-MM` to valid date
        .toList();
    allDates.sort();
    final startDate = allDates.first;
    final endDate = allDates.last;

    // Generate continuous months for the entire interval
    final continuousMonths = List.generate(
      (endDate.year - startDate.year) * 12 +
          endDate.month -
          startDate.month +
          1, // Total months including start and end
      (index) => DateTime(startDate.year, startDate.month + index, 1),
    )
        .map((date) => DateFormat('yyyy-MM').format(date))
        .toList(); // Format as `yyyy-MM`

    // Initialize categoryColors
    for (var categories in groupedData.values) {
      for (var categoryId in categories.keys) {
        if (!categoryColors.containsKey(categoryId)) {
          final categoryData = categories[categoryId];
          categoryColors[categoryId] =
              categoryData?['categoryColor'] as Color? ?? Colors.grey;
        }
      }
    }

    // Populate categorySpots with data for all months
    for (var categoryId in allCategoryIds) {
      if (!categorySpots.containsKey(categoryId)) {
        categorySpots[categoryId] = [];
      }

      for (var month in continuousMonths) {
        final xValue = continuousMonths.indexOf(month).toDouble();
        final categories = groupedData[month] ?? {};
        final categoryData = categories[categoryId];
        final total = (categoryData?['total'] as double? ?? 0.0)
            .clamp(0.0, double.infinity); // Prevent negative values

        categorySpots[categoryId]!.add(
          FlSpot(xValue, total),
        );
      }
    }

    // Create LineChartBarData for each category
    return categorySpots.entries.map((entry) {
      final categoryId = entry.key;
      return LineChartBarData(
        spots: entry.value,
        isCurved: true,
        color: categoryColors[categoryId],
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      );
    }).toList();
  }

  List<Widget> getLegendItems(BuildContext context) {
    final receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);
    final groupedData = receiptProvider.groupedReceiptsByMonthAndCategory;

    if (groupedData == null || groupedData.isEmpty) {
      return [];
    }

    // Get unique category names and colors
    final Map<String, Color> categoryColors = {};
    for (var categories in groupedData.values) {
      categories.forEach((categoryId, categoryData) {
        final categoryName = categoryData['categoryName'] ?? 'Unknown';
        final categoryColor =
            categoryData['categoryColor'] as Color? ?? Colors.grey;
        if (!categoryColors.containsKey(categoryName)) {
          categoryColors[categoryName] = categoryColor;
        }
      });
    }

    // Generate legend widgets
    return categoryColors.entries.map((entry) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: entry.value,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 4),
          Text(entry.key, style: const TextStyle(fontSize: 12)),
        ],
      );
    }).toList();
  }

// Method to build the line chart
  Widget buildCategoryLineChart(BuildContext context) {
    final receiptProvider = Provider.of<ReceiptProvider>(context);
    final groupedData = receiptProvider.groupedReceiptsByMonthAndCategory;

    if (groupedData == null || groupedData.isEmpty) {
      return const Center(child: Text('No data available.'));
    }

    final lines = getLineChartData(context); // Get the line chart data

    // Determine start and end date for the interval
    // Determine start and end date from groupedData.keys
    final allDates = groupedData.keys
        .map((key) =>
            DateTime.parse('$key-01')) // Convert `yyyy-MM` to valid date
        .toList();
    allDates.sort();
    final startDate = allDates.first;
    final endDate = allDates.last;

// Generate all months between startDate and endDate
    final continuousMonths = List.generate(
      (endDate.year - startDate.year) * 12 +
          endDate.month -
          startDate.month +
          1, // Total months including start and end
      (index) => DateTime(startDate.year, startDate.month + index, 1),
    )
        .map((date) => DateFormat('yyyy-MM').format(date))
        .toList(); // Format as `yyyy-MM`

    return Column(
      children: [
        // Line chart widget
        SizedBox(
          height: 300,
          child: LineChart(LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true, // Show the left titles
                  reservedSize: 40, // Adjust this as needed for proper spacing
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true, // Show the right titles
                  reservedSize: 40, // Adjust this as needed for proper spacing
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false, // Hide the top titles
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < continuousMonths.length) {
                      final month = continuousMonths[index];
                      final date = DateTime.parse('$month-01');
                      return Text(
                        '${date.year}/${date.month.toString().padLeft(2, '0')}', // Format as YYYY/MM
                        style: const TextStyle(fontSize: 10),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  reservedSize: 32,
                ),
              ),
            ),
            lineBarsData: lines,
          )),
        ),
        const SizedBox(height: 20),

        // Legend
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: getLegendItems(context),
        ),
      ],
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
          color: isSelected ? purple100 : Colors.grey.shade200,
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
    return Scaffold(
      backgroundColor: light90,
      appBar: CustomAppBar(),
      body: Consumer<ReceiptProvider>(
        builder: (context, receiptProvider, child) {
          final chartType = receiptProvider.currentChartType;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Toggle Button for Charts
                  Row(
                    children: [
                      // Bar Chart Button
                      TextButton(
                        onPressed: () {
                          receiptProvider.setChartType(ChartType.pie);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: chartType == ChartType.pie
                              ? purple80
                              : Colors.white,
                          minimumSize: const Size(10, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                            side: BorderSide(
                              color: chartType == ChartType.pie
                                  ? Colors.transparent
                                  : light60,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Icon(
                          Icons.pie_chart,
                          color:
                              chartType == ChartType.pie ? light80 : purple100,
                        ),
                      ),

                      // Pie Chart Button
                      TextButton(
                        onPressed: () {
                          receiptProvider.setChartType(ChartType.bar);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: chartType == ChartType.bar
                              ? purple80
                              : Colors.white,
                          minimumSize: const Size(10, 50),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: chartType == ChartType.bar
                                  ? Colors.transparent
                                  : light60,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Icon(
                          Icons.bar_chart,
                          color:
                              chartType == ChartType.bar ? light80 : purple100,
                        ),
                      ),

                      // Line Chart Button
                      TextButton(
                        onPressed: () {
                          receiptProvider.setChartType(ChartType.line);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: chartType == ChartType.line
                              ? purple80
                              : Colors.white,
                          minimumSize: const Size(10, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                            side: BorderSide(
                              color: chartType == ChartType.line
                                  ? Colors.transparent
                                  : light60,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Icon(
                          Icons.show_chart, // Line chart icon
                          color:
                              chartType == ChartType.line ? light80 : purple100,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Render the interval options dynamically
                  if (chartType == ChartType.bar) ...[
                    const SizedBox(height: 20),
                    Center(
                      child: Wrap(
                        spacing: 8,
                        children: TimeInterval.values
                            .map((interval) => _buildFilterOption(
                                  label: interval.name.toUpperCase(),
                                  isSelected:
                                      receiptProvider.selectedInterval ==
                                          interval,
                                  onSelected: (_) {
                                    receiptProvider.updateInterval(interval);
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Render the chart
                  if (chartType == ChartType.pie)
                    buildCard(
                      context: context,
                      title: 'Expenses by Category',
                      content: buildPieChart(context),
                    )
                  else if (chartType == ChartType.line)
                    buildCard(
                      context: context,
                      title: 'Expenses Trend by Category',
                      content: buildCategoryLineChart(context),
                    )
                  else
                    buildCard(
                      context: context,
                      title:
                          'Expenses by ${receiptProvider.selectedInterval.name}',
                      content: buildBarChart(
                          context, receiptProvider.selectedInterval),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

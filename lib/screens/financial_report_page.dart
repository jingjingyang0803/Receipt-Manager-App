import 'package:flutter/material.dart';
import 'package:receipt_manager/constants/app_colors.dart';

class FinancialReportPage extends StatefulWidget {
  static const String id = 'financial_report_page';

  const FinancialReportPage({super.key});

  @override
  FinancialReportPageState createState() => FinancialReportPageState();
}

class FinancialReportPageState extends State<FinancialReportPage> {
  bool isPieChart = true; // Toggle state for chart

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: light90,
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Removes the default back arrowbackgroundColor: Colors.white,
        backgroundColor: light90,
        elevation: 0,
        title: const Text(
          'Report',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Month Button and Chart Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Month Button
                TextButton(
                  onPressed: () {
                    // Handle dropdown action here
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                      side: BorderSide(
                          color: light60, width: 1), // Subtle border color
                    ),
                    backgroundColor: Colors.white, // Light background color
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.expand_more, // Updated icon for dropdown arrow
                        color: purple100, // Use purple color for the arrow icon
                        size: 20, // Adjust size if necessary
                      ),
                      const SizedBox(width: 4), // Space between icon and text
                      Text(
                        "Month",
                        style: TextStyle(
                            fontSize: 14,
                            color: dark50,
                            fontWeight: FontWeight.w500), // Text style
                      ),
                    ],
                  ),
                ),
                // Toggle Button for Bar Chart and Pie Chart
                Row(
                  children: [
                    // Bar Chart Button with rounded left corners
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isPieChart = false;
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: isPieChart ? Colors.white : purple80,
                        minimumSize: const Size(
                            10, 50), // Adjust width and height if necessary
                        shape: RoundedRectangleBorder(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                          side: BorderSide(
                            color: isPieChart
                                ? light60
                                : Colors
                                    .transparent, // Border only when inactive
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Icon(
                        Icons.bar_chart, // Use preferred icon for bar chart
                        color: isPieChart ? purple80 : light60,
                      ),
                    ),
                    // Pie Chart Button with rounded right corners
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isPieChart = true;
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: isPieChart ? purple80 : Colors.white,
                        minimumSize: const Size(10, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          side: BorderSide(
                            color: isPieChart
                                ? Colors.transparent
                                : light60, // Border only when inactive
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Icon(
                        Icons.pie_chart,
                        color: isPieChart ? light80 : purple100,
                      ),
                    ),
                  ],
                )
              ],
            ),

            const SizedBox(height: 16),

            // Displayed Chart (Pie Chart or Bar Chart Placeholder)
            Expanded(
              child: Center(
                child: isPieChart
                    ? _buildPieChartPlaceholder()
                    : _buildBarChartPlaceholder(),
              ),
            ),

            // Expense and Income Toggle Buttons
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text("Expense",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                      ),
                      child:
                          Text("Income", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Category Dropdown and Filter Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Text("Category", style: TextStyle(color: Colors.black)),
                      Icon(Icons.arrow_drop_down, color: Colors.black),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.filter_alt_outlined,
                      color: Colors.grey.shade700),
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Expense List Items
            _buildExpenseItem(
              icon: Icons.shopping_bag,
              category: "Shopping",
              description: "Buy some grocery",
              amount: "- \$120",
              time: "10:00 AM",
              color: Colors.orange,
            ),
            _buildExpenseItem(
              icon: Icons.subscriptions,
              category: "Subscription",
              description: "Disney+ Annual",
              amount: "- \$80",
              time: "03:30 PM",
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder for Pie Chart
  Widget _buildPieChartPlaceholder() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [Colors.orange, Colors.purple, Colors.red],
          startAngle: 0.0,
          endAngle: 3.14 * 2,
        ),
      ),
      child: Center(
        child: Text(
          "\$332",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Placeholder for Bar Chart
  Widget _buildBarChartPlaceholder() {
    return Container(
      width: 150,
      height: 150,
      color: Colors.purple.shade100,
      child: Center(
        child: Text(
          "Bar Chart",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Expense Item Builder
  Widget _buildExpenseItem({
    required IconData icon,
    required String category,
    required String description,
    required String amount,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Icon with background
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),

          // Category, Description, and Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(description, style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          // Amount and Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: amount.startsWith('-') ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(time, style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

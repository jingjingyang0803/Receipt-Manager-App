import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: Text("Financial Report"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Month Dropdown and Chart Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Month Dropdown
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Text("Month", style: TextStyle(color: Colors.black)),
                      Icon(Icons.arrow_drop_down, color: Colors.black),
                    ],
                  ),
                ),

                // Toggle Button for Bar Chart and Pie Chart
                Container(
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.bar_chart),
                        color: isPieChart ? Colors.grey : Colors.purple,
                        onPressed: () {
                          setState(() {
                            isPieChart = false;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.pie_chart),
                        color: isPieChart ? Colors.purple : Colors.grey,
                        onPressed: () {
                          setState(() {
                            isPieChart = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
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

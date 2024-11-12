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
            // Toggle Button for Bar Chart and Pie Chart
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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

            // Chart (Pie Chart or Bar Chart)
            Expanded(
              child: Center(
                child: isPieChart
                    ? _buildPieChartPlaceholder()
                    : _buildBarChartPlaceholder(),
              ),
            ),

            // Expense and Income Toggle Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child:
                        Text("Expense", style: TextStyle(color: Colors.white)),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child:
                        Text("Income", style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
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
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/budget_provider.dart';

class BudgetPage extends StatefulWidget {
  static const String id = 'budget_page';

  const BudgetPage({super.key});

  @override
  BudgetPageState createState() => BudgetPageState();
}

class BudgetPageState extends State<BudgetPage> {
  late BudgetProvider budgetProvider;
  List<Map<String, dynamic>> updatedBudgets = []; // Local list to store changes

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
      budgetProvider.loadUserBudgets(); // Load budgets when the page is opened
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when tapping outside input fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Manage Budgets', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Column(
          children: [
            Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Consumer<BudgetProvider>(
                  builder: (context, budgetProvider, _) {
                    final budgets = budgetProvider.budgets;

                    // Initialize updatedBudgets when budgets are loaded
                    if (updatedBudgets.isEmpty) {
                      updatedBudgets =
                          budgets.map((budget) => {...budget}).toList();
                    }

                    return ListView.builder(
                      itemCount: updatedBudgets.length,
                      itemBuilder: (context, index) {
                        String categoryName =
                            updatedBudgets[index]['categoryName'] ?? '';
                        String categoryIcon =
                            updatedBudgets[index]['categoryIcon'] ?? '';
                        TextEditingController controller =
                            TextEditingController(
                          text: updatedBudgets[index]['amount']
                              .toStringAsFixed(2),
                        );

                        return ListTile(
                          leading: Text(categoryIcon,
                              style: TextStyle(fontSize: 24)),
                          title: Text(
                            categoryName,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          trailing: SizedBox(
                            width: 80,
                            child: TextFormField(
                              controller: controller,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: InputDecoration(
                                hintText: "0.00",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: purple100),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                              ),
                              onChanged: (value) {
                                updatedBudgets[index]['amount'] =
                                    double.tryParse(value) ?? 0.0;
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            FocusScope.of(context).unfocus(); // Dismiss the keyboard on save

            // Create a list with only categoryId and amount for saving
            List<Map<String, dynamic>> budgetsToSave =
                updatedBudgets.map((budget) {
              return {
                'categoryId': budget['categoryId'],
                'amount': budget['amount'],
              };
            }).toList();

            await budgetProvider.updateUserBudgets(budgetsToSave);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Budgets saved successfully")),
            );
          },
          backgroundColor: purple100,
          elevation: 6,
          child: Icon(Icons.save, color: Colors.white),
        ),
      ),
    );
  }
}

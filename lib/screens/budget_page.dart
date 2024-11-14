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

  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load budgets once the widget is added to the tree
      Provider.of<BudgetProvider>(context, listen: false).loadUserBudgets();
    });
  }

  void loadUserBudgets() {
    budgetProvider.loadUserBudgets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Budgets', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Divider(
            color: Colors.grey.shade300,
            thickness: 1,
            height: 1,
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Consumer<BudgetProvider>(
                builder: (context, budgetProvider, _) {
                  final budgets = budgetProvider.budgets;
                  print('budgets: $budgets');

                  return ListView.builder(
                    itemCount: budgets.length,
                    itemBuilder: (context, index) {
                      // Extract category info from budgets
                      String categoryName =
                          budgets[index]['categoryName'] ?? '';
                      String categoryIcon =
                          budgets[index]['categoryIcon'] ?? '';

                      // Controller for budget input
                      TextEditingController controller = TextEditingController(
                        text: budgets[index]['amount'].toStringAsFixed(2),
                      );

                      return ListTile(
                        leading: Text(
                          categoryIcon,
                          style: TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          categoryName,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        trailing: SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: controller,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
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
                              // Update the amount in the budgets list
                              budgets[index]['amount'] =
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
          // Save updated budgets via the provider
          await budgetProvider.updateUserBudgets(budgetProvider.budgets);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Budgets saved successfully")),
          );
        },
        backgroundColor: purple100,
        elevation: 6,
        child: Icon(Icons.save, color: Colors.white),
      ),
    );
  }
}

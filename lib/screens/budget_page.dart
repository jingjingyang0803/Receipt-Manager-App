import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/authentication_provider.dart';
import '../providers/budget_provider.dart';

class BudgetPage extends StatefulWidget {
  static const String id = 'budget_page';

  const BudgetPage({super.key});

  @override
  BudgetPageState createState() => BudgetPageState();
}

class BudgetPageState extends State<BudgetPage> {
  late AuthenticationProvider authProvider;
  late BudgetProvider budgetProvider;
  List<Map<String, dynamic>> updatedBudgets = []; // Local list to store changes

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authProvider =
          Provider.of<AuthenticationProvider>(context, listen: false);
      budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
      // Load budgets when the page is opened
      // Load categories for the user once at the beginning
      loadBudgetsForUser();
    });
  }

  void loadBudgetsForUser() {
    final userEmail = authProvider.user?.email;
    if (userEmail != null) {
      budgetProvider.loadUserBudgets();
    }
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
                      TextEditingController controller = TextEditingController(
                        text:
                            updatedBudgets[index]['amount'].toStringAsFixed(2),
                      );

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0), // Spacing between cards
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,// Slightly brighter box color for contrast
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200, // Subtle shadow for depth
                                blurRadius: 6, // Blurred shadow
                                offset: Offset(0, 2), // Light shadow offset
                              ),
                            ],
                          ),
                          child: SizedBox(
                            height: 55, // Adjusted height
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12), // Inner padding
                              child: Row(
                                children: [
                                  // Category Icon
                                  Text(categoryIcon, style: TextStyle(fontSize: 24)),
                                  const SizedBox(width: 12), // Space between icon and text
                                  // Category Name
                                  Expanded(
                                    child: Text(
                                      categoryName,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  // Amount Input
                                  SizedBox(
                                    width: 70,
                                    child: TextFormField(
                                      controller: controller,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                        hintText: "0.00",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: Colors.grey.shade400),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      ),
                                      onChanged: (value) {
                                        updatedBudgets[index]['amount'] =
                                            double.tryParse(value) ?? 0.0;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

          await Provider.of<BudgetProvider>(context, listen: false)
              .updateUserBudgets(budgetsToSave);
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

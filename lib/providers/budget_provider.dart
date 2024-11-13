import 'package:flutter/material.dart';

import '../services/budget_service.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetService _budgetService = BudgetService();
  List<Map<String, dynamic>> _budgets = [];
  Map<String, dynamic>? _budgetByCategory;

  List<Map<String, dynamic>> get budgets => _budgets;
  Map<String, dynamic>? get budgetByCategory => _budgetByCategory;

  // Fetch all budgets for a specific user
  Future<void> loadUserBudgets(String email) async {
    _budgets = await _budgetService.fetchUserBudgets(email);
    notifyListeners();
  }

  // Update budgets for a specific user
  Future<void> updateUserBudgets(
    String email,
    List<Map<String, dynamic>> budgetList,
  ) async {
    await _budgetService.updateUserBudgets(email, budgetList);
    await loadUserBudgets(email); // Refresh after updating
  }

  // Fetch budget by category ID for a specific user
  Future<void> loadBudgetByCategoryId(String email, String categoryId) async {
    _budgetByCategory =
        await _budgetService.fetchBudgetByCategoryId(email, categoryId);
    notifyListeners();
  }
}

import 'package:flutter/material.dart';

import '../services/budget_service.dart';
import 'authentication_provider.dart';
import 'category_provider.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetService _budgetService = BudgetService();
  AuthenticationProvider? _authProvider;
  CategoryProvider? _categoryProvider;

  List<Map<String, dynamic>> _budgets = [];
  Map<String, dynamic>? _budgetByCategory;

  // Getter for budgets with category information
  List<Map<String, dynamic>> get budgets {
    return _budgets.map((budget) {
      final categoryId = budget['categoryId'];
      final category = _categoryProvider?.categories.firstWhere(
        (cat) => cat['id'] == categoryId,
        orElse: () => {'name': 'Unknown', 'icon': '❓'},
      );
      return {
        ...budget,
        'categoryName': category?['name'] ?? 'Unknown',
        'categoryIcon': category?['icon'] ?? '❓',
      };
    }).toList();
  }

  Map<String, dynamic>? get budgetByCategory => _budgetByCategory;

  // Setters for AuthenticationProvider and CategoryProvider
  set authProvider(AuthenticationProvider authProvider) {
    _authProvider = authProvider;
    notifyListeners();
  }

  set categoryProvider(CategoryProvider categoryProvider) {
    _categoryProvider = categoryProvider;
    updateCategories(); // Update categories whenever CategoryProvider changes
  }

  // Helper to get user email from AuthenticationProvider
  String? get _userEmail => _authProvider?.user?.email;

  // Fetch all budgets for the current user
  Future<void> loadUserBudgets() async {
    if (_userEmail != null && _categoryProvider != null) {
      if (_categoryProvider!.categories.isEmpty) {
        await _categoryProvider!.loadUserCategories();
      }

      // Fetch existing budgets from Firestore
      List<Map<String, dynamic>> existingBudgets =
          await _budgetService.fetchUserBudgets(_userEmail!);

      List<Map<String, dynamic>> categories = _categoryProvider!.categories;

      // If the fetched budget is empty, create a default list in Firestore
      if (existingBudgets.isEmpty) {
        existingBudgets = categories.map((category) {
          return {
            'categoryId': category['id'],
            'amount': 0.0,
            'period': 'monthly',
          };
        }).toList();

        // Save the default budget list to Firestore
        await _budgetService.updateUserBudgets(_userEmail!, existingBudgets);
      }

      _budgets = categories.map((category) {
        Map<String, dynamic>? existingBudget = existingBudgets.firstWhere(
          (budget) => budget['categoryId'] == category['id'],
          orElse: () => {'amount': 0.0, 'period': 'monthly'},
        );

        return {
          'categoryId': category['id'],
          'categoryName': category['name'],
          'categoryIcon': category['icon'],
          'amount': existingBudget['amount'] ?? 0.0,
          'period': existingBudget['period'] ?? 'monthly',
        };
      }).toList();

      notifyListeners();
    }
  }

  // Method to update budgets based on updated categories from CategoryProvider
  void updateCategories() {
    if (_categoryProvider != null) {
      List<Map<String, dynamic>> categories = _categoryProvider!.categories;

      // Update _budgets to align with the new categories
      _budgets = categories.map((category) {
        Map<String, dynamic>? existingBudget = _budgets.firstWhere(
          (budget) => budget['categoryId'] == category['id'],
          orElse: () => {'amount': 0.0, 'period': 'monthly'},
        );

        return {
          'categoryId': category['id'],
          'categoryName': category['name'],
          'categoryIcon': category['icon'],
          'amount': existingBudget['amount'] ?? 0.0,
          'period': existingBudget['period'] ?? 'monthly',
        };
      }).toList();

      notifyListeners();
    }
  }

  // Update budgets for the current user
  Future<void> updateUserBudgets(List<Map<String, dynamic>> budgetList) async {
    if (_userEmail != null) {
      await _budgetService.updateUserBudgets(_userEmail!, budgetList);
      await loadUserBudgets(); // Refresh after updating
    }
  }

  // Fetch budget by category ID for the current user
  Future<void> loadBudgetByCategoryId(String categoryId) async {
    if (_userEmail != null) {
      _budgetByCategory =
          await _budgetService.fetchBudgetByCategoryId(_userEmail!, categoryId);
      notifyListeners();
    }
  }
}

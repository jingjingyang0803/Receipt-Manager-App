import 'package:flutter/material.dart';

import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<Map<String, dynamic>> _categories = [];
  Map<String, dynamic>? _categoryDetails;

  List<Map<String, dynamic>> get categories => _categories;
  Map<String, dynamic>? get categoryDetails => _categoryDetails;

  // Fetch all categories for a specific user
  Future<void> loadUserCategories(String email) async {
    _categories = await _categoryService.fetchUserCategories(email);
    notifyListeners();
  }

  // Add a new category for a specific user
  Future<void> addCategory(String email, String name, String icon) async {
    await _categoryService.addCategoryToFirestore(email, name, icon);
    await loadUserCategories(email); // Reload categories after adding
  }

  // Delete a category for a specific user
  Future<void> deleteCategory(String email, String categoryId) async {
    await _categoryService.deleteCategory(email, categoryId);
    await loadUserCategories(email); // Reload categories after deleting
  }

  // Check if a category exists for a specific user
  Future<bool> checkIfCategoryExists(String email, String categoryName) async {
    return await _categoryService.categoryExists(email, categoryName);
  }

  // Fetch category name by ID for a specific user
  Future<void> loadCategoryNameById(String email, String categoryId) async {
    _categoryDetails = {
      'name': await _categoryService.fetchCategoryNameById(email, categoryId)
    };
    notifyListeners();
  }

  // Fetch category icon by ID for a specific user
  Future<void> loadCategoryIconById(String email, String categoryId) async {
    _categoryDetails = {
      'icon': await _categoryService.fetchCategoryIconById(email, categoryId)
    };
    notifyListeners();
  }
}

import 'budget_service.dart';
import 'category_service.dart';
import 'receipt_service.dart';
import 'user_service.dart';

class ServiceManager {
  // Singleton pattern
  static final ServiceManager _instance = ServiceManager._internal();

  factory ServiceManager() => _instance;

  // Initialize each service instance
  final BudgetService budgetService = BudgetService();
  final UserService userService = UserService();
  final CategoryService categoryService = CategoryService();
  final ReceiptService receiptService = ReceiptService();

  ServiceManager._internal();
}

// Define a global instance
final services = ServiceManager();

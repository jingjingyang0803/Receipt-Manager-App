import 'budget_service.dart';
import 'category_service.dart';
import 'receipt_service.dart';
import 'user_service.dart';

class ServiceManager {
  // Singleton pattern for global access
  static final ServiceManager _instance = ServiceManager._internal();

  factory ServiceManager() => _instance;

  // Initialize each service instance
  final UserService userService = UserService();
  final CategoryService categoryService = CategoryService();
  final BudgetService budgetService = BudgetService();
  final ReceiptService receiptService = ReceiptService();

  ServiceManager._internal();
}

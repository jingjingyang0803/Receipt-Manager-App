import 'auth_service.dart';
import 'budget_service.dart';
import 'category_service.dart';
import 'receipt_service.dart';
import 'user_service.dart';

class ServiceManager {
  // Singleton pattern
  static final ServiceManager _instance = ServiceManager._internal();

  factory ServiceManager() => _instance;

  // Initialize each service instance
  final AuthService authService = AuthService();
  final UserService userService = UserService();
  final CategoryService categoryService = CategoryService();
  final BudgetService budgetService = BudgetService();
  final ReceiptService receiptService = ReceiptService();

  ServiceManager._internal();
}

// Define a global instance
final services = ServiceManager();

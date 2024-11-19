import 'package:cloud_firestore/cloud_firestore.dart';

import '../logger.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all budgets for a user
  Future<List<Map<String, dynamic>>> fetchUserBudgets(String email) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('budgets').doc(email).get();

      if (!userDoc.exists) {
        // Document does not exist, create it with default data
        await _firestore.collection('budgets').doc(email).set({
          'budgetlist': [],
        });
        logger.i("Default document created for email: $email");
        return [];
      }

      // Document exists, return the budget list
      var data = userDoc.data() as Map<String, dynamic>;
      List<dynamic> budgetList = data['budgetlist'] ?? [];

      return budgetList.map((budget) {
        return {
          'categoryId': budget['categoryId'] ?? '',
          'amount': budget['amount'] ?? 0.0,
          'period': budget['period'] ?? 'monthly',
        };
      }).toList();
    } catch (e) {
      logger.e("Error fetching user budgets: $e");
      return [];
    }
  }

  Future<void> updateUserBudgets(
      String email, List<Map<String, dynamic>> budgetList) async {
    try {
      await _firestore.collection('budgets').doc(email).set(
          {
            'budgetlist': budgetList,
          },
          SetOptions(
              merge:
                  true)); // Use `set` with merge to ensure creation if missing
    } catch (e) {
      logger.e("Error updating user budgets: $e");
      rethrow;
    }
  }
}

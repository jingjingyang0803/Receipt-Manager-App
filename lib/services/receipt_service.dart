import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;

enum TimeInterval { day, week, month, year }

class ReceiptService {
  // Fetch receipts for a specific user by email
  Stream<DocumentSnapshot<Map<String, dynamic>>> fetchReceipts(String email) {
    return _firestore
        .collection('receipts')
        .doc(email) // Use provided email for user identification
        .snapshots();
  }

  // Get the count of receipts for a specific user
  Future<int> getReceiptCount(String email) async {
    try {
      DocumentReference userDocRef =
          _firestore.collection('receipts').doc(email);

      DocumentSnapshot userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        return 0; // Return 0 if no document is found
      }

      // Get the receipt list from Firestore
      List<dynamic> receiptList = userDoc['receiptlist'] ?? [];
      return receiptList.length;
    } catch (e) {
      throw Exception('Failed to fetch receipt count: $e');
    }
  }

  // Add a new receipt for a specific user
  Future<void> addReceipt({
    required String email,
    required Map<String, dynamic> receiptData,
    required String paymentMethod,
  }) async {
    // Generate a unique ID for each receipt
    String receiptId =
        FirebaseFirestore.instance.collection('receipts').doc().id;

    // Add the receipt ID and payment method to the receipt data
    receiptData['id'] = receiptId;
    receiptData['paymentMethod'] = paymentMethod;

    DocumentReference userDocRef = _firestore.collection('receipts').doc(email);

    await userDocRef.set({
      'receiptlist': FieldValue.arrayUnion([receiptData])
    }, SetOptions(merge: true));
  }

  // Update an existing receipt for a specific user
  Future<void> updateReceipt({
    required String email,
    required String receiptId,
    required Map<String, dynamic> updatedData,
    String? paymentMethod,
  }) async {
    DocumentReference userDocRef = _firestore.collection('receipts').doc(email);

    DocumentSnapshot userDoc = await userDocRef.get();

    if (!userDoc.exists) {
      throw Exception('User document not found');
    }

    // Get the current receipt list
    List<dynamic> receiptList = userDoc['receiptlist'] ?? [];

    // Find the index of the receipt to update by its ID
    int receiptIndex =
        receiptList.indexWhere((receipt) => receipt['id'] == receiptId);

    if (receiptIndex != -1) {
      // Preserve the original ID and add/update the paymentMethod if provided
      updatedData['id'] = receiptId;
      if (paymentMethod != null) {
        updatedData['paymentMethod'] = paymentMethod;
      }

      // Replace the old receipt with the updated data
      receiptList[receiptIndex] = updatedData;

      // Update the receipt list in the document
      await userDocRef.update({'receiptlist': receiptList});
    } else {
      throw Exception('Receipt not found');
    }
  }

  // Delete a receipt for a specific user by its ID
  Future<void> deleteReceipt(String email, String receiptId) async {
    DocumentReference userDocRef = _firestore.collection('receipts').doc(email);

    // First, get the current receipt list
    DocumentSnapshot doc = await userDocRef.get();
    if (doc.exists) {
      List<dynamic> receiptList = doc['receiptlist'] ?? [];

      // Find the receipt and remove it
      receiptList.removeWhere((receipt) => receipt['id'] == receiptId);

      // Update the document with the new list
      await userDocRef.update({'receiptlist': receiptList});
    }
  }

  // Set categoryId to null for all receipts that match the given categoryId
  Future<void> setReceiptsCategoryToNull(
      String email, String categoryId) async {
    DocumentReference userDocRef = _firestore.collection('receipts').doc(email);

    // Fetch the user's receipts
    DocumentSnapshot doc = await userDocRef.get();
    if (doc.exists) {
      List<dynamic> receiptList = doc['receiptlist'] ?? [];

      // Iterate over the receipts and set categoryId to null for those with matching categoryId
      List<dynamic> updatedReceiptList = receiptList.map((receipt) {
        if (receipt['categoryId'] == categoryId) {
          receipt['categoryId'] = null; // Set the categoryId to null
        }
        return receipt;
      }).toList();

      // Update the Firestore document with the modified receipts
      await userDocRef.update({'receiptlist': updatedReceiptList});
    } else {
      throw Exception('No receipts found for the current user');
    }
  }

// Other methods remain the same, except now they use 'email' as a parameter.
}

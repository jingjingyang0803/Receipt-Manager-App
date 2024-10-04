import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firestore = FirebaseFirestore.instance;

class ReceiptService {
  User? loggedInUser;

  ReceiptService() {
    getCurrentUser();
  }

  void getCurrentUser() async {
    loggedInUser = FirebaseAuth.instance.currentUser;
  }

  // Fetch receipts for the current user
  Stream<DocumentSnapshot<Map<String, dynamic>>> fetchReceipts() {
    if (loggedInUser == null) {
      throw Exception('User not logged in');
    }

    return _firestore
        .collection('receipts')
        .doc(loggedInUser!.email) // Use email or uid for user identification
        .snapshots();
  }

  // Add a new receipt
  Future<void> addReceipt(Map<String, dynamic> receiptData) async {
    if (loggedInUser == null) {
      throw Exception('User not logged in');
    }

    // Get the user document by userId or email
    DocumentReference userDocRef =
        _firestore.collection('receipts').doc(loggedInUser!.email);

    await userDocRef.set({
      'receiptlist': FieldValue.arrayUnion([receiptData])
    }, SetOptions(merge: true));
  }

  // Delete a receipt by its index (assumes receipts are stored in an array)
  Future<void> deleteReceipt(String receiptId) async {
    if (loggedInUser == null) {
      throw Exception('User not logged in');
    }

    DocumentReference userDocRef =
        _firestore.collection('receipts').doc(loggedInUser!.email);

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
}
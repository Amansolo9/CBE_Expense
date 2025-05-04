import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchExpenses(String uid) async {
    print('Fetching expenses for UID: $uid');
    final snap =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('expenses')
            .orderBy('date', descending: true)
            .get();
    print('Raw Firestore query result: ${snap.docs.length} documents fetched');
    return snap.docs.map((d) => d.data()..['id'] = d.id).toList();
  }

  Future<void> addExpense({
    required String uid,
    required double amount,
    required DateTime date,
    String? category,
    String? description,
  }) async {
    await _firestore.collection('users').doc(uid).collection('expenses').add({
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'category': category,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> editExpense(
    String uid,
    String expenseId,
    Map<String, dynamic> updatedData,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .doc(expenseId)
        .update(updatedData);
  }

  Future<void> deleteExpense(String uid, String expenseId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }
}

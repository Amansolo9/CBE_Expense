import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchExpenses(String uid) async {
    final snap =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('expenses')
            .orderBy('date', descending: true)
            .get();
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
}

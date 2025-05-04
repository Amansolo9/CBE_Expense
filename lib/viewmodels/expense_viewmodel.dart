import 'package:flutter/material.dart';
import '../services/expense_service.dart';

class ExpenseViewModel extends ChangeNotifier {
  final ExpenseService _service;
  final String uid;
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> expenses = [];

  ExpenseViewModel({required this.uid, ExpenseService? service})
    : _service = service ?? ExpenseService();

  Future<void> fetchExpenses() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      expenses = await _service.fetchExpenses(uid);
    } catch (e) {
      error = 'Failed to load expenses: $e';
    }
    loading = false;
    notifyListeners();
  }

  Future<bool> addExpense({
    required double amount,
    required DateTime date,
    String? category,
    String? description,
  }) async {
    try {
      await _service.addExpense(
        uid: uid,
        amount: amount,
        date: date,
        category: category,
        description: description,
      );
      await fetchExpenses();
      return true;
    } catch (e) {
      error = 'Failed to add expense: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> editExpense(
    String expenseId,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      await _service.editExpense(uid, expenseId, updatedData);
      await fetchExpenses();
      return true;
    } catch (e) {
      error = 'Failed to edit expense: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExpense(String expenseId) async {
    try {
      await _service.deleteExpense(uid, expenseId);
      await fetchExpenses();
      return true;
    } catch (e) {
      error = 'Failed to delete expense: $e';
      notifyListeners();
      return false;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../widgets/dialogs.dart';

class ExpenseCard extends StatelessWidget {
  final Map<String, dynamic> expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExpenseCard({
    Key? key,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date =
        expense['date'] is DateTime
            ? expense['date']
            : (expense['date'] as Timestamp).toDate();

    return Padding(
      padding: const EdgeInsets.only(left: 32, top: 6, bottom: 6),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ETB ${expense['amount'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'LexendDeca',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFCD359C),
                      ),
                    ),
                    if (expense['category'] != null &&
                        (expense['category'] as String).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          expense['category'],
                          style: const TextStyle(
                            fontFamily: 'LexendDeca',
                            fontSize: 14,
                            color: Color(0xFFB29365),
                          ),
                        ),
                      ),
                    if (expense['description'] != null &&
                        (expense['description'] as String).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          expense['description'],
                          style: const TextStyle(
                            fontFamily: 'LexendDeca',
                            fontSize: 13,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(date),
                        style: const TextStyle(
                          fontFamily: 'LexendDeca',
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFFB29365)),
                    onPressed: () {
                      final vm = Provider.of<ExpenseViewModel>(
                        context,
                        listen: false,
                      );
                      showEditExpenseDialog(context, vm, expense);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFFCD359C)),
                    onPressed: () {
                      final vm = Provider.of<ExpenseViewModel>(
                        context,
                        listen: false,
                      );
                      showDeleteExpenseDialog(context, vm, expense['id']);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

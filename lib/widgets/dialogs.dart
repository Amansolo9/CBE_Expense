import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../viewmodels/expense_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void showEditExpenseDialog(
  BuildContext context,
  ExpenseViewModel vm,
  Map<String, dynamic> expense,
) {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController(
    text: expense['amount'].toString(),
  );
  DateTime selectedDate =
      expense['date'] is DateTime
          ? expense['date']
          : (expense['date'] as Timestamp).toDate();
  String? selectedCategory = expense['category'];
  String? customCategory;
  final descController = TextEditingController(text: expense['description']);
  bool showCustomCategory = selectedCategory == 'Other';
  bool isEditing = false;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Edit Expense',
              style: TextStyle(
                fontFamily: 'LexendDeca',
                fontWeight: FontWeight.bold,
                color: Color(0xFFCD359C),
              ),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        hintText: 'Enter amount (e.g., 25.50)',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Amount required';
                        final n = double.tryParse(v);
                        if (n == null || n <= 0)
                          return 'Enter a valid positive number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'Date:',
                          style: TextStyle(
                            fontFamily: 'LexendDeca',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null)
                                setState(() => selectedDate = picked);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFCD359C)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                DateFormat('yyyy-MM-dd').format(selectedDate),
                                style: const TextStyle(
                                  fontFamily: 'LexendDeca',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items:
                          [
                                'Food',
                                'Transport',
                                'Entertainment',
                                'Bills',
                                'Shopping',
                                'Other',
                              ]
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(
                                    cat,
                                    style: const TextStyle(
                                      fontFamily: 'LexendDeca',
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedCategory = val;
                          showCustomCategory = val == 'Other';
                        });
                      },
                    ),
                    if (showCustomCategory)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Custom Category',
                          ),
                          onChanged: (v) => customCategory = v,
                          validator: (v) {
                            if (showCustomCategory &&
                                (v == null || v.trim().isEmpty))
                              return 'Enter custom category';
                            return null;
                          },
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descController,
                      maxLength: 20,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Brief note about the expense',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'LexendDeca',
                    color: Color(0xFFCD359C),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCD359C),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontFamily: 'LexendDeca',
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  if (formKey.currentState?.validate() != true || isEditing)
                    return;
                  setState(() => isEditing = true);
                  final updatedData = {
                    'amount': double.parse(amountController.text),
                    'date': selectedDate,
                    'category':
                        showCustomCategory ? customCategory : selectedCategory,
                    'description': descController.text.trim(),
                  };
                  final success = await vm.editExpense(
                    expense['id'],
                    updatedData,
                  );
                  setState(() => isEditing = false);
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Center(
                          child: Text(
                            'Expense edited successfully!',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        backgroundColor: Color(0xFFCD359C),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Center(
                          child: Text(
                            'Failed to edit expense. Please try again.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        backgroundColor: const Color(0xFFCD359C),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child:
                    isEditing
                        ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFCD359C),
                          ),
                          backgroundColor: Colors.white,
                          strokeWidth: 3,
                        )
                        : const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}

void showDeleteExpenseDialog(
  BuildContext context,
  ExpenseViewModel vm,
  String expenseId,
) {
  bool isDeleting = false;
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Delete Expense',
              style: TextStyle(
                fontFamily: 'LexendDeca',
                fontWeight: FontWeight.bold,
                color: Color(0xFFCD359C),
              ),
            ),
            content: const Text(
              'Are you sure you want to delete this expense?',
              style: TextStyle(fontFamily: 'LexendDeca'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'LexendDeca',
                    color: Color(0xFFCD359C),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCD359C),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontFamily: 'LexendDeca',
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  if (isDeleting) return;
                  setState(() => isDeleting = true);
                  final success = await vm.deleteExpense(expenseId);
                  setState(() => isDeleting = false);
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Center(
                          child: Text(
                            'Expense deleted successfully!',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        backgroundColor: Color(0xFFCD359C),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Center(
                          child: Text(
                            'Failed to delete expense. Please try again.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        backgroundColor: const Color(0xFFCD359C),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child:
                    isDeleting
                        ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFCD359C),
                          ),
                          backgroundColor: Colors.white,
                          strokeWidth: 3,
                        )
                        : const Text('Delete'),
              ),
            ],
          );
        },
      );
    },
  );
}

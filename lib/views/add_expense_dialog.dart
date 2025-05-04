import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../viewmodels/expense_viewmodel.dart';

class AddExpenseDialog extends StatefulWidget {
  final ExpenseViewModel viewModel;

  const AddExpenseDialog({required this.viewModel, Key? key}) : super(key: key);

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final descController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String? selectedCategory;
  String? customCategory;
  bool showCustomCategory = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Add Expense',
        style: TextStyle(
          fontFamily: 'LexendDeca',
          fontWeight: FontWeight.bold,
          color: Color(0xFFCD359C),
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount (e.g., 25.50)',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Amount required';
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
                          style: const TextStyle(fontFamily: 'LexendDeca'),
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
                              style: const TextStyle(fontFamily: 'LexendDeca'),
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
                          (v == null || v.trim().isEmpty)) {
                        return 'Enter custom category';
                      }
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
          onPressed:
              isLoading
                  ? null
                  : () async {
                    if (_formKey.currentState?.validate() != true) return;
                    setState(() => isLoading = true);
                    final amount = double.parse(amountController.text);
                    final category =
                        showCustomCategory ? customCategory : selectedCategory;
                    final desc = descController.text.trim();
                    final success = await widget.viewModel.addExpense(
                      amount: amount,
                      date: selectedDate,
                      category: category,
                      description: desc,
                    );
                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Center(
                            child: Text(
                              'Expense added!',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'LexendDeca',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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
                              widget.viewModel.error ?? 'Failed to add expense',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'LexendDeca',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          backgroundColor: const Color(0xFFCD359C),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                    setState(() => isLoading = false);
                  },
          child:
              isLoading
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  )
                  : const Text('Add'),
        ),
      ],
    );
  }
}

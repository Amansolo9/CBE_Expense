import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../widgets/expenses_list.dart';

class ExpensesPage extends StatefulWidget {
  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  String? _uid;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUid();
  }

  Future<void> _loadUid() async {
    final authService = AuthService();
    final uid = await authService.getSessionUid();
    if (!mounted) return;
    if (uid == null) {
      setState(() {
        _error = 'No user session.';
        _loading = false;
      });
      return;
    }
    setState(() {
      _uid = uid;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCD359C)),
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (_uid == null) return const SizedBox.shrink();
    return ChangeNotifierProvider(
      create: (_) => ExpenseViewModel(uid: _uid!)..fetchExpenses(),
      child: const _ExpensesView(),
    );
  }
}

class _ExpensesView extends StatelessWidget {
  const _ExpensesView();

  void _showAddExpenseDialog(BuildContext context, ExpenseViewModel vm) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String? selectedCategory;
    String? customCategory;
    final descController = TextEditingController();
    bool showCustomCategory = false;
    bool isAdding = false;
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
                'Add Expense',
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
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
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
                    if (formKey.currentState?.validate() != true || isAdding)
                      return;
                    setState(() => isAdding = true);
                    final amount = double.parse(amountController.text);
                    final category =
                        showCustomCategory ? customCategory : selectedCategory;
                    final desc = descController.text.trim();
                    final success = await vm.addExpense(
                      amount: amount,
                      date: selectedDate,
                      category: category,
                      description: desc,
                    );
                    setState(() => isAdding = false);
                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Center(
                            child: Text(
                              'Expense added successfully!',
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
                              'Failed to add expense. Please try again.',
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
                      isAdding
                          ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFCD359C),
                            ),
                            backgroundColor: Colors.white,
                            strokeWidth: 3,
                          )
                          : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> showEditExpenseDialog(
    BuildContext context,
    ExpenseViewModel vm,
    Map<String, dynamic> expense,
  ) async {
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

    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text('Edit Expense'),
                  content: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: amountController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Amount is required';
                              if (double.tryParse(value) == null)
                                return 'Enter a valid number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text('Date:'),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: selectedDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                    );
                                    if (pickedDate != null) {
                                      setState(() => selectedDate = pickedDate);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(selectedDate),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: selectedCategory,
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
                                      (category) => DropdownMenuItem(
                                        value: category,
                                        child: Text(category),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value;
                                showCustomCategory = value == 'Other';
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Category',
                            ),
                          ),
                          if (showCustomCategory)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Custom Category',
                              ),
                              onChanged: (value) => customCategory = value,
                            ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: descController,
                            decoration: const InputDecoration(
                              labelText: 'Description (Optional)',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed:
                          isEditing
                              ? null
                              : () async {
                                if (!formKey.currentState!.validate()) return;
                                setState(() => isEditing = true);
                                final success = await vm
                                    .editExpense(expense['id'], {
                                      'amount': double.parse(
                                        amountController.text,
                                      ),
                                      'date': selectedDate,
                                      'category':
                                          showCustomCategory
                                              ? customCategory
                                              : selectedCategory,
                                      'description': descController.text,
                                    });
                                setState(() => isEditing = false);
                                if (success && context.mounted) {
                                  Navigator.pop(context, true);
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
                              ? const CircularProgressIndicator()
                              : const Text('Save'),
                    ),
                  ],
                );
              },
            );
          },
        ) ??
        false;
  }

  Future<bool> showDeleteExpenseDialog(
    BuildContext context,
    ExpenseViewModel vm,
    String expenseId,
  ) async {
    bool isDeleting = false;
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text('Delete Expense'),
                  content: const Text(
                    'Are you sure you want to delete this expense?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed:
                          isDeleting
                              ? null
                              : () async {
                                setState(() => isDeleting = true);
                                final success = await vm.deleteExpense(
                                  expenseId,
                                );
                                setState(() => isDeleting = false);
                                if (success && context.mounted) {
                                  Navigator.pop(context, true);
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
                              ? const CircularProgressIndicator()
                              : const Text('Delete'),
                    ),
                  ],
                );
              },
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseViewModel>(
      builder: (context, vm, _) {
        Widget body;
        if (vm.loading) {
          body = const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCD359C)),
            ),
          );
        } else if (vm.error != null) {
          body = Center(
            child: Text(vm.error!, style: const TextStyle(color: Colors.red)),
          );
        } else {
          final grouped =
              <String, Map<String, Map<String, List<Map<String, dynamic>>>>>{};
          for (final exp in vm.expenses) {
            final date =
                exp['date'] is DateTime
                    ? exp['date']
                    : (exp['date'] as Timestamp).toDate();
            final year = DateFormat('yyyy').format(date);
            final month = DateFormat('MMMM').format(date);
            final dayKey = DateFormat('d').format(date);
            grouped.putIfAbsent(year, () => {});
            grouped[year]!.putIfAbsent(month, () => {});
            grouped[year]![month]!.putIfAbsent(dayKey, () => []);
            grouped[year]![month]![dayKey]!.add(exp);
          }
          if (grouped.isEmpty) {
            body = const Center(
              child: Text(
                'No expenses yet.',
                style: TextStyle(fontFamily: 'LexendDeca'),
              ),
            );
          } else {
            body = ExpensesList(
              groupedExpenses: grouped,
              onEdit: (expense) async {
                final vm = Provider.of<ExpenseViewModel>(
                  context,
                  listen: false,
                );
                final success = await showEditExpenseDialog(
                  context,
                  vm,
                  expense,
                );
                if (success) {
                  vm.fetchExpenses();
                }
              },
              onDelete: (expense) async {
                final vm = Provider.of<ExpenseViewModel>(
                  context,
                  listen: false,
                );
                final success = await showDeleteExpenseDialog(
                  context,
                  vm,
                  expense['id'],
                );
                if (success) {
                  vm.fetchExpenses();
                }
              },
            );
          }
        }
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFFCD359C),
            onPressed: () => _showAddExpenseDialog(context, vm),
            child: const Icon(FeatherIcons.plus, color: Colors.white),
          ),
          body: body,
        );
      },
    );
  }
}

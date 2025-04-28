import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../viewmodels/expense_viewmodel.dart';

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
    final _formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String? selectedCategory;
    String? customCategory;
    final descController = TextEditingController();
    bool showCustomCategory = false;
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
                  key: _formKey,
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
                    if (_formKey.currentState?.validate() != true) return;
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
                              vm.error ?? 'Failed to add expense',
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
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
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
          // Group expenses by year/month/day
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
            body = ListView(
              padding: const EdgeInsets.all(16),
              children:
                  grouped.entries.map((yearEntry) {
                    final List<Widget> monthWidgets =
                        yearEntry.value.entries.map((monthEntry) {
                          final List<Widget> dayWidgets =
                              monthEntry.value.entries
                                  .map(
                                    (dayEntry) => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 16,
                                            top: 6,
                                          ),
                                          child: Text(
                                            'Day ${dayEntry.key}',
                                            style: const TextStyle(
                                              fontFamily: 'LexendDeca',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Color(0xFF333333),
                                            ),
                                          ),
                                        ),
                                        ...dayEntry.value.map(
                                          (exp) => Padding(
                                            padding: const EdgeInsets.only(
                                              left: 32,
                                              top: 6,
                                              bottom: 6,
                                            ),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 2,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 16,
                                                    ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'ETB ${exp['amount'].toStringAsFixed(2)}',
                                                            style: const TextStyle(
                                                              fontFamily:
                                                                  'LexendDeca',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                              color: Color(
                                                                0xFFCD359C,
                                                              ),
                                                            ),
                                                          ),
                                                          if (exp['category'] !=
                                                                  null &&
                                                              (exp['category']
                                                                      as String)
                                                                  .isNotEmpty)
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    top: 2,
                                                                  ),
                                                              child: Text(
                                                                exp['category'],
                                                                style: const TextStyle(
                                                                  fontFamily:
                                                                      'LexendDeca',
                                                                  fontSize: 14,
                                                                  color: Color(
                                                                    0xFFB29365,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          if (exp['description'] !=
                                                                  null &&
                                                              (exp['description']
                                                                      as String)
                                                                  .isNotEmpty)
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    top: 2,
                                                                  ),
                                                              child: Text(
                                                                exp['description'],
                                                                style: const TextStyle(
                                                                  fontFamily:
                                                                      'LexendDeca',
                                                                  fontSize: 13,
                                                                  color: Color(
                                                                    0xFF333333,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.only(
                                                                  top: 2,
                                                                ),
                                                            child: Text(
                                                              DateFormat(
                                                                'yyyy-MM-dd',
                                                              ).format(
                                                                exp['date']
                                                                        is DateTime
                                                                    ? exp['date']
                                                                    : (exp['date']
                                                                            as Timestamp)
                                                                        .toDate(),
                                                              ),
                                                              style: const TextStyle(
                                                                fontFamily:
                                                                    'LexendDeca',
                                                                fontSize: 12,
                                                                color: Color(
                                                                  0xFF999999,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.edit,
                                                            color: Color(
                                                              0xFFB29365,
                                                            ),
                                                          ),
                                                          onPressed:
                                                              () {}, // To be implemented
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.delete,
                                                            color: Color(
                                                              0xFFCD359C,
                                                            ),
                                                          ),
                                                          onPressed:
                                                              () {}, // To be implemented
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8, top: 8),
                                child: Text(
                                  monthEntry.key,
                                  style: const TextStyle(
                                    fontFamily: 'LexendDeca',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFFB29365),
                                  ),
                                ),
                              ),
                              ...dayWidgets,
                            ],
                          );
                        }).toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          yearEntry.key,
                          style: const TextStyle(
                            fontFamily: 'LexendDeca',
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Color(0xFFCD359C),
                          ),
                        ),
                        ...monthWidgets,
                      ],
                    );
                  }).toList(),
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

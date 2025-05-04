import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'expense_card.dart';

class ExpensesList extends StatelessWidget {
  final Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>>
  groupedExpenses;
  final Function(Map<String, dynamic>) onEdit;
  final Function(Map<String, dynamic>) onDelete;

  const ExpensesList({
    Key? key,
    required this.groupedExpenses,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children:
          groupedExpenses.entries.map((yearEntry) {
            final List<Widget> monthWidgets =
                yearEntry.value.entries.map((monthEntry) {
                  final List<Widget> dayWidgets =
                      monthEntry.value.entries.map((dayEntry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16, top: 6),
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
                              (exp) => ExpenseCard(
                                expense: exp,
                                onEdit: () => onEdit(exp),
                                onDelete: () => onDelete(exp),
                              ),
                            ),
                          ],
                        );
                      }).toList();

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

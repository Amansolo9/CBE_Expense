import 'package:another_telephony/telephony.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

final Telephony telephony = Telephony.instance;

class MessagesPage extends StatefulWidget {
  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  Map<String, Map<String, Map<String, List<_CbeSms>>>> _groupedMessages = {};
  bool _loading = true;
  String? _error;
  CbeSmsType _selectedType = CbeSmsType.credit;

  @override
  void initState() {
    super.initState();
    _requestAndFetchMessages();
  }

  Future<void> _requestAndFetchMessages() async {
    final bool? granted = await telephony.requestSmsPermissions;
    if (granted == true) {
      await _fetchMessages();
    } else {
      setState(() {
        _error = 'SMS permission denied. Please allow SMS access in settings.';
        _loading = false;
      });
    }
  }

  Future<void> _fetchMessages() async {
    try {
      final List<SmsMessage> messages = await telephony.getInboxSms();
      final filtered =
          messages
              .where(
                (m) =>
                    m.address == 'CBE' &&
                    m.body != null &&
                    m.body!.contains('CBE'),
              )
              .toList();
      final parsed =
          filtered
              .map(_CbeSms.fromSmsMessage)
              .where((m) => m != null)
              .cast<_CbeSms>()
              .toList();
      final grouped = <String, Map<String, Map<String, List<_CbeSms>>>>{};
      for (final msg in parsed) {
        final date = msg.date;
        final year = DateFormat('yyyy').format(date);
        final month = DateFormat('MMMM').format(date);
        final day = DateFormat('d').format(date);
        grouped.putIfAbsent(year, () => {});
        grouped[year]!.putIfAbsent(month, () => {});
        grouped[year]![month]!.putIfAbsent(day, () => []);
        grouped[year]![month]![day]!.add(msg);
      }
      setState(() {
        _groupedMessages = grouped;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load messages: $e';
        _loading = false;
      });
    }
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
    if (_groupedMessages.isEmpty) {
      return const Center(child: Text('No CBE messages found.'));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _selectedType == CbeSmsType.credit
                            ? const Color(0xFFCD359C)
                            : Colors.white,
                    foregroundColor:
                        _selectedType == CbeSmsType.credit
                            ? Colors.white
                            : const Color(0xFFCD359C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFFCD359C)),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'LexendDeca',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed:
                      () => setState(() => _selectedType = CbeSmsType.credit),
                  child: const Text('Credits'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _selectedType == CbeSmsType.debit
                            ? const Color(0xFFCD359C)
                            : Colors.white,
                    foregroundColor:
                        _selectedType == CbeSmsType.debit
                            ? Colors.white
                            : const Color(0xFFCD359C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFFCD359C)),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'LexendDeca',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed:
                      () => setState(() => _selectedType = CbeSmsType.debit),
                  child: const Text('Debits'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children:
                _groupedMessages.entries.map((yearEntry) {
                  final filteredMonths = yearEntry.value.map((month, days) {
                    final filteredDays = days.map((day, msgs) {
                      final filteredMsgs =
                          msgs
                              .where((msg) => msg.type == _selectedType)
                              .toList();
                      return MapEntry(day, filteredMsgs);
                    })..removeWhere((_, msgs) => msgs.isEmpty);
                    return MapEntry(month, filteredDays);
                  })..removeWhere((_, days) => days.isEmpty);
                  if (filteredMonths.isEmpty) return const SizedBox.shrink();
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
                      ...filteredMonths.entries.map(
                        (monthEntry) => Column(
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
                            ...monthEntry.value.entries.map(
                              (dayEntry) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    (msg) => Padding(
                                      padding: const EdgeInsets.only(
                                        left: 32,
                                        top: 2,
                                        bottom: 2,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            msg.type == CbeSmsType.credit
                                                ? Icons.arrow_downward
                                                : Icons.arrow_upward,
                                            color:
                                                msg.type == CbeSmsType.credit
                                                    ? Colors.green
                                                    : Colors.red,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            msg.type == CbeSmsType.credit
                                                ? '+${msg.amount} ETB'
                                                : '-${msg.amount} ETB',
                                            style: TextStyle(
                                              fontFamily: 'LexendDeca',
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  msg.type == CbeSmsType.credit
                                                      ? Colors.green
                                                      : Colors.red,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}

enum CbeSmsType { credit, debit }

class _CbeSms {
  final DateTime date;
  final double amount;
  final CbeSmsType type;

  _CbeSms({required this.date, required this.amount, required this.type});

  static _CbeSms? fromSmsMessage(SmsMessage msg) {
    final body = msg.body ?? '';
    final date = DateTime.fromMillisecondsSinceEpoch(
      msg.date ?? DateTime.now().millisecondsSinceEpoch,
    );
    final creditMatch = RegExp(
      r'has been credited with ETB ?([\d,.]+)(?:[. ]|$)',
      caseSensitive: false,
    ).firstMatch(body);
    if (creditMatch != null) {
      String amtStr = creditMatch
          .group(1)!
          .replaceAll(',', '')
          .replaceAll(RegExp(r'[. ]+?$'), '');
      if (amtStr.endsWith('.')) amtStr = amtStr.substring(0, amtStr.length - 1);
      final amount = double.tryParse(amtStr);
      if (amount != null) {
        return _CbeSms(date: date, amount: amount, type: CbeSmsType.credit);
      }
    }
    final debitMatch = RegExp(
      r'has been debited with ETB ?([\d,.]+)(?:[. ]|$)',
      caseSensitive: false,
    ).firstMatch(body);
    if (debitMatch != null) {
      final totalMatch = RegExp(
        r'total of ETB ?([\d,.]+)',
        caseSensitive: false,
      ).firstMatch(body);
      String amtStr;
      if (totalMatch != null) {
        amtStr = totalMatch
            .group(1)!
            .replaceAll(',', '')
            .replaceAll(RegExp(r'[. ]+?$'), '');
        if (amtStr.endsWith('.')) {
          amtStr = amtStr.substring(0, amtStr.length - 1);
        }
      } else {
        amtStr = debitMatch
            .group(1)!
            .replaceAll(',', '')
            .replaceAll(RegExp(r'[. ]+?$'), '');
        if (amtStr.endsWith('.')) {
          amtStr = amtStr.substring(0, amtStr.length - 1);
        }
      }
      final amount = double.tryParse(amtStr);
      if (amount != null) {
        return _CbeSms(date: date, amount: amount, type: CbeSmsType.debit);
      }
    }
    return null;
  }
}

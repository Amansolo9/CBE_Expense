import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../viewmodels/analytics_viewmodel.dart';
import '../services/auth_service.dart';

class AnalyticsPage extends StatefulWidget {
  final AnalyticsViewModel viewModel;

  const AnalyticsPage({Key? key, required this.viewModel}) : super(key: key);

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _selectedFilter = 'Daily';
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
    _fetchExpenses();
  }

  void _fetchExpenses() {
    print('Fetching expenses...');
    widget.viewModel
        .fetchAnalyticsData()
        .then((_) {
          print('Expenses fetched: ${widget.viewModel.analyticsData.length}');
          print('Loading state after fetch: ${widget.viewModel.loading}');
          setState(() {});
        })
        .catchError((error) {
          print('Error fetching expenses: ${error.toString()}');
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
        child: Text(
          _error!,
          style: const TextStyle(
            fontFamily: 'LexendDeca',
            fontSize: 16,
            color: Colors.red,
          ),
        ),
      );
    }
    if (_uid == null) {
      return const SizedBox.shrink();
    }

    final vm = widget.viewModel;

    Widget _buildChart() {
      if (vm.loading) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCD359C)),
          ),
        );
      }
      if (vm.analyticsData.isEmpty) {
        return const Center(
          child: Text(
            'No available data.',
            style: TextStyle(
              fontFamily: 'LexendDeca',
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        );
      }

      switch (_selectedFilter) {
        case 'Daily':
          final data = _groupDataByCategory(vm.analyticsData);
          return _buildPieChart(data);
        case 'Weekly':
        case 'Monthly':
        case 'Yearly':
          final data = _groupDataByTime(vm.analyticsData, _selectedFilter);
          return _buildBarChart(data);
        default:
          return const SizedBox.shrink();
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FeatherIcons.arrowLeft, color: Color(0xFFCD359C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Analytics',
          style: TextStyle(
            fontFamily: 'LexendDeca',
            fontWeight: FontWeight.bold,
            color: Color(0xFFCD359C),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: _selectedFilter,
                  items:
                      ['Daily', 'Weekly', 'Monthly', 'Yearly']
                          .map(
                            (filter) => DropdownMenuItem(
                              value: filter,
                              child: Text(
                                filter,
                                style: const TextStyle(
                                  fontFamily: 'LexendDeca',
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SizedBox(width: 300, height: 300, child: _buildChart()),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> data) {
    final List<PieChartSectionData> sections =
        data.entries.map((entry) {
          final color =
              Colors.primaries[data.keys.toList().indexOf(entry.key) %
                  Colors.primaries.length];
          return PieChartSectionData(
            color: color,
            value: entry.value,
            title: '${entry.value.toStringAsFixed(1)}ETB',
            radius: 100,
            titleStyle: const TextStyle(
              fontFamily: 'LexendDeca',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 300,
          height: 300,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              data.keys.map((key) {
                final color =
                    Colors.primaries[data.keys.toList().indexOf(key) %
                        Colors.primaries.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 12, height: 12, color: color),
                    const SizedBox(width: 4),
                    Text(
                      key,
                      style: const TextStyle(
                        fontFamily: 'LexendDeca',
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<BarChartGroupData> data) {
    return SizedBox(
      width: 400,
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: data,
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              axisNameWidget: const RotatedBox(
                quarterTurns: 1,
                child: Text(
                  'Amount',
                  style: TextStyle(fontFamily: 'LexendDeca', fontSize: 12),
                ),
              ),
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (_selectedFilter == 'Weekly') {
                    return Text(
                      'Week ${value.toInt()}',
                      style: const TextStyle(
                        fontFamily: 'LexendDeca',
                        fontSize: 12,
                      ),
                    );
                  } else if (_selectedFilter == 'Monthly') {
                    const months = [
                      'Jan',
                      'Feb',
                      'Mar',
                      'Apr',
                      'May',
                      'Jun',
                      'Jul',
                      'Aug',
                      'Sep',
                      'Oct',
                      'Nov',
                      'Dec',
                    ];
                    return Text(
                      months[value.toInt() - 1],
                      style: const TextStyle(
                        fontFamily: 'LexendDeca',
                        fontSize: 12,
                      ),
                    );
                  } else if (_selectedFilter == 'Yearly') {
                    return Text(
                      '${value.toInt()}',
                      style: const TextStyle(
                        fontFamily: 'LexendDeca',
                        fontSize: 12,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, double> _groupDataByCategory(
    List<Map<String, dynamic>> expenses,
  ) {
    final Map<String, double> groupedData = {};
    for (final exp in expenses) {
      final category = exp['category'] ?? 'Others';
      final amount = exp['amount'] as double;
      groupedData[category] = (groupedData[category] ?? 0) + amount;
    }
    return groupedData;
  }

  List<BarChartGroupData> _groupDataByTime(
    List<Map<String, dynamic>> expenses,
    String filter,
  ) {
    final Map<int, double> groupedData = {};
    for (final exp in expenses) {
      final date =
          exp['date'] is DateTime
              ? exp['date']
              : (exp['date'] as Timestamp).toDate();
      int key;
      if (filter == 'Weekly') {
        key = date.weekday;
      } else if (filter == 'Monthly') {
        key = date.month;
      } else if (filter == 'Yearly') {
        key = date.year;
      } else {
        continue;
      }
      final amount = exp['amount'] as double;
      groupedData[key] = (groupedData[key] ?? 0) + amount;
    }
    return groupedData.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [BarChartRodData(toY: entry.value, color: Color(0xFFCD359C))],
      );
    }).toList();
  }
}

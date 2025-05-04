import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final AnalyticsService _service;
  final String uid;
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> analyticsData = [];

  AnalyticsViewModel({required this.uid, AnalyticsService? service})
    : _service = service ?? AnalyticsService();

  Future<void> fetchAnalyticsData() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      analyticsData = await _service.fetchAnalyticsData(uid);
    } catch (e) {
      error = 'Failed to load analytics data: $e';
    }
    loading = false;
    notifyListeners();
  }
}

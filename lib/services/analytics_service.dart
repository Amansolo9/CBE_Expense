import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchAnalyticsData(String uid) async {
    print('Fetching analytics data for UID: $uid');
    final snap =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('expenses')
            .orderBy('date', descending: true)
            .get();
    print('Raw Firestore query result: ${snap.docs.length} documents fetched');
    return snap.docs.map((d) => d.data()..['id'] = d.id).toList();
  }
}

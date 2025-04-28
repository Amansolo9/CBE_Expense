import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> saveSession(User user) async {
    final expiry = DateTime.now().add(const Duration(hours: 24));
    await _secureStorage.write(key: 'uid', value: user.uid);
    await _secureStorage.write(key: 'expiry', value: expiry.toIso8601String());
  }

  Future<void> clearSession() async {
    await _secureStorage.deleteAll();
  }

  Future<bool> hasValidSession() async {
    final uid = await _secureStorage.read(key: 'uid');
    final expiryStr = await _secureStorage.read(key: 'expiry');
    if (uid == null || expiryStr == null) return false;
    final expiry = DateTime.tryParse(expiryStr);
    if (expiry == null) return false;
    return DateTime.now().isBefore(expiry);
  }

  Future<String?> getSessionUid() async {
    return await _secureStorage.read(key: 'uid');
  }

  Future<User?> signUp(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        final safeName =
            (name.trim().isEmpty) ? email.split('@').first : name.trim();
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': safeName,
          'email': email,
        });
        await saveSession(user);
      }
      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User?> logIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        await saveSession(user);
      }
      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await clearSession();
  }
}

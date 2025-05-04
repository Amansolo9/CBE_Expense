import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<String?> _getUserName(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null &&
            data['name'] != null &&
            (data['name'] as String).trim().isNotEmpty) {
          return data['name'];
        }
      }
    } catch (e) {
    }
    return null;
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        final user = await _authService.logIn(email, password);
        if (user != null) {
          final name =
              await _getUserName(user.uid) ??
              user.email?.split('@').first ??
              'User';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text(
                  'Welcome $name!',
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
          await Future.delayed(Duration(milliseconds: 800));
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text(
                  'Login failed.',
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
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                'Login failed.',
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
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}",
    );
    if (!emailRegex.hasMatch(value.trim())) return 'Please enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final formWidth = width * 0.9 > 360 ? 360.0 : width * 0.9;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 0, bottom: 10),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'WinkyRough',
                            fontSize: 32,
                            letterSpacing: 1,
                          ),
                          children: [
                            TextSpan(
                              text: 'CBE',
                              style: TextStyle(color: Color(0xFFCD359C)),
                            ),
                            TextSpan(text: ' '),
                            TextSpan(
                              text: 'Expense',
                              style: TextStyle(color: Color(0xFFB29365)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: formWidth,
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Login to your account.',
                        style: TextStyle(
                          fontFamily: 'LexendDeca',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color(0xFF333333),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: formWidth,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomTextField(
                              label: 'Email',
                              controller: _emailController,
                              icon: Icons.email,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              label: 'Password',
                              controller: _passwordController,
                              icon: Icons.lock,
                              obscureText: true,
                              showToggle: true,
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account ?",
                                  style: TextStyle(
                                    fontFamily: 'LexendDeca',
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    color: Color(0xFF666666),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(
                                      context,
                                    ).pushReplacementNamed('/signup');
                                  },
                                  child: const Text(
                                    'Signup',
                                    style: TextStyle(
                                      fontFamily: 'LexendDeca',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFFCD359C),
                                      letterSpacing: 0.3,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFCD359C),
                                  foregroundColor: const Color.fromARGB(
                                    255,
                                    255,
                                    255,
                                    255,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: const TextStyle(
                                    fontFamily: 'LexendDeca',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                onPressed: _isLoading ? null : _login,
                                child:
                                    _isLoading
                                        ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Color(0xFFCD359C),
                                                ),
                                            backgroundColor: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                        )
                                        : const Text('Login'),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

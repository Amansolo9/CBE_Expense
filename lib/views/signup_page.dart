import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../services/auth_service.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final name = _nameController.text.trim();
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();

        final user = await _authService.signUp(email, password, name);
        if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text(
                  'Signup successful! Welcome, $name!',
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
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text(
                  'Signup failed.',
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
                'Signup failed.',
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

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your name';
    return null;
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final formWidth = width * 0.9 > 360 ? 360.0 : width * 0.9;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
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
                // Subtitle
                Container(
                  width: formWidth,
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Create an account.',
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
                          label: 'Name',
                          controller: _nameController,
                          icon: Icons.person,
                          validator: _validateName,
                        ),
                        const SizedBox(height: 20),
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
                        const SizedBox(height: 20),
                        CustomTextField(
                          label: 'Confirm Password',
                          controller: _confirmPasswordController,
                          icon: Icons.lock_outline,
                          obscureText: true,
                          showToggle: true,
                          validator: _validateConfirmPassword,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account ?',
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
                                ).pushReplacementNamed('/login');
                              },
                              child: const Text(
                                'Login',
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
                        const SizedBox(height: 32),
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
                            onPressed: _isLoading ? null : _signup,
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
                                    : const Text('Sign Up'),
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
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

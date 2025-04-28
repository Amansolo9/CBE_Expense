import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SessionCheckPage extends StatelessWidget {
  const SessionCheckPage({Key? key}) : super(key: key);

  Future<String> _getInitialRoute() async {
    final authService = AuthService();
    final hasSession = await authService.hasValidSession();
    return hasSession ? '/home' : '/login';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Something went wrong!\n{snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text('No route found!')));
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(snapshot.data!);
        });
        return const SizedBox.shrink();
      },
    );
  }
}

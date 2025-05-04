import '../services/auth_service.dart';
import '../viewmodels/analytics_viewmodel.dart';
import 'package:feather_icons/feather_icons.dart';
import 'expenses_page.dart';
import 'messages_page.dart';
import 'analytics.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [ExpensesPage(), MessagesPage()];
  final AuthService _authService = AuthService();
  String? _userName;
  String? _userInitial;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final uid = await _authService.getSessionUid();
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final name = doc.data()?['name'] ?? '';
      setState(() {
        _userName = name;
        _userInitial = (name.isNotEmpty) ? name.trim()[0].toUpperCase() : '';
        _isLoadingUser = false;
      });
    } else {
      setState(() {
        _userName = '';
        _userInitial = '';
        _isLoadingUser = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFCD359C)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isLoadingUser
                        ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                        : Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _userInitial ?? '',
                              style: const TextStyle(
                                color: Color(0xFFCD359C),
                                fontFamily: 'LexendDeca',
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            ),
                          ),
                        ),
                    const SizedBox(height: 12),
                    Text(
                      _userName ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'LexendDeca',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                FeatherIcons.barChart2,
                color: Color(0xFFCD359C),
              ),
              title: const Text(
                'Analytics',
                style: TextStyle(fontFamily: 'LexendDeca'),
              ),
              onTap: () async {
                final uid = await _authService.getSessionUid();
                if (uid != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => AnalyticsPage(
                            viewModel: AnalyticsViewModel(uid: uid),
                          ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Failed to load user data. Please try again.',
                      ),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(
                FeatherIcons.logOut,
                color: Color(0xFFCD359C),
              ),
              title: const Text(
                'Logout',
                style: TextStyle(fontFamily: 'LexendDeca'),
              ),
              onTap: _logout,
            ),
            const SizedBox(height: 200),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Amanuel Ayana', style: TextStyle(fontSize: 20 ,fontFamily: 'WinkyRough', color: Color(0xFFCD359C))),
                  const Divider(),
                  Text('Amanuel Dagnachew', style: TextStyle(fontSize: 20 ,fontFamily: 'WinkyRough', color: Color(0xFFCD359C))),
                  const Divider(),
                  Text('Amanuel Mandefro', style: TextStyle(fontSize: 20 ,fontFamily: 'WinkyRough', color: Color(0xFFCD359C))),
                  const Divider(),
                  Text('Amanuel Solomon', style: TextStyle(fontSize: 20 ,fontFamily: 'WinkyRough', color: Color(0xFFCD359C))),
                  const Divider(),
                  Text('Beamanuel Tesfaye', style: TextStyle(fontSize: 20 ,fontFamily: 'WinkyRough', color: Color(0xFFCD359C))),
                  SizedBox(height: 16),
                  Center(
                    child: Text('Made with <3', style: TextStyle(fontFamily: 'WinkyRough', color: Color(0xFFCD359C), fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(FeatherIcons.menu, color: Color(0xFFCD359C)),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'WinkyRough',
              fontSize: 32,
              letterSpacing: 1,
            ),
            children: [
              TextSpan(text: 'CBE', style: TextStyle(color: Color(0xFFCD359C))),
              TextSpan(text: ' '),
              TextSpan(
                text: 'Expense',
                style: TextStyle(color: Color(0xFFB29365)),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFCD359C),
        unselectedItemColor: const Color(0xFF666666),
        selectedLabelStyle: const TextStyle(fontFamily: 'LexendDeca'),
        unselectedLabelStyle: const TextStyle(fontFamily: 'LexendDeca'),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.list),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.messageCircle),
            label: 'CBE',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/app_state.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/statistik_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/transaction_screen.dart';
import 'providers/transaction_provider.dart'; // 1. IMPORT TRANSACTION PROVIDER KAMU DI SINI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    // 2. GANTI MENJADI MULTIPROVIdER AGAR BISA DAFTAR BANYAK PROVIDER sekaligus
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(
            create: (_) => TransactionProvider()), // <-- DAFTARKAN DI SINI
      ],
      child: const CashyBaraApp(),
    ),
  );
}

class CashyBaraApp extends StatelessWidget {
  const CashyBaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CashyBara',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F0EA),
        fontFamily: 'PlusJakartaSans',
      ),
      home: const SplashRouter(),
    );
  }
}

// ── SPLASH ROUTER ─────────────────────────────────────────────────────────────

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});
  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final loggedIn = await context.read<AppState>().tryAutoLogin();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => loggedIn ? const MainScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF4A3728),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🦫', style: TextStyle(fontSize: 80)),
            SizedBox(height: 16),
            Text(
              'CashyBara',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}

// ── MAIN SCREEN (Bottom Nav) ──────────────────────────────────────────────────

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _idx = 0;

  final _screens = const [
    HomeScreen(),
    TransactionScreen(),
    StatistikScreen(),
    BudgetScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _idx,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4A3728),
        unselectedItemColor: const Color(0xFF9E8F82),
        backgroundColor: Colors.white,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Statistik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Budget',
          ),
        ],
      ),
    );
  }
}

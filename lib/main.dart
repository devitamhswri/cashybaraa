import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/app_state.dart';
import 'screens/main_screen.dart';
import 'providers/transaction_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
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
        fontFamily: 'Plus Jakarta Sans',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A3728)),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
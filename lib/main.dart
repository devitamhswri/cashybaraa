import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cashybara/providers/transaction_provider.dart';
import 'package:cashybara/screens/login_screen.dart';
import 'package:cashybara/screens/main_screen.dart'; // Import file baru ini

void main() {
  runApp(
    MultiProvider(
      providers: [
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF41241A)),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      // Tetap mulai dari Login, nanti setelah login arahkan ke MainScreen()
      home: const LoginScreen(), 
    );
  }
}
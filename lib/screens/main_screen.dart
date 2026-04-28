import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'transaction_screen.dart'; // Pastikan file ini sudah ada

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan
  final List<Widget> _pages = [
    const HomeScreen(),
    const TransactionScreen(),
    const Center(child: Text("Halaman Budget")),
    const Center(child: Text("Halaman Pengaturan")),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Biar label muncul semua
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF41241A), // Cokelat gelap sesuai tema
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book), // Ikon Beranda (seperti buku di desainmu)
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long), // Ikon Transaksi
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings), // Ikon Budget
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings), // Ikon Pengaturan
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
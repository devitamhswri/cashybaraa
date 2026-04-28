import 'package:flutter/material.dart';

class TransactionItem {
  final String title;
  final double amount;
  final String time;
  final IconData icon;
  final String account; // Tambahan: buat bedain BCA atau Tunai

  TransactionItem({
    required this.title,
    required this.amount,
    required this.time,
    required this.icon,
    this.account = 'BCA', // Default ke BCA
  });
}

class TransactionProvider with ChangeNotifier {
  final List<TransactionItem> _items = [];

  List<TransactionItem> get items => _items;

  // --- FITUR HITUNG TOTAL (Untuk Kartu Cokelat) ---
  
  double get totalBalance => _items.fold(0, (sum, item) => sum + item.amount);

  double get bcaBalance => _items
      .where((item) => item.account == 'BCA')
      .fold(0, (sum, item) => sum + item.amount);

  double get cashBalance => _items
      .where((item) => item.account == 'Tunai')
      .fold(0, (sum, item) => sum + item.amount);

  // --- FUNGSI TAMBAH DATA ---

  void addTransaction(String title, double amount, IconData icon, {String account = 'BCA'}) {
    _items.insert(
      0,
      TransactionItem(
        title: title,
        amount: amount,
        time: "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
        icon: icon,
        account: account,
      ),
    );
    notifyListeners();
  }
}
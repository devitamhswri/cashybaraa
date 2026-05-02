import 'package:flutter/material.dart';

// ── MODELS ────────────────────────────────────────────────────────────────────

class AkunItem {
  final String nama;
  final String tipe;
  int saldo;
  final Color bgColor;

  AkunItem({
    required this.nama,
    required this.tipe,
    required this.saldo,
    required this.bgColor,
  });
}

class CategoryData {
  final int id;
  final String name;
  final String icon;
  final Color bg;
  final Color color;
  int amount;

  CategoryData({
    required this.id,
    required this.name,
    required this.icon,
    required this.bg,
    required this.color,
    this.amount = 0,
  });

  int pct(int totalSaldo) {
    if (totalSaldo == 0) return 0;
    return ((amount / totalSaldo) * 100).round();
  }
}

// ── APP STATE ─────────────────────────────────────────────────────────────────

class AppState extends ChangeNotifier {
  // Akun / saldo
  final List<AkunItem> akunList = [
    AkunItem(
        nama: 'Bank BCA',
        tipe: 'bank',
        saldo: 1000000,
        bgColor: const Color(0xFFE8F4FF)),
    AkunItem(
        nama: 'Uang Tunai',
        tipe: 'cash',
        saldo: 1350000,
        bgColor: const Color(0xFFE8F5E9)),
  ];

  int get totalSaldo => akunList.fold(0, (sum, a) => sum + a.saldo);

  void tambahAkun(AkunItem akun) {
    akunList.add(akun);
    notifyListeners();
  }

  // Kategori pengeluaran
  final List<CategoryData> categories = [
    CategoryData(
        id: 1,
        name: "Makanan dan Minuman",
        icon: "🍔",
        bg: const Color(0xFFFFF3E0),
        color: const Color(0xFFF4A03A)),
    CategoryData(
        id: 2,
        name: "Transportasi",
        icon: "🚗",
        bg: const Color(0xFFE3F2FD),
        color: const Color(0xFF42A5F5)),
    CategoryData(
        id: 3,
        name: "Biaya Utilitas",
        icon: "🏠",
        bg: const Color(0xFFE8F5E9),
        color: const Color(0xFF66BB6A)),
    CategoryData(
        id: 4,
        name: "Belanja",
        icon: "🛍",
        bg: const Color(0xFFFCE4EC),
        color: const Color(0xFFEC407A)),
    CategoryData(
        id: 5,
        name: "Kesehatan",
        icon: "❤️",
        bg: const Color(0xFFFDF3E7),
        color: const Color(0xFFEF5350)),
    CategoryData(
        id: 6,
        name: "Perawatan",
        icon: "💆",
        bg: const Color(0xFFF3E5F5),
        color: const Color(0xFFAB47BC)),
  ];

  void setAmount(int categoryId, int amount) {
    final cat = categories.firstWhere((c) => c.id == categoryId);
    cat.amount = amount;
    notifyListeners();
  }

  void tambahCategory(CategoryData cat) {
    categories.add(cat);
    notifyListeners();
  }
}

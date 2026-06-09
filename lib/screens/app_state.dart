import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class CategoryData {
  final String id;
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

  static Color hexToColor(String? hex, Color fallback) {
    if (hex == null) return fallback;
    try {
      return Color(int.parse(hex.replaceAll('#', '0xFF')));
    } catch (_) {
      return fallback;
    }
  }
}

class AkunItem {
  final String id; // ← Firestore doc id
  final String nama;
  final String tipe;
  final int saldo;
  final Color bgColor;

  const AkunItem({
    this.id = '',
    required this.nama,
    required this.tipe,
    required this.saldo,
    required this.bgColor,
  });
}

class AppState extends ChangeNotifier {
  String userName = '';
  int totalSaldo = 0;
  int monthIncome = 0;
  int monthExpense = 0;
  bool isLoading = false;
  List<CategoryData> categories = [];
  List<AkunItem> akunList = [];

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<String?> login(String email, String password) async {
    final error = await FirebaseService.login(email, password);
    if (error != null) return error;
    await _loadUser();
    await loadData();
    return null;
  }

  Future<String?> register(String name, String email, String password) async {
    final error = await FirebaseService.register(name, email, password);
    if (error != null) return error;
    await _loadUser();
    await loadData();
    return null;
  }

  // Tambahan method Login dengan Google
  Future<String?> loginWithGoogle() async {
    final error = await FirebaseService.signInWithGoogle();
    if (error != null) return error;
    await _loadUser();
    await loadData();
    return null;
  }

  Future<void> _loadUser() async {
    final user = await FirebaseService.getUser();
    userName = user?['name'] ?? '';
    notifyListeners();
  }

  // Update logout untuk menggunakan Google Sign Out
  Future<void> logout() async {
    await FirebaseService.signOutGoogle(); // ← Sudah diganti ke signOutGoogle
    userName = '';
    totalSaldo = 0;
    monthIncome = 0;
    monthExpense = 0;
    categories = [];
    akunList = [];
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    if (!FirebaseService.isLoggedIn) return false;
    await _loadUser();
    await loadData();
    return true;
  }

  // ── Load Data ─────────────────────────────────────────────────────────────

  Future<void> loadData() async {
    if (!FirebaseService.isLoggedIn) return;
    isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final summary = await FirebaseService.getSummary(now.month, now.year);
    totalSaldo = summary['total_balance']!;
    monthIncome = summary['income']!;
    monthExpense = summary['expense']!;

    final cats = await FirebaseService.getCategories(type: 'expense');
    final List<CategoryData> result = [];
    for (final c in cats) {
      final txs = await FirebaseService.getTransactions(
        month: now.month, year: now.year, categoryId: c['id'],
      );
      final spent = txs
          .where((t) => t['type'] == 'expense')
          .fold<int>(0, (s, t) => s + (t['amount'] as int));
      result.add(CategoryData(
        id: c['id'], name: c['name'] ?? '', icon: c['icon'] ?? '💰',
        bg: CategoryData.hexToColor(c['bg_color'], const Color(0xFFF5F0EA)),
        color: CategoryData.hexToColor(c['color'], const Color(0xFF4A3728)),
        amount: spent,
      ));
    }
    categories = result;

    // Load akun dari Firestore
    await _loadAkun();

    isLoading = false;
    notifyListeners();
  }

  // ── Akun ──────────────────────────────────────────────────────────────────

  Future<void> _loadAkun() async {
    final list = await FirebaseService.getAkun();
    akunList = list.map((a) {
      Color bg;
      switch (a['tipe']) {
        case 'bank':    bg = const Color(0xFFE8F4FF); break;
        case 'cash':    bg = const Color(0xFFE8F5E9); break;
        default:        bg = const Color(0xFFF3E5F5);
      }
      return AkunItem(
        id: a['id'] ?? '',
        nama: a['nama'] ?? '',
        tipe: a['tipe'] ?? 'bank',
        saldo: (a['saldo'] as num?)?.toInt() ?? 0,
        bgColor: bg,
      );
    }).toList();

    // Hitung total saldo dari akun
    totalSaldo = akunList.fold(0, (sum, a) => sum + a.saldo);
  }

  Future<void> tambahAkun(AkunItem akun) async {
    final id = await FirebaseService.addAkun({
      'nama': akun.nama,
      'tipe': akun.tipe,
      'saldo': akun.saldo,
    });
    akunList.add(AkunItem(
      id: id, nama: akun.nama, tipe: akun.tipe,
      saldo: akun.saldo, bgColor: akun.bgColor,
    ));
    totalSaldo += akun.saldo;
    notifyListeners();
  }

  Future<void> tambahSaldoAkun(int index, int jumlah) async {
    final akun = akunList[index];
    final saldoBaru = akun.saldo + jumlah;

    // Update ke Firestore
    await FirebaseService.updateSaldoAkun(akun.id, saldoBaru);

    akunList[index] = AkunItem(
      id: akun.id, nama: akun.nama, tipe: akun.tipe,
      saldo: saldoBaru, bgColor: akun.bgColor,
    );
    totalSaldo += jumlah;
    notifyListeners();
  }

  // ── Kategori ──────────────────────────────────────────────────────────────

  Future<void> tambahCategory(CategoryData cat) async {
    final bgHex = '#${cat.bg.value.toRadixString(16).substring(2).toUpperCase()}';
    final colorHex = '#${cat.color.value.toRadixString(16).substring(2).toUpperCase()}';
    final id = await FirebaseService.addCategory({
      'name': cat.name, 'icon': cat.icon,
      'bg_color': bgHex, 'color': colorHex, 'type': 'expense',
    });
    categories.add(CategoryData(
      id: id, name: cat.name, icon: cat.icon, bg: cat.bg, color: cat.color,
    ));
    notifyListeners();
  }

  // ── Transaksi ─────────────────────────────────────────────────────────────

  Future<void> tambahTransaksi({
    required String categoryId,
    required String type,
    required int amount,
    required String date,
    String? note,
  }) async {
    await FirebaseService.addTransaction({
      'category_id': categoryId, 'type': type,
      'amount': amount, 'date': date, 'note': note ?? '',
    });
    await loadData();
  }
}
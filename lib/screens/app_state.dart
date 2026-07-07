import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class CategoryData {
  final String id;
  final String name;
  final String icon;
  final Color bg;
  final Color color;
  final String type;
  int amount;

  CategoryData({
    required this.id,
    required this.name,
    required this.icon,
    required this.bg,
    required this.color,
    this.type = 'expense',
    this.amount = 0,
  });

  int pct(int total) {
    if (total == 0) return 0;
    return ((amount / total) * 100).round();
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

// ── AKUN ──────────────────────────────────────────────────────────────────────

class AkunItem {
  final String id;
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

// ── APP STATE ─────────────────────────────────────────────────────────────────

class AppState extends ChangeNotifier {
  String userName  = '';
  String userEmail = '';
  bool isLoading   = false;

  int selectedMonth = DateTime.now().month;
  int selectedYear  = DateTime.now().year;

  int totalSaldo   = 0;
  int monthIncome  = 0;
  int monthExpense = 0;

  List<CategoryData> expenseCategories = [];
  List<CategoryData> incomeCategories  = [];
  List<AkunItem>     akunList          = [];

  List<CategoryData> get categories => expenseCategories;

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

  Future<void> _loadUser() async {
    final user = await FirebaseService.getUser();
    userName  = user?['name']  ?? '';
    userEmail = user?['email'] ?? FirebaseService.currentUser?.email ?? '';
    notifyListeners();
  }

  Future<void> logout() async {
    await FirebaseService.logout();
    userName          = '';
    userEmail         = '';
    totalSaldo        = 0;
    monthIncome       = 0;
    monthExpense      = 0;
    expenseCategories = [];
    incomeCategories  = [];
    akunList          = [];
    notifyListeners();
  }

  Future<String?> loginWithGoogle() async {
    await FirebaseService.signOutGoogle();
    final error = await FirebaseService.signInWithGoogle();
    if (error != null) return error;
    await _loadUser();
    await loadData();
    return null;
  }

  Future<bool> tryAutoLogin() async {
    if (!FirebaseService.isLoggedIn) return false;
    await _loadUser();
    await loadData();
    return true;
  }

  // ── Bulan ─────────────────────────────────────────────────────────────────

  Future<void> setMonth(int month, int year) async {
    selectedMonth = month;
    selectedYear  = year;
    await loadData();
  }

  // ── Load Data ─────────────────────────────────────────────────────────────

  Future<void> loadData() async {
    if (!FirebaseService.isLoggedIn) return;
    isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      FirebaseService.getSummary(selectedMonth, selectedYear),
      FirebaseService.getCategories(type: 'expense'),
      FirebaseService.getCategories(type: 'income'),
      FirebaseService.getAkun(),
      FirebaseService.getTransactions(month: selectedMonth, year: selectedYear),
    ]);

    final summary  = results[0] as Map<String, int>;
    final expCats  = results[1] as List<Map<String, dynamic>>;
    final incCats  = results[2] as List<Map<String, dynamic>>;
    final akunData = results[3] as List<Map<String, dynamic>>;
    final allTxs   = results[4] as List<Map<String, dynamic>>;

    monthIncome  = summary['income']!;
    monthExpense = summary['expense']!;

    // totalSaldo dari saldo akun Firestore — bukan dari kalkulasi transaksi
    akunList = akunData.map((a) {
      final tipe = (a['tipe'] ?? 'bank') as String;
      final bg = tipe == 'bank'
          ? const Color(0xFFE8F4FF)
          : tipe == 'cash'
              ? const Color(0xFFE8F5E9)
              : const Color(0xFFF3E5F5);
      return AkunItem(
        id:      a['id'] ?? '',
        nama:    a['nama'] ?? a['name'] ?? '',
        tipe:    tipe,
        saldo:   (a['saldo'] as num?)?.toInt() ?? 0,
        bgColor: bg,
      );
    }).toList();

    totalSaldo = akunList.fold(0, (sum, a) => sum + a.saldo);

    // Expense categories
    expenseCategories = expCats.map((c) {
      final spent = allTxs
          .where((t) => t['category_id'] == c['id'] && t['type'] == 'expense')
          .fold<int>(0, (s, t) => s + (t['amount'] as int));
      return CategoryData(
        id: c['id'], name: c['name'] ?? '', icon: c['icon'] ?? '💰',
        bg:    CategoryData.hexToColor(c['bg_color'], const Color(0xFFF5F0EA)),
        color: CategoryData.hexToColor(c['color'],    const Color(0xFF4A3728)),
        type: 'expense', amount: spent,
      );
    }).toList();

    // Income categories
    incomeCategories = incCats.map((c) {
      final earned = allTxs
          .where((t) => t['category_id'] == c['id'] && t['type'] == 'income')
          .fold<int>(0, (s, t) => s + (t['amount'] as int));
      return CategoryData(
        id: c['id'], name: c['name'] ?? '', icon: c['icon'] ?? '💰',
        bg:    CategoryData.hexToColor(c['bg_color'], const Color(0xFFE0F2F1)),
        color: CategoryData.hexToColor(c['color'],    const Color(0xFF26A69A)),
        type: 'income', amount: earned,
      );
    }).toList();

    isLoading = false;
    notifyListeners();
  }

  // ── Kategori ──────────────────────────────────────────────────────────────

  Future<void> tambahCategory(CategoryData cat) async {
    final bgHex    = '#${cat.bg.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
    final colorHex = '#${cat.color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
    final id = await FirebaseService.addCategory({
      'name': cat.name, 'icon': cat.icon,
      'bg_color': bgHex, 'color': colorHex, 'type': cat.type,
    });
    final newCat = CategoryData(
      id: id, name: cat.name, icon: cat.icon,
      bg: cat.bg, color: cat.color, type: cat.type,
    );
    if (cat.type == 'income') {
      incomeCategories.add(newCat);
    } else {
      expenseCategories.add(newCat);
    }
    notifyListeners();
  }

  // ── Akun ──────────────────────────────────────────────────────────────────

  Future<void> tambahAkun(AkunItem akun) async {
    final id = await FirebaseService.addAkun({
      'nama': akun.nama, 'tipe': akun.tipe, 'saldo': akun.saldo,
    });
    akunList.add(AkunItem(
      id: id, nama: akun.nama, tipe: akun.tipe,
      saldo: akun.saldo, bgColor: akun.bgColor,
    ));
    totalSaldo += akun.saldo;
    notifyListeners();
  }

  Future<void> tambahSaldoAkun(int index, int tambah) async {
    final akun      = akunList[index];
    final saldoBaru = akun.saldo + tambah;
    await FirebaseService.updateSaldoAkun(akun.id, saldoBaru);
    akunList[index] = AkunItem(
      id: akun.id, nama: akun.nama, tipe: akun.tipe,
      saldo: saldoBaru, bgColor: akun.bgColor,
    );
    totalSaldo += tambah;
    notifyListeners();
  }

  // ── Profil ────────────────────────────────────────────────────────────────

  Future<String?> updateProfil({required String nama, required String email}) async {
    final error = await FirebaseService.updateUser(nama: nama, email: email);
    if (error != null) return error;
    userName  = nama;
    userEmail = email;
    notifyListeners();
    return null;
  }

  Future<String?> updatePassword({
    required String passwordLama,
    required String passwordBaru,
  }) async {
    return await FirebaseService.updatePassword(
      passwordLama: passwordLama,
      passwordBaru: passwordBaru,
    );
  }

  // ── Reset Data (nama sesuai setting_screen: state.resetData()) ────────────

  Future<void> resetData() async {
    await FirebaseService.resetSemuaData();
    await loadData();
  }

  // ── Hapus Akun (nama sesuai setting_screen: state.hapusAkun(password:)) ──

  Future<String?> hapusAkun({required String password}) async {
    final error = await FirebaseService.hapusAkunPermanen(password: password);
    if (error != null) return error;
    userName          = '';
    userEmail         = '';
    totalSaldo        = 0;
    monthIncome       = 0;
    monthExpense      = 0;
    expenseCategories = [];
    incomeCategories  = [];
    akunList          = [];
    notifyListeners();
    return null;
  }
}
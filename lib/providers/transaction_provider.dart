import 'package:flutter/material.dart';

class TransactionItem {
  final String title;
  final double amount;
  final String tipe; // 'pengeluaran' atau 'pemasukan'
  final String kategori;
  final String akun;
  final DateTime tanggal;
  final String notes;
  final String iconEmoji;
  final String time;

  TransactionItem({
    required this.title,
    required this.amount,
    required this.tipe,
    required this.kategori,
    required this.akun,
    required this.tanggal,
    this.notes = '',
    this.iconEmoji = '💰',
    required this.time,
  });
}

class TransactionProvider with ChangeNotifier {
  final List<TransactionItem> _items = [];

  List<TransactionItem> get items => List.unmodifiable(_items);

  // ── GETTER SALDO ────────────────────────────────────────────────────────────

  double get totalBalance => _items.fold(0, (sum, t) => sum + t.amount);

  double get bcaBalance => _items
      .where((t) => t.akun == 'Bank BCA')
      .fold(0, (sum, t) => sum + t.amount);

  double get cashBalance => _items
      .where((t) => t.akun == 'Uang Tunai')
      .fold(0, (sum, t) => sum + t.amount);

  // ── FILTER ─────────────────────────────────────────────────────────────────

  List<TransactionItem> getByDay(DateTime day) => _items
      .where((t) =>
          t.tanggal.year == day.year &&
          t.tanggal.month == day.month &&
          t.tanggal.day == day.day)
      .toList();

  List<TransactionItem> getByMonth(int year, int month) => _items
      .where((t) => t.tanggal.year == year && t.tanggal.month == month)
      .toList();

  Set<int> getDotDays(int year, int month) => _items
      .where((t) => t.tanggal.year == year && t.tanggal.month == month)
      .map((t) => t.tanggal.day)
      .toSet();

  // ── TAMBAH TRANSAKSI ────────────────────────────────────────────────────────

  void addTransactionFull({
    required String title,
    required double amount,
    required String tipe,
    required String kategori,
    required String akun,
    required DateTime tanggal,
    String notes = '',
  }) {
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    _items.insert(
      0,
      TransactionItem(
        title: title,
        amount: amount,
        tipe: tipe,
        kategori: kategori,
        akun: akun,
        tanggal: tanggal,
        notes: notes,
        iconEmoji: _emojiKategori(kategori),
        time: time,
      ),
    );
    notifyListeners();
  }

  // Fungsi lama untuk kompatibilitas income_card.dart
  void addTransaction(String title, double amount, IconData icon,
      {String account = 'BCA'}) {
    final now = DateTime.now();
    _items.insert(
      0,
      TransactionItem(
        title: title,
        amount: amount,
        tipe: 'pengeluaran',
        kategori: 'Lainnya',
        akun: account == 'BCA' ? 'Bank BCA' : 'Uang Tunai',
        tanggal: now,
        time:
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      ),
    );
    notifyListeners();
  }

  String _emojiKategori(String kategori) {
    const map = {
      'Makanan dan Minuman': '🍔',
      'Transportasi': '🚗',
      'Biaya Utilitas': '🏠',
      'Belanja': '🛍',
      'Kesehatan': '❤️',
      'Perawatan': '💆',
    };
    return map[kategori] ?? '💰';
  }
}
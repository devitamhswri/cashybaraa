import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class TransactionItem {
  final String id;
  final String title;
  final double amount;
  final String tipe;
  final String kategori;
  final String categoryId;
  final String akun;
  final DateTime tanggal;
  final String notes;
  final String iconEmoji;
  final String time;

  TransactionItem({
    this.id = '',
    required this.title,
    required this.amount,
    required this.tipe,
    required this.kategori,
    this.categoryId = '',
    required this.akun,
    required this.tanggal,
    this.notes = '',
    this.iconEmoji = '💰',
    required this.time,
  });
}

class TransactionProvider with ChangeNotifier {
  final List<TransactionItem> _items = [];
  bool isLoading = false;

  List<TransactionItem> get items => List.unmodifiable(_items);

  // ── FILTER ─────────────────────────────────────────────────────────────────

  List<TransactionItem> getByDay(DateTime day) => _items
      .where((t) =>
          t.tanggal.year == day.year &&
          t.tanggal.month == day.month &&
          t.tanggal.day == day.day)
      .toList();

  List<TransactionItem> getByMonthLocal(int year, int month) => _items
      .where((t) => t.tanggal.year == year && t.tanggal.month == month)
      .toList();

  Set<int> getDotDays(int year, int month) => _items
      .where((t) => t.tanggal.year == year && t.tanggal.month == month)
      .map((t) => t.tanggal.day)
      .toSet();

  // ── GETTER BALANCE (kompatibilitas income_card.dart) ───────────────────────

  double get totalBalance => _items.fold(0, (sum, t) {
        if (t.tipe == 'pemasukan' || t.tipe == 'income') return sum + t.amount;
        return sum - t.amount;
      });

  double get bcaBalance => _items
          .where((t) => t.akun.toLowerCase().contains('bca'))
          .fold(0, (sum, t) {
        if (t.tipe == 'pemasukan' || t.tipe == 'income') return sum + t.amount;
        return sum - t.amount;
      });

  double get cashBalance => _items
          .where((t) =>
              t.akun.toLowerCase().contains('tunai') ||
              t.akun.toLowerCase().contains('cash'))
          .fold(0, (sum, t) {
        if (t.tipe == 'pemasukan' || t.tipe == 'income') return sum + t.amount;
        return sum - t.amount;
      });

  // ── LOAD DARI FIREBASE ──────────────────────────────────────────────────────

  Future<void> loadMonth(int year, int month) async {
    isLoading = true;
    notifyListeners();

    try {
      final cats = await FirebaseService.getCategories();
      final catMap = <String, Map<String, String>>{};
      for (final c in cats) {
        catMap[c['id']] = {
          'name': c['name'] ?? '',
          'icon': c['icon'] ?? '💰',
        };
      }

      final txs =
          await FirebaseService.getTransactions(month: month, year: year);

      _items.clear();
      for (final t in txs) {
        final catId = t['category_id'] ?? '';
        final catData = catMap[catId];
        final tanggal = DateTime.tryParse(t['date'] ?? '') ?? DateTime.now();
        final now = DateTime.now();

        _items.add(TransactionItem(
          id: t['id'] ?? '',
          title: (t['note'] != null && t['note'].toString().isNotEmpty)
              ? t['note']
              : (catData?['name'] ?? 'Transaksi'),
          amount: (t['amount'] as num).toDouble(),
          tipe: t['type'] == 'income' ? 'pemasukan' : 'pengeluaran',
          kategori: catData?['name'] ?? '',
          categoryId: catId,
          akun: t['akun'] ?? '',
          tanggal: tanggal,
          notes: t['note'] ?? '',
          iconEmoji: catData?['icon'] ?? '💰',
          time:
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        ));
      }
    } catch (e) {
      debugPrint('TransactionProvider loadMonth error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  // ── TAMBAH → FIREBASE ───────────────────────────────────────────────────────

  Future<void> addTransactionFull({
    required String title,
    required double amount,
    required String tipe,
    required String kategori,
    required String categoryId,
    required String akun,
    required DateTime tanggal,
    String notes = '',
    required VoidCallback onSuccess,
  }) async {
    try {
      final type = (tipe == 'pemasukan') ? 'income' : 'expense';
      final dateStr =
          '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';

      // 1. Simpan transaksi ke Firestore
      await FirebaseService.addTransaction({
        'category_id': categoryId,
        'type': type,
        'amount': amount.toInt(),
        'date': dateStr,
        'note': notes.isNotEmpty ? notes : title,
        'akun': akun,
      });

      // 2. Update saldo akun di Firestore
      final akunList = await FirebaseService.getAkun();
      final akunData = akunList.firstWhere(
        (a) => (a['nama'] ?? a['name'] ?? '') == akun,
        orElse: () => {},
      );
      if (akunData.isNotEmpty) {
        final akunId = akunData['id'] as String;
        final saldoLama = (akunData['saldo'] as num?)?.toInt() ?? 0;
        final saldoBaru = type == 'expense'
            ? saldoLama - amount.toInt()
            : saldoLama + amount.toInt();
        await FirebaseService.updateSaldoAkun(akunId, saldoBaru);
      }

      // 3. Reload tampilan transaksi & trigger home refresh
      await loadMonth(tanggal.year, tanggal.month);
      onSuccess();
    } catch (e) {
      debugPrint('addTransactionFull error: $e');
    }
  }

  // ── DELETE ──────────────────────────────────────────────────────────────────

  Future<void> deleteTransaction(String id, DateTime tanggal) async {
    await FirebaseService.deleteTransaction(id);
    await loadMonth(tanggal.year, tanggal.month);
  }
}

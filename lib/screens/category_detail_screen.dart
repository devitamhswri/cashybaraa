import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import '../services/firebase_service.dart';

const Color kBrown      = Color(0xFF4A3728);
const Color kBrownLight = Color(0xFF9E8F82);
const Color kBg         = Color(0xFFF5F0EA);

class CategoryDetailScreen extends StatefulWidget {
  final CategoryData category;
  final String type;
  final int month;
  final int year;

  const CategoryDetailScreen({
    super.key,
    required this.category,
    required this.type,
    required this.month,
    required this.year,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    final txs = await FirebaseService.getTransactions(
      month: widget.month,
      year: widget.year,
      categoryId: widget.category.id,
    );
    setState(() {
      _transactions = txs;
      _isLoading = false;
    });
  }

  String _formatRp(int num) {
    final s = num.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $s';
  }

  String _formatDate(String dateStr) {
    final d = DateTime.tryParse(dateStr);
    if (d == null) return dateStr;
    const bulan = ['','Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return '${d.day} ${bulan[d.month]} ${d.year}';
  }

  Future<void> _deleteTransaction(Map<String, dynamic> tx) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Transaksi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        content: const Text('Yakin ingin menghapus transaksi ini?', style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseService.deleteTransaction(tx['id']);

    // Kembalikan saldo ke akun jika expense
    if (tx['type'] == 'expense' && tx['akun'] != null) {
      final state = context.read<AppState>();
      final idx = state.akunList.indexWhere((a) => a.nama == tx['akun']);
      if (idx >= 0) {
        final saldoBaru = state.akunList[idx].saldo + (tx['amount'] as int);
        await FirebaseService.updateSaldoAkun(state.akunList[idx].id, saldoBaru);
      }
    }

    await context.read<AppState>().loadData();
    await _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.type == 'income';
    final cat = widget.category;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          // Header
          Container(
            color: kBrown,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(children: [
                        Icon(Icons.chevron_left, size: 18, color: Colors.white.withValues(alpha: 0.8)),
                        Text('Kembali', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: cat.bg, borderRadius: BorderRadius.circular(14)),
                      child: Center(child: Text(cat.icon, style: const TextStyle(fontSize: 24))),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text(isIncome ? 'Pemasukan' : 'Pengeluaran',
                            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  (isIncome ? '+' : '-') + _formatRp(cat.amount),
                  style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                Text('Total bulan ini',
                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.55))),
              ],
            ),
          ),

          // List transaksi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: kBrown, strokeWidth: 2))
                : _transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('📭', style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 12),
                            const Text('Belum ada transaksi di kategori ini',
                                style: TextStyle(fontSize: 13, color: kBrownLight)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: _transactions.length,
                        itemBuilder: (_, i) {
                          final tx = _transactions[i];
                          final amount = (tx['amount'] as num).toInt();
                          final note   = tx['note'] ?? '';
                          final akun   = tx['akun'] ?? '';
                          final date   = _formatDate(tx['date'] ?? '');

                          return Dismissible(
                            key: Key(tx['id']),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete_outline, color: Colors.white),
                            ),
                            confirmDismiss: (_) async {
                              await _deleteTransaction(tx);
                              return false; // kita handle sendiri
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 0.5),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42, height: 42,
                                    decoration: BoxDecoration(color: cat.bg, borderRadius: BorderRadius.circular(12)),
                                    child: Center(child: Text(cat.icon, style: const TextStyle(fontSize: 20))),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(note.isNotEmpty ? note : cat.name,
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D2218))),
                                        const SizedBox(height: 2),
                                        Text('$akun • $date',
                                            style: const TextStyle(fontSize: 11, color: kBrownLight)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    (isIncome ? '+' : '-') + _formatRp(amount),
                                    style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w700,
                                      color: isIncome ? const Color(0xFF43A047) : const Color(0xFFEF5350),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
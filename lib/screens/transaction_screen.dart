import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  DateTime _focusedDay  = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String _searchQuery   = '';
  bool _isSearching     = false;
  final _searchController = TextEditingController();

  static const Color kBrown = Color(0xFF4A3728);
  static const Color kBg    = Color(0xFFF5F0EA);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false)
          .loadMonth(_focusedDay.year, _focusedDay.month);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        // Filter berdasarkan search
        final allHariIni  = provider.getByDay(_selectedDay);
        final transaksiHariIni = _searchQuery.isEmpty
            ? allHariIni
            : provider.items.where((t) =>
                t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                t.kategori.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                t.akun.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

        final dotDays = provider.getDotDays(_focusedDay.year, _focusedDay.month);

        final pemasukanHari = transaksiHariIni
            .where((t) => t.tipe == 'income' || t.tipe == 'pemasukan')
            .fold(0.0, (sum, t) => sum + t.amount);
        final pengeluaranHari = transaksiHariIni
            .where((t) => t.tipe == 'expense' || t.tipe == 'pengeluaran')
            .fold(0.0, (sum, t) => sum + t.amount);
        final saldoHari = pemasukanHari - pengeluaranHari;

        return Scaffold(
          backgroundColor: kBg,
          body: Column(
            children: [
              Container(
                color: kBrown,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // ── Search bar ──────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, size: 16, color: Colors.white.withValues(alpha: 0.7)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  style: const TextStyle(fontSize: 13, color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Cari transaksi...',
                                    hintStyle: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5), fontStyle: FontStyle.italic),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (v) => setState(() {
                                    _searchQuery  = v;
                                    _isSearching  = v.isNotEmpty;
                                  }),
                                ),
                              ),
                              if (_isSearching)
                                GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() { _searchQuery = ''; _isSearching = false; });
                                  },
                                  child: Icon(Icons.close, size: 16, color: Colors.white.withValues(alpha: 0.7)),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Kalender (sembunyikan saat search) ─────────────
                      if (!_isSearching) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() { _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1); });
                                  provider.loadMonth(_focusedDay.year, _focusedDay.month);
                                },
                                child: const Icon(Icons.chevron_left, color: Colors.white),
                              ),
                              Text(
                                '${_namabulan(_focusedDay.month)} ${_focusedDay.year}',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() { _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1); });
                                  provider.loadMonth(_focusedDay.year, _focusedDay.month);
                                },
                                child: const Icon(Icons.chevron_right, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: ['Sen','Sel','Rab','Kam','Jum','Sab','Min']
                                .map((d) => Expanded(
                                  child: Center(
                                    child: Text(d, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w500)),
                                  ),
                                )).toList(),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: _buildCalendarGrid(dotDays),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // ── Summary ────────────────────────────────────────
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            _summaryItem('PEMASUKAN',   pemasukanHari,  const Color(0xFF7EE8A2)),
                            _divider(),
                            _summaryItem('PENGELUARAN', pengeluaranHari, const Color(0xFFF8A5A5)),
                            _divider(),
                            _summaryItem('SALDO',       saldoHari,      Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── List transaksi ─────────────────────────────────────────
              Expanded(
                child: transaksiHariIni.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🦦', style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 12),
                            Text(
                              _isSearching ? 'Tidak ada transaksi ditemukan' : 'Belum ada transaksi hari ini',
                              style: TextStyle(color: Colors.grey[500], fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                        children: [
                          if (!_isSearching)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_labelHari(_selectedDay),
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2D2218))),
                                  Text(
                                    saldoHari >= 0
                                        ? '+ ${_formatRp(saldoHari.abs().toInt())}'
                                        : '- ${_formatRp(saldoHari.abs().toInt())}',
                                    style: TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w600,
                                      color: saldoHari >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ...transaksiHariIni.map((t) => _buildTransaksiCard(t)),
                        ],
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: kBrown,
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
              if (mounted) provider.loadMonth(_focusedDay.year, _focusedDay.month);
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildCalendarGrid(Set<int> dotDays) {
    final firstDay    = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final offset      = (firstDay.weekday - 1) % 7;
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final rows        = ((offset + daysInMonth) / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Row(
          children: List.generate(7, (col) {
            final day = row * 7 + col - offset + 1;
            if (day < 1 || day > daysInMonth) return const Expanded(child: SizedBox(height: 36));
            final date       = DateTime(_focusedDay.year, _focusedDay.month, day);
            final isSelected = _isSameDay(date, _selectedDay);
            final isToday    = _isSameDay(date, DateTime.now());
            final hasDot     = dotDays.contains(day);

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDay = date),
                child: Container(
                  height: 36,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isToday && !isSelected ? Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$day', style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected ? const Color(0xFF4A3728) : Colors.white,
                      )),
                      if (hasDot) Container(width: 4, height: 4,
                          decoration: BoxDecoration(color: isSelected ? const Color(0xFF4A3728) : const Color(0xFFEF5350), shape: BoxShape.circle)),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildTransaksiCard(dynamic t) {
    final isPemasukan = t.tipe == 'income' || t.tipe == 'pemasukan';
    return Container(
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
            decoration: BoxDecoration(
              color: isPemasukan ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(t.iconEmoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D2218))),
                const SizedBox(height: 2),
                Text('${t.kategori} • ${t.akun}', style: const TextStyle(fontSize: 11, color: Color(0xFF9E8F82))),
              ],
            ),
          ),
          // ← WARNA MERAH untuk pengeluaran
          Text(
            '${isPemasukan ? '+' : '-'} ${_formatRp(t.amount.toInt())}',
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: isPemasukan ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, double amount, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.6), letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(_formatRp(amount.abs().toInt()), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.15));

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  String _namabulan(int m) => ['','Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'][m];

  String _labelHari(DateTime d) {
    final hari = ['','Sen','Sel','Rab','Kam','Jum','Sab','Min'][d.weekday];
    return '$hari, ${d.day} ${_namabulan(d.month).substring(0, 3)}';
  }

  String _formatRp(int num) {
    final s = num.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp $s';
  }
}
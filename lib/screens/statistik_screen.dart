import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../services/firebase_service.dart';
import 'app_state.dart';

const Color kBrown      = Color(0xFF4A3728);
const Color kBrownLight = Color(0xFF9E8F82);
const Color kBg         = Color(0xFFF5F0EA);
const Color kCard       = Colors.white;
const Color kKeluar     = Color(0xFFB85C38);
const Color kMasuk      = Color(0xFF6BAA8E);

class StatistikScreen extends StatefulWidget {
  const StatistikScreen({super.key});
  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  int _tab = 0;
  bool _isLoading = true;

  static const _tabs      = ['Mingguan', 'Bulanan', '3 Bulan', 'Tahunan'];
  static const _vsLabels  = ['minggu lalu', 'bulan lalu', '3 bulan lalu', 'tahun lalu'];
  static const _bulanNames = ['','Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];

  // ── Data hasil fetch ──────────────────────────────────────────────────────
  List<Map<String, dynamic>> _allTx = [];
  List<Map<String, dynamic>> _allCats = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      FirebaseService.getTransactions(),
      FirebaseService.getCategories(),
    ]);
    _allTx   = results[0] as List<Map<String, dynamic>>;
    _allCats = results[1] as List<Map<String, dynamic>>;
    if (mounted) setState(() => _isLoading = false);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatRp(int n) {
    if (n == 0) return 'Rp 0';
    if (n >= 1000000) return 'Rp ${(n / 1000000).toStringAsFixed(1).replaceAll('.0', '')}jt';
    if (n >= 1000)    return '${(n / 1000).toStringAsFixed(0)}rb';
    return 'Rp $n';
  }

  String _formatRpFull(int n) {
    return 'Rp ' + n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  List<Map<String, dynamic>> _txOfMonth(int month, int year) => _allTx.where((t) {
    final d = DateTime.tryParse(t['date'] ?? '');
    return d != null && d.month == month && d.year == year;
  }).toList();

  List<Map<String, dynamic>> _txOfWeek(DateTime start) {
    final end = start.add(const Duration(days: 6));
    return _allTx.where((t) {
      final d = DateTime.tryParse(t['date'] ?? '');
      return d != null && !d.isBefore(start) && !d.isAfter(end);
    }).toList();
  }

  int _sumType(List<Map<String, dynamic>> txs, String type) =>
      txs.where((t) => t['type'] == type).fold(0, (s, t) => s + (t['amount'] as int));

  // ── Range label di header ─────────────────────────────────────────────────

  String _rangeLabel() {
    final now = DateTime.now();
    switch (_tab) {
      case 0: // mingguan — 7 hari ke belakang
        final start = now.subtract(Duration(days: now.weekday - 1));
        return '${start.day}–${now.day} ${_bulanNames[now.month].toLowerCase()}';
      case 1: return '${_bulanNames[now.month]} ${now.year}';
      case 2:
        final m1 = DateTime(now.year, now.month - 2);
        return '${_bulanNames[m1.month]}–${_bulanNames[now.month]} ${now.year}';
      case 3: return '${now.year}';
      default: return '';
    }
  }

  // ── Summary header values ─────────────────────────────────────────────────

  (int keluar, int masuk) _headerSummary() {
    final now   = DateTime.now();
    List<Map<String, dynamic>> txs;
    switch (_tab) {
      case 0:
        final start = now.subtract(Duration(days: now.weekday - 1));
        txs = _txOfWeek(start);
        break;
      case 1:
        txs = _txOfMonth(now.month, now.year);
        break;
      case 2:
        txs = [
          ..._txOfMonth(now.month, now.year),
          ..._txOfMonth(now.month - 1 < 1 ? 12 : now.month - 1, now.month - 1 < 1 ? now.year - 1 : now.year),
          ..._txOfMonth(now.month - 2 < 1 ? 12 : now.month - 2, now.month - 2 < 1 ? now.year - 1 : now.year),
        ];
        break;
      case 3:
        txs = _allTx.where((t) {
          final d = DateTime.tryParse(t['date'] ?? '');
          return d != null && d.year == now.year;
        }).toList();
        break;
      default: txs = [];
    }
    return (_sumType(txs, 'expense'), _sumType(txs, 'income'));
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [
        _buildHeader(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: kBrown, strokeWidth: 2))
              : RefreshIndicator(
                  onRefresh: _loadAll,
                  color: kBrown,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: _buildContent(),
                  ),
                ),
        ),
      ]),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final (keluar, masuk) = _isLoading ? (0, 0) : _headerSummary();

    return Container(
      color: kBrown,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Statistik\nKeuangan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, height: 1.25)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_rangeLabel(),
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 16),

        // Tab
        Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(3),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final sel = _tab == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(_tabs[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: sel ? kBrown : Colors.white.withOpacity(0.6),
                        )),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 14),

        // Summary
        Row(children: [
          Expanded(child: _summaryTile('Pengeluaran', _formatRpFull(keluar), _vsLabels[_tab], false)),
          const SizedBox(width: 10),
          Expanded(child: _summaryTile('Pemasukan', _formatRpFull(masuk), _vsLabels[_tab], true)),
        ]),
      ]),
    );
  }

  Widget _summaryTile(String label, String amount, String sub, bool isIncome) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: isIncome ? kMasuk : const Color(0xFFF8A5A5))),
        const SizedBox(height: 4),
        Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 2),
        Text('vs $sub', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.55))),
      ]),
    );
  }

  // ── Content ───────────────────────────────────────────────────────────────

  Widget _buildContent() {
    switch (_tab) {
      case 0: return _buildMingguan();
      case 1: return _buildBulanan();
      case 2: return _buildTigaBulan();
      case 3: return _buildTahunan();
      default: return const SizedBox();
    }
  }

  // ── TAB 0: MINGGUAN ───────────────────────────────────────────────────────

  Widget _buildMingguan() {
    final now   = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1)); // Senin minggu ini

    final labels    = ['Sen','Sel','Rab','Kam','Jum','Sab','Min'];
    final keluarData = List<double>.filled(7, 0);
    final masukData  = List<double>.filled(7, 0);
    final heatmap    = List<int>.filled(7, 0);

    for (final t in _allTx) {
      final d = DateTime.tryParse(t['date'] ?? '');
      if (d == null) continue;
      final diff = d.difference(start).inDays;
      if (diff < 0 || diff > 6) continue;
      final amt = (t['amount'] as int).toDouble();
      if (t['type'] == 'expense') {
        keluarData[diff] += amt;
        heatmap[diff]++;
      } else {
        masukData[diff] += amt;
      }
    }

    // Heatmap — normalisasi 0-4
    final maxH = heatmap.fold(0, math.max);
    final heatNorm = heatmap.map((v) => maxH > 0 ? ((v / maxH) * 4).round() : 0).toList();

    return Column(children: [
      _card(
        title: 'Pengeluaran Harian',
        trailing: _legendRow(),
        child: _BarChart(labels: labels, keluarData: keluarData, masukData: masukData, formatVal: _formatRp),
      ),
      const SizedBox(height: 14),
      _card(
        title: 'Aktivitas Minggu Ini',
        trailing: Text('${_bulanNames[start.month]} ${start.year}',
            style: TextStyle(fontSize: 11, color: kBrown.withOpacity(0.7), fontWeight: FontWeight.w600)),
        child: _Heatmap(data: heatNorm, dayLabels: labels, startOffset: 0),
      ),
    ]);
  }

  // ── TAB 1: BULANAN ────────────────────────────────────────────────────────

  Widget _buildBulanan() {
    final now   = DateTime.now();
    final txs   = _txOfMonth(now.month, now.year);

    // Per minggu (4 minggu)
    final mingguLabels  = ['Mg 1','Mg 2','Mg 3','Mg 4'];
    final mgKeluar      = List<double>.filled(4, 0);
    final mgMasuk       = List<double>.filled(4, 0);

    for (final t in txs) {
      final d   = DateTime.tryParse(t['date'] ?? '')!;
      final mg  = ((d.day - 1) / 7).floor().clamp(0, 3);
      final amt = (t['amount'] as int).toDouble();
      if (t['type'] == 'expense') mgKeluar[mg] += amt;
      else mgMasuk[mg] += amt;
    }

    // Breakdown per kategori
    final catMap = <String, Map<String, dynamic>>{};
    for (final c in _allCats) { catMap[c['id']] = c; }

    final catTotals = <String, int>{};
    final totalKeluar = _sumType(txs, 'expense');
    for (final t in txs.where((t) => t['type'] == 'expense')) {
      final cid = t['category_id'] ?? '';
      catTotals[cid] = (catTotals[cid] ?? 0) + (t['amount'] as int);
    }

    final sorted = catTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topCats = sorted.take(4).toList();

    final breakdown = topCats.map((e) {
      final cat = catMap[e.key];
      final pct = totalKeluar > 0 ? ((e.value / totalKeluar) * 100).round() : 0;
      return {
        'nama':  cat?['name'] ?? 'Lainnya',
        'icon':  cat?['icon'] ?? '💰',
        'color': _hexColor(cat?['color'], kKeluar),
        'bg':    _hexColor(cat?['bg_color'], const Color(0xFFFFF3E0)),
        'pct':   pct,
        'amount': e.value,
      };
    }).toList();

    return Column(children: [
      _card(
        title: 'Pengeluaran per Minggu',
        trailing: _legendRow(),
        child: _BarChart(labels: mingguLabels, keluarData: mgKeluar, masukData: mgMasuk, formatVal: _formatRp),
      ),
      if (breakdown.isNotEmpty) ...[
        const SizedBox(height: 14),
        _card(
          title: 'Breakdown Kategori',
          child: _DonutBreakdown(items: breakdown, totalKeluar: totalKeluar, formatRp: _formatRp),
        ),
        const SizedBox(height: 14),
        _card(
          title: 'Top Pengeluaran Bulan Ini',
          child: Column(
            children: breakdown.take(3).map((t) => _TopItem(
              icon: t['icon'] as String,
              bg: t['bg'] as Color,
              iconColor: t['color'] as Color,
              nama: t['nama'] as String,
              amount: t['amount'] as int,
              formatRp: _formatRpFull,
            )).toList(),
          ),
        ),
      ],
    ]);
  }

  // ── TAB 2: 3 BULAN ───────────────────────────────────────────────────────

  Widget _buildTigaBulan() {
    final now = DateTime.now();
    final months = [
      DateTime(now.year, now.month - 2),
      DateTime(now.year, now.month - 1),
      DateTime(now.year, now.month),
    ];

    final labels     = months.map((m) => _bulanNames[m.month]).toList();
    final keluarData = months.map((m) => _sumType(_txOfMonth(m.month, m.year), 'expense').toDouble()).toList();
    final masukData  = months.map((m) => _sumType(_txOfMonth(m.month, m.year), 'income').toDouble()).toList();

    // Per kategori 3 bulan
    final catMap = <String, Map<String, dynamic>>{};
    for (final c in _allCats) { catMap[c['id']] = c; }

    // Ambil top 3 kategori expense bulan ini
    final txsNow     = _txOfMonth(now.month, now.year);
    final catTotals  = <String, int>{};
    for (final t in txsNow.where((t) => t['type'] == 'expense')) {
      final cid = t['category_id'] ?? '';
      catTotals[cid] = (catTotals[cid] ?? 0) + (t['amount'] as int);
    }
    final topIds = (catTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .take(3).map((e) => e.key).toList();

    final katRows = topIds.map((cid) {
      final cat = catMap[cid];
      return {
        'icon': cat?['icon'] ?? '💰',
        'nama': cat?['name'] ?? 'Lainnya',
        'vals': months.map((m) {
          final txs = _txOfMonth(m.month, m.year);
          return txs.where((t) => t['category_id'] == cid && t['type'] == 'expense')
              .fold(0, (s, t) => s + (t['amount'] as int));
        }).toList(),
      };
    }).toList();

    return Column(children: [
      _card(
        title: 'Perbandingan 3 Bulan',
        trailing: _legendRow(),
        child: _BarChart(labels: labels, keluarData: keluarData, masukData: masukData, formatVal: _formatRp),
      ),
      if (katRows.isNotEmpty) ...[
        const SizedBox(height: 14),
        _card(
          title: 'Perbandingan Kategori',
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            _colLabel(labels[0]), const SizedBox(width: 8),
            _colLabel(labels[1]), const SizedBox(width: 8),
            _colLabel(labels[2]),
          ]),
          child: Column(
            children: katRows.map((k) => _KategoriRow3(
              icon: k['icon'] as String,
              nama: k['nama'] as String,
              vals: k['vals'] as List<int>,
              labels: labels,
              formatRp: _formatRp,
            )).toList(),
          ),
        ),
      ],
    ]);
  }

  // ── TAB 3: TAHUNAN ───────────────────────────────────────────────────────

  Widget _buildTahunan() {
    final now  = DateTime.now();
    final data = List.generate(12, (i) =>
        _sumType(_txOfMonth(i + 1, now.year), 'expense'));

    return _card(
      title: 'Pengeluaran per Bulan',
      trailing: Text('${now.year}',
          style: TextStyle(fontSize: 11, color: kBrown.withOpacity(0.7), fontWeight: FontWeight.w600)),
      child: _MonthGrid(data: data, labels: const ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'], formatRp: _formatRp),
    );
  }

  // ── Shared ────────────────────────────────────────────────────────────────

  Color _hexColor(dynamic hex, Color fallback) {
    if (hex == null) return fallback;
    try { return Color(int.parse(hex.toString().replaceAll('#', '0xFF'))); }
    catch (_) { return fallback; }
  }

  Widget _card({required String title, Widget? trailing, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: kCard, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2D2218))),
          if (trailing != null) trailing,
        ]),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }

  Widget _legendRow() => Row(mainAxisSize: MainAxisSize.min, children: [
    _dot(kKeluar), const SizedBox(width: 4),
    Text('Keluar', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
    const SizedBox(width: 10),
    _dot(kMasuk), const SizedBox(width: 4),
    Text('Masuk', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
  ]);

  Widget _dot(Color c) => Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  Widget _colLabel(String text) => Text(text,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: kBrown.withOpacity(0.6)));
}

// ── BAR CHART ─────────────────────────────────────────────────────────────────

class _BarChart extends StatelessWidget {
  final List<String> labels;
  final List<double> keluarData;
  final List<double> masukData;
  final String Function(int) formatVal;

  const _BarChart({required this.labels, required this.keluarData, required this.masukData, required this.formatVal});

  @override
  Widget build(BuildContext context) {
    final maxVal = [...keluarData, ...masukData].fold(0.0, math.max);
    if (maxVal == 0) return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text('Belum ada data', style: TextStyle(fontSize: 12, color: kBrownLight)),
      ),
    );

    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(labels.length, (i) {
          final kH = (keluarData[i] / maxVal) * 100;
          final mH = (masukData[i]  / maxVal) * 100;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (keluarData[i] > 0) _Bar(height: kH, color: kKeluar),
                  const SizedBox(width: 2),
                  if (masukData[i] > 0) _Bar(height: mH, color: kMasuk),
                ],
              )),
              const SizedBox(height: 6),
              Text(labels[i], style: const TextStyle(fontSize: 9, color: kBrownLight)),
            ],
          );
        }),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final Color color;
  const _Bar({required this.height, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: 14, height: height.clamp(4, 100),
    decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
  );
}

// ── HEATMAP ───────────────────────────────────────────────────────────────────

class _Heatmap extends StatelessWidget {
  final List<int> data;
  final List<String> dayLabels;
  final int startOffset;
  const _Heatmap({required this.data, required this.dayLabels, required this.startOffset});

  Color _cellColor(int v) {
    switch (v) {
      case 0: return const Color(0xFFF5F0EA);
      case 1: return const Color(0xFFE8C9A8);
      case 2: return const Color(0xFFD4A574);
      case 3: return const Color(0xFFB87840);
      case 4: return const Color(0xFF7A4A1C);
      default: return const Color(0xFFF5F0EA);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCells = startOffset + data.length;
    final rows = (totalCells / 7).ceil();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: dayLabels.map((d) => Expanded(
        child: Text(d, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: kBrownLight)),
      )).toList()),
      const SizedBox(height: 6),
      ...List.generate(rows, (row) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: List.generate(7, (col) {
          final cellIdx = row * 7 + col;
          final dayIdx  = cellIdx - startOffset;
          final inRange = dayIdx >= 0 && dayIdx < data.length;
          return Expanded(child: Container(
            height: 28, margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: inRange ? _cellColor(data[dayIdx]) : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
            ),
          ));
        })),
      )),
    ]);
  }
}

// ── DONUT BREAKDOWN ───────────────────────────────────────────────────────────

class _DonutBreakdown extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final int totalKeluar;
  final String Function(int) formatRp;
  const _DonutBreakdown({required this.items, required this.totalKeluar, required this.formatRp});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      SizedBox(
        width: 100, height: 100,
        child: CustomPaint(
          painter: _DonutPainter(items),
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(formatRp(totalKeluar),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kBrown)),
            const Text('total\nkeluar', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 9, color: kBrownLight)),
          ])),
        ),
      ),
      const SizedBox(width: 20),
      Expanded(child: Column(
        children: items.map((k) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Container(width: 8, height: 8,
                decoration: BoxDecoration(color: k['color'] as Color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(k['nama'] as String,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2D2218))),
                Text('${k['pct']}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2D2218))),
              ]),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (k['pct'] as int) / 100,
                  minHeight: 3,
                  backgroundColor: const Color(0xFFF0E9E2),
                  valueColor: AlwaysStoppedAnimation<Color>(k['color'] as Color),
                ),
              ),
            ])),
          ]),
        )).toList(),
      )),
    ]);
  }
}

class _DonutPainter extends CustomPainter {
  final List<Map<String, dynamic>> items;
  _DonutPainter(this.items);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    double startAngle = -math.pi / 2;
    for (final item in items) {
      final sweep = 2 * math.pi * (item['pct'] as int) / 100;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweep - 0.04, false,
        Paint()..color = item['color'] as Color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 14
              ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweep;
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

// ── TOP ITEM ──────────────────────────────────────────────────────────────────

class _TopItem extends StatelessWidget {
  final String icon, nama;
  final Color bg, iconColor;
  final int amount;
  final String Function(int) formatRp;
  const _TopItem({required this.icon, required this.nama, required this.bg, required this.iconColor, required this.amount, required this.formatRp});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(children: [
      Container(width: 38, height: 38,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 18)))),
      const SizedBox(width: 12),
      Expanded(child: Text(nama, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D2218)))),
      Text(formatRp(amount), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: iconColor)),
    ]),
  );
}

// ── 3 BULAN KATEGORI ROW ─────────────────────────────────────────────────────

class _KategoriRow3 extends StatelessWidget {
  final String icon, nama;
  final List<int> vals;
  final List<String> labels;
  final String Function(int) formatRp;
  const _KategoriRow3({required this.icon, required this.nama, required this.vals, required this.labels, required this.formatRp});

  @override
  Widget build(BuildContext context) {
    final maxVal = vals.fold(0, math.max).toDouble();
    final colors = [const Color(0xFFD4A574), kKeluar, kMasuk];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(nama, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2D2218))),
        ]),
        const SizedBox(height: 6),
        ...List.generate(vals.length, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(children: [
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: maxVal > 0 ? vals[i] / maxVal : 0,
                minHeight: 8,
                backgroundColor: const Color(0xFFF0E9E2),
                valueColor: AlwaysStoppedAnimation<Color>(colors[i]),
              ),
            )),
            const SizedBox(width: 8),
            Text(formatRp(vals[i]),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                    color: i == vals.length - 1 ? kBrown : kBrownLight)),
          ]),
        )),
      ]),
    );
  }
}

// ── MONTH GRID ────────────────────────────────────────────────────────────────

class _MonthGrid extends StatelessWidget {
  final List<int> data;
  final List<String> labels;
  final String Function(int) formatRp;
  const _MonthGrid({required this.data, required this.labels, required this.formatRp});

  @override
  Widget build(BuildContext context) {
    final now    = DateTime.now();
    final maxVal = data.fold(0, math.max).toDouble();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, childAspectRatio: 1.6, crossAxisSpacing: 10, mainAxisSpacing: 10,
      ),
      itemCount: 12,
      itemBuilder: (_, i) {
        final isNow    = i + 1 == now.month;
        final hasData  = data[i] > 0;
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isNow ? const Color(0xFFFFF8F0) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isNow ? kBrown.withOpacity(0.3) : Colors.transparent),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(labels[i], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  color: isNow ? kBrown : const Color(0xFF2D2218))),
              if (isNow) ...[const SizedBox(width: 3), const Text('✨', style: TextStyle(fontSize: 10))],
            ]),
            const Spacer(),
            if (hasData) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: maxVal > 0 ? data[i] / maxVal : 0,
                  minHeight: 3,
                  backgroundColor: const Color(0xFFF0E9E2),
                  valueColor: AlwaysStoppedAnimation<Color>(isNow ? kMasuk : kKeluar),
                ),
              ),
              const SizedBox(height: 4),
              Text(formatRp(data[i]),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: isNow ? kBrown : const Color(0xFF2D2218))),
            ] else
              Text('—', style: TextStyle(fontSize: 11, color: Colors.grey[300])),
          ]),
        );
      },
    );
  }
}
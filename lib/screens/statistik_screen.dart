import 'package:flutter/material.dart';
import 'dart:math' as math;

const Color kBrown      = Color(0xFF4A3728);
const Color kBrownLight = Color(0xFF9E8F82);
const Color kBg         = Color(0xFFF5F0EA);
const Color kCard       = Colors.white;
const Color kKeluar     = Color(0xFFB85C38);
const Color kMasuk      = Color(0xFF6BAA8E);

// ── DUMMY DATA ─────────────────────────────────────────────────────────────────

// Mingguan — per hari (Sen-Min)
const _hariLabels = ['Sen','Sel','Rab','Kam','Jum','Sab','Min'];
const _mingguanKeluar = [120000, 85000, 310000, 275000, 190000, 420000, 95000];
const _mingguanMasuk  = [0, 0, 0, 500000, 0, 0, 200000];

// Bulanan — per minggu
const _mingguLabels = ['Mg 1','Mg 2','Mg 3','Mg 4'];
const _bulananKeluar = [380000, 420000, 275000, 575000];
const _bulananMasuk  = [500000, 200000, 800000, 300000];

// 3 bulan — per bulan
const _tigaBulanLabels  = ['Februari','Maret','April'];
const _tigaBulanKeluar  = [1500000, 2100000, 1000000];
const _tigaBulanMasuk   = [3000000, 2500000, 5000000];

// Tahunan — per bulan (Jan-Des)
const _bulanLabels  = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
const _tahunanKeluar = [1800000, 1500000, 2100000, 650000, 0, 0, 0, 0, 0, 0, 0, 0];

// Breakdown kategori (bulanan)
const _kategoriBreakdown = [
  {'nama': 'Makanan',   'icon': '🍔', 'color': kKeluar,          'pct': 50, 'amount': 325000},
  {'nama': 'Transport', 'icon': '🚗', 'color': Color(0xFF42A5F5), 'pct': 27, 'amount': 176000},
  {'nama': 'Belanja',   'icon': '🛍', 'color': Color(0xFFEC407A), 'pct': 14, 'amount': 89000},
  {'nama': 'Kesehatan', 'icon': '❤️', 'color': Color(0xFF66BB6A), 'pct': 9,  'amount': 62500},
];

// Top pengeluaran bulan ini
const _topPengeluaran = [
  {'nama': 'Makanan & Minuman', 'icon': '🍔', 'color': Color(0xFFFFF3E0), 'iconColor': kKeluar,          'amount': 325000},
  {'nama': 'Transportasi',      'icon': '🚗', 'color': Color(0xFFE3F2FD), 'iconColor': Color(0xFF42A5F5), 'amount': 176000},
  {'nama': 'Belanja',           'icon': '🛍', 'color': Color(0xFFFCE4EC), 'iconColor': Color(0xFFEC407A), 'amount': 89000},
];

// 3 bulan kategori breakdown
const _tigaBulanKategori = [
  {'nama': 'Makanan',   'icon': '🍔', 'feb': 380000, 'mar': 420000, 'apr': 325000},
  {'nama': 'Transport', 'icon': '🚗', 'feb': 150000, 'mar': 210000, 'apr': 176000},
  {'nama': 'Belanja',   'icon': '🛍', 'feb': 200000, 'mar': 120000, 'apr': 89000},
];

// Heatmap April 2026 — intensitas 0-4 per hari (1=Apr, 30=Apr)
final _heatmapData = List.generate(30, (i) {
  final rng = math.Random(i * 7 + 3);
  return rng.nextInt(5); // 0-4
});

// ── STATISTIK SCREEN ──────────────────────────────────────────────────────────

class StatistikScreen extends StatefulWidget {
  const StatistikScreen({super.key});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  int _tab = 0; // 0=Mingguan, 1=Bulanan, 2=3Bulan, 3=Tahunan

  static const _tabs = ['Mingguan', 'Bulanan', '3 Bulan', 'Tahunan'];
  static const _vsLabels = ['minggu lalu', 'bulan lalu', '3 bulan lalu', 'tahun lalu'];

  String _formatRp(int n) {
    if (n == 0) return 'Rp 0';
    if (n >= 1000000) return 'Rp ${(n / 1000000).toStringAsFixed(1).replaceAll('.0', '')}jt';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}rb';
    return 'Rp $n';
  }

  String _formatRpFull(int n) {
    return 'Rp ' + n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: _buildContent(),
          ),
        ),
      ]),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: kBrown,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Title + date range
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Statistik\nKeuangan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, height: 1.25)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.chevron_left, size: 16, color: Colors.white.withOpacity(0.8)),
              const SizedBox(width: 4),
              Text('21 - 27 apr',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 16, color: Colors.white.withOpacity(0.8)),
            ]),
          ),
        ]),

        const SizedBox(height: 16),

        // Tab filter
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
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

        // Pengeluaran vs Pemasukan summary
        Row(children: [
          Expanded(child: _summaryTile('Pengeluaran', 'Rp 1.000.000', '12% vs ${_vsLabels[_tab]}', false)),
          const SizedBox(width: 10),
          Expanded(child: _summaryTile('Pemasukan', 'Rp 12.000.000', '8% vs ${_vsLabels[_tab]}', true)),
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
        Text(label,
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: isIncome ? kMasuk : const Color(0xFFF8A5A5),
            )),
        const SizedBox(height: 4),
        Text(amount,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 2),
        Text(sub, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.55))),
      ]),
    );
  }

  // ── Content per tab ─────────────────────────────────────────────────────────

  Widget _buildContent() {
    switch (_tab) {
      case 0: return _buildMingguan();
      case 1: return _buildBulanan();
      case 2: return _buildTigaBulan();
      case 3: return _buildTahunan();
      default: return const SizedBox();
    }
  }

  // ── TAB 0: MINGGUAN ─────────────────────────────────────────────────────────

  Widget _buildMingguan() {
    return Column(children: [
      _card(
        title: 'Pengeluaran Harian',
        trailing: _legendRow(),
        child: _BarChart(
          labels: _hariLabels,
          keluarData: _mingguanKeluar.map((e) => e.toDouble()).toList(),
          masukData:  _mingguanMasuk.map((e) => e.toDouble()).toList(),
          formatVal: _formatRp,
        ),
      ),
      const SizedBox(height: 14),
      _card(
        title: 'Heatmap Pengeluaran',
        trailing: Text('April 2026',
            style: TextStyle(fontSize: 11, color: kBrown.withOpacity(0.7), fontWeight: FontWeight.w600)),
        child: _Heatmap(data: _heatmapData),
      ),
    ]);
  }

  // ── TAB 1: BULANAN ──────────────────────────────────────────────────────────

  Widget _buildBulanan() {
    return Column(children: [
      _card(
        title: 'Pengeluaran per Minggu',
        trailing: _legendRow(),
        child: _BarChart(
          labels: _mingguLabels,
          keluarData: _bulananKeluar.map((e) => e.toDouble()).toList(),
          masukData:  _bulananMasuk.map((e) => e.toDouble()).toList(),
          formatVal: _formatRp,
        ),
      ),
      const SizedBox(height: 14),
      _card(
        title: 'Breakdown Kategori',
        child: _DonutBreakdown(items: _kategoriBreakdown, formatRp: _formatRp),
      ),
      const SizedBox(height: 14),
      _card(
        title: 'Top Pengeluaran per Bulan',
        child: Column(
          children: _topPengeluaran.map((t) => _TopItem(
            icon: t['icon'] as String,
            bg: t['color'] as Color,
            iconColor: t['iconColor'] as Color,
            nama: t['nama'] as String,
            amount: t['amount'] as int,
            formatRp: _formatRpFull,
          )).toList(),
        ),
      ),
    ]);
  }

  // ── TAB 2: 3 BULAN ──────────────────────────────────────────────────────────

  Widget _buildTigaBulan() {
    return Column(children: [
      _card(
        title: 'Perbandingan 3 Bulan',
        trailing: _legendRow(),
        child: _BarChart(
          labels: _tigaBulanLabels,
          keluarData: _tigaBulanKeluar.map((e) => e.toDouble()).toList(),
          masukData:  _tigaBulanMasuk.map((e) => e.toDouble()).toList(),
          formatVal: _formatRp,
        ),
      ),
      const SizedBox(height: 14),
      _card(
        title: 'Perbandingan Kategori',
        trailing: Row(mainAxisSize: MainAxisSize.min, children: const [
          _ColLabel('Feb'), SizedBox(width: 8),
          _ColLabel('Mar'), SizedBox(width: 8),
          _ColLabel('Apr'),
        ]),
        child: Column(
          children: _tigaBulanKategori.map((k) => _KategoriRow3(
            icon: k['icon'] as String,
            nama: k['nama'] as String,
            feb:  k['feb']  as int,
            mar:  k['mar']  as int,
            apr:  k['apr']  as int,
            formatRp: _formatRp,
          )).toList(),
        ),
      ),
    ]);
  }

  // ── TAB 3: TAHUNAN ──────────────────────────────────────────────────────────

  Widget _buildTahunan() {
    return Column(children: [
      _card(
        title: 'Pengeluaran per Bulan',
        trailing: Text('2026',
            style: TextStyle(fontSize: 11, color: kBrown.withOpacity(0.7), fontWeight: FontWeight.w600)),
        child: _MonthGrid(data: _tahunanKeluar, labels: _bulanLabels, formatRp: _formatRp),
      ),
    ]);
  }

  // ── Shared card wrapper ─────────────────────────────────────────────────────

  Widget _card({required String title, Widget? trailing, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(18),
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

  Widget _legendRow() {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      _dot(kKeluar), const SizedBox(width: 4),
      Text('Keluar', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      const SizedBox(width: 10),
      _dot(kMasuk), const SizedBox(width: 4),
      Text('Masuk', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
    ]);
  }

  Widget _dot(Color c) => Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle));
}

// ── BAR CHART ─────────────────────────────────────────────────────────────────

class _BarChart extends StatelessWidget {
  final List<String> labels;
  final List<double> keluarData;
  final List<double> masukData;
  final String Function(int) formatVal;

  const _BarChart({
    required this.labels,
    required this.keluarData,
    required this.masukData,
    required this.formatVal,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = [...keluarData, ...masukData].fold(0.0, math.max);
    if (maxVal == 0) return const SizedBox(height: 120);

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
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (keluarData[i] > 0)
                      _Bar(height: kH, color: kKeluar),
                    const SizedBox(width: 2),
                    if (masukData[i] > 0)
                      _Bar(height: mH, color: kMasuk),
                  ],
                ),
              ),
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
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: height.clamp(4, 100),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}

// ── HEATMAP ───────────────────────────────────────────────────────────────────

class _Heatmap extends StatelessWidget {
  final List<int> data; // 30 values 0-4
  const _Heatmap({required this.data});

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
    const days = ['Sen','Sel','Rab','Kam','Jum','Sab','Min'];
    // April 2026 mulai hari Rabu (index 2)
    const startOffset = 2;
    final totalCells  = startOffset + 30;
    final rows        = (totalCells / 7).ceil();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Day headers
      Row(children: days.map((d) => Expanded(
        child: Text(d, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: kBrownLight)),
      )).toList()),
      const SizedBox(height: 6),

      // Grid
      ...List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(children: List.generate(7, (col) {
            final cellIdx = row * 7 + col;
            final dayIdx  = cellIdx - startOffset;
            final inRange = dayIdx >= 0 && dayIdx < 30;

            return Expanded(
              child: Container(
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: inRange ? _cellColor(data[dayIdx]) : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            );
          })),
        );
      }),
    ]);
  }
}

// ── DONUT + BREAKDOWN ─────────────────────────────────────────────────────────

class _DonutBreakdown extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String Function(int) formatRp;
  const _DonutBreakdown({required this.items, required this.formatRp});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      // Donut
      SizedBox(
        width: 100, height: 100,
        child: CustomPaint(
          painter: _DonutPainter(items),
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(formatRp(650000),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kBrown)),
            const Text('total\nkeluar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 9, color: kBrownLight)),
          ])),
        ),
      ),
      const SizedBox(width: 20),

      // List
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
    const strokeW = 14.0;
    double startAngle = -math.pi / 2;

    for (final item in items) {
      final sweep = 2 * math.pi * (item['pct'] as int) / 100;
      final paint = Paint()
        ..color = item['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweep - 0.04, false, paint,
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

  const _TopItem({
    required this.icon, required this.nama, required this.bg,
    required this.iconColor, required this.amount, required this.formatRp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(children: [
        Container(width: 38, height: 38,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 18)))),
        const SizedBox(width: 12),
        Expanded(child: Text(nama,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D2218)))),
        Text(formatRp(amount),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: iconColor)),
      ]),
    );
  }
}

// ── 3 BULAN KATEGORI ROW ──────────────────────────────────────────────────────

class _KategoriRow3 extends StatelessWidget {
  final String icon, nama;
  final int feb, mar, apr;
  final String Function(int) formatRp;

  const _KategoriRow3({
    required this.icon, required this.nama,
    required this.feb, required this.mar, required this.apr,
    required this.formatRp,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = [feb, mar, apr].fold(0, math.max).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(nama, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2D2218))),
        ]),
        const SizedBox(height: 6),
        _BarRow3(val: feb, max: maxVal, color: const Color(0xFFD4A574), label: formatRp(feb)),
        const SizedBox(height: 3),
        _BarRow3(val: mar, max: maxVal, color: kKeluar,                  label: formatRp(mar)),
        const SizedBox(height: 3),
        _BarRow3(val: apr, max: maxVal, color: kMasuk,                   label: formatRp(apr), isLatest: true),
      ]),
    );
  }
}

class _BarRow3 extends StatelessWidget {
  final int val;
  final double max;
  final Color color;
  final String label;
  final bool isLatest;

  const _BarRow3({
    required this.val, required this.max, required this.color,
    required this.label, this.isLatest = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: max > 0 ? val / max : 0,
            minHeight: 8,
            backgroundColor: const Color(0xFFF0E9E2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Row(children: [
        Text(label,
            style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: isLatest ? kBrown : kBrownLight,
            )),
        if (isLatest) ...[
          const SizedBox(width: 2),
          const Icon(Icons.arrow_drop_down, size: 14, color: Color(0xFFEF5350)),
        ],
      ]),
    ]);
  }
}

class _ColLabel extends StatelessWidget {
  final String text;
  const _ColLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: kBrown.withOpacity(0.6)));
  }
}

// ── MONTH GRID (TAHUNAN) ──────────────────────────────────────────────────────

class _MonthGrid extends StatelessWidget {
  final List<int> data;
  final List<String> labels;
  final String Function(int) formatRp;

  const _MonthGrid({required this.data, required this.labels, required this.formatRp});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 12,
      itemBuilder: (_, i) {
        final isNow     = i + 1 == now.month;
        final hasDatata = data[i] > 0;
        final maxVal    = data.fold(0, math.max).toDouble();

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isNow ? const Color(0xFFFFF8F0) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isNow ? kBrown.withOpacity(0.3) : Colors.transparent,
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(labels[i],
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: isNow ? kBrown : const Color(0xFF2D2218),
                  )),
              if (isNow) ...[
                const SizedBox(width: 3),
                const Text('✨', style: TextStyle(fontSize: 10)),
              ],
            ]),
            const Spacer(),
            if (hasDatata) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: maxVal > 0 ? data[i] / maxVal : 0,
                  minHeight: 3,
                  backgroundColor: const Color(0xFFF0E9E2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isNow ? kMasuk : kKeluar,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(formatRp(data[i]),
                  style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: isNow ? kBrown : const Color(0xFF2D2218),
                  )),
            ] else
              Text('—', style: TextStyle(fontSize: 11, color: Colors.grey[300])),
          ]),
        );
      },
    );
  }
}
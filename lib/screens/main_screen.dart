import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'transaction_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const TransactionScreen(),
    const Center(child: Text("Halaman Statistik")),
    const Center(child: Text("Halaman Budget")),
  ];

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: _CashyBaraNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ── CUSTOM NAVBAR ─────────────────────────────────────────────────────────────

class _CashyBaraNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _CashyBaraNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                index: 0,
                selectedIndex: selectedIndex,
                label: 'Beranda',
                icon: _NavIcon.beranda,
                onTap: onTap,
              ),
              _NavItem(
                index: 1,
                selectedIndex: selectedIndex,
                label: 'Transaksi',
                icon: _NavIcon.transaksi,
                onTap: onTap,
              ),
              _NavItem(
                index: 2,
                selectedIndex: selectedIndex,
                label: 'Statistik',
                icon: _NavIcon.statistik,
                onTap: onTap,
              ),
              _NavItem(
                index: 3,
                selectedIndex: selectedIndex,
                label: 'Budget',
                icon: _NavIcon.budget,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final String label;
  final _NavIcon icon;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.selectedIndex,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    const activeColor = Color(0xFF41241A);
    const inactiveColor = Color(0xFFB0A090);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: _NavSvgIcon(
                icon: icon,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? activeColor : inactiveColor,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ── CUSTOM PAINTED ICONS (mirip desain illustrated outline) ───────────────────

enum _NavIcon { beranda, transaksi, statistik, budget }

class _NavSvgIcon extends StatelessWidget {
  final _NavIcon icon;
  final Color color;

  const _NavSvgIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 28),
      painter: _IconPainter(icon: icon, color: color),
    );
  }
}

class _IconPainter extends CustomPainter {
  final _NavIcon icon;
  final Color color;

  _IconPainter({required this.icon, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    switch (icon) {
      case _NavIcon.beranda:
        _drawBeranda(canvas, size);
        break;
      case _NavIcon.transaksi:
        _drawTransaksi(canvas, size);
        break;
      case _NavIcon.statistik:
        _drawStatistik(canvas, size);
        break;
      case _NavIcon.budget:
        _drawBudget(canvas, size);
        break;
    }
  }

  Paint get _stroke => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.7
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint get _fill => Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  // ── BERANDA: buku dengan koin di cover ──────────────────────────────────────
  void _drawBeranda(Canvas canvas, Size s) {
    final p = _stroke;

    // Buku - cover depan
    final book = RRect.fromRectAndRadius(
      Rect.fromLTWH(s.width * 0.1, s.height * 0.1, s.width * 0.72, s.height * 0.82),
      const Radius.circular(3),
    );
    canvas.drawRRect(book, p);

    // Spine (punggung buku)
    canvas.drawLine(
      Offset(s.width * 0.22, s.height * 0.1),
      Offset(s.width * 0.22, s.height * 0.92),
      p,
    );

    // Koin di cover — lingkaran
    canvas.drawCircle(
      Offset(s.width * 0.56, s.height * 0.46),
      s.width * 0.18,
      p,
    );

    // Simbol $ di dalam koin
    final dollarPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final cx = s.width * 0.56;
    final cy = s.height * 0.46;
    // S shape - simplified sebagai garis lengkung
    final path = Path();
    path.moveTo(cx + 4, cy - 5);
    path.cubicTo(cx - 5, cy - 5, cx - 5, cy, cx, cy);
    path.cubicTo(cx + 5, cy, cx + 5, cy + 5, cx - 4, cy + 5);
    canvas.drawPath(path, dollarPaint);

    // Garis vertikal koin
    canvas.drawLine(Offset(cx, cy - 7), Offset(cx, cy + 7), dollarPaint);

    // Garis baris di buku (kiri spine)
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(s.width * 0.28, s.height * 0.68), Offset(s.width * 0.46, s.height * 0.68), linePaint);
    canvas.drawLine(Offset(s.width * 0.28, s.height * 0.76), Offset(s.width * 0.46, s.height * 0.76), linePaint);
  }

  // ── TRANSAKSI: struk/nota dengan lingkaran $ ─────────────────────────────────
  void _drawTransaksi(Canvas canvas, Size s) {
    final p = _stroke;

    // Kertas struk
    final path = Path();
    path.moveTo(s.width * 0.18, s.height * 0.05);
    path.lineTo(s.width * 0.82, s.height * 0.05);
    path.lineTo(s.width * 0.82, s.height * 0.88);
    // Zig-zag bawah (3 puncak)
    path.lineTo(s.width * 0.72, s.height * 0.78);
    path.lineTo(s.width * 0.62, s.height * 0.88);
    path.lineTo(s.width * 0.50, s.height * 0.78);
    path.lineTo(s.width * 0.38, s.height * 0.88);
    path.lineTo(s.width * 0.28, s.height * 0.78);
    path.lineTo(s.width * 0.18, s.height * 0.88);
    path.close();
    canvas.drawPath(path, p);

    // Koin / lingkaran di tengah
    canvas.drawCircle(
      Offset(s.width * 0.50, s.height * 0.40),
      s.width * 0.17,
      p,
    );

    // $ di dalam koin
    final dp = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    final cx = s.width * 0.50;
    final cy = s.height * 0.40;
    final sp = Path();
    sp.moveTo(cx + 3.5, cy - 4.5);
    sp.cubicTo(cx - 4.5, cy - 4.5, cx - 4.5, cy, cx, cy);
    sp.cubicTo(cx + 4.5, cy, cx + 4.5, cy + 4.5, cx - 3.5, cy + 4.5);
    canvas.drawPath(sp, dp);
    canvas.drawLine(Offset(cx, cy - 6.5), Offset(cx, cy + 6.5), dp);

    // Baris-baris struk
    final lp = Paint()..color = color..strokeWidth = 1.1..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(s.width * 0.30, s.height * 0.67), Offset(s.width * 0.70, s.height * 0.67), lp);
    canvas.drawLine(Offset(s.width * 0.30, s.height * 0.74), Offset(s.width * 0.58, s.height * 0.74), lp);
  }

  // ── STATISTIK: bar chart dengan panah naik ────────────────────────────────
  void _drawStatistik(Canvas canvas, Size s) {
    final p = _stroke;

    // 3 bar
    final bars = [
      Rect.fromLTWH(s.width * 0.12, s.height * 0.52, s.width * 0.18, s.height * 0.36),
      Rect.fromLTWH(s.width * 0.38, s.height * 0.32, s.width * 0.18, s.height * 0.56),
      Rect.fromLTWH(s.width * 0.64, s.height * 0.18, s.width * 0.18, s.height * 0.70),
    ];
    for (final bar in bars) {
      canvas.drawRRect(RRect.fromRectAndRadius(bar, const Radius.circular(3)), p);
    }

    // Panah naik di kanan atas
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final arrowPath = Path();
    // Garis miring dari kiri bawah ke kanan atas
    arrowPath.moveTo(s.width * 0.18, s.height * 0.60);
    arrowPath.lineTo(s.width * 0.42, s.height * 0.38);
    arrowPath.lineTo(s.width * 0.58, s.height * 0.50);
    arrowPath.lineTo(s.width * 0.80, s.height * 0.20);
    canvas.drawPath(arrowPath, arrowPaint);

    // Kepala panah
    final tip = Offset(s.width * 0.80, s.height * 0.20);
    canvas.drawLine(tip, Offset(s.width * 0.66, s.height * 0.18), arrowPaint);
    canvas.drawLine(tip, Offset(s.width * 0.82, s.height * 0.34), arrowPaint);
  }

  // ── BUDGET: tumpukan koin dengan mahkota / topi ───────────────────────────
  void _drawBudget(Canvas canvas, Size s) {
    final p = _stroke;

    // Topi / mahkota atas (segitiga kecil)
    final crownPath = Path();
    crownPath.moveTo(s.width * 0.28, s.height * 0.28);
    crownPath.lineTo(s.width * 0.18, s.height * 0.10);
    crownPath.lineTo(s.width * 0.35, s.height * 0.20);
    crownPath.lineTo(s.width * 0.50, s.height * 0.05);
    crownPath.lineTo(s.width * 0.65, s.height * 0.20);
    crownPath.lineTo(s.width * 0.82, s.height * 0.10);
    crownPath.lineTo(s.width * 0.72, s.height * 0.28);
    crownPath.close();
    canvas.drawPath(crownPath, p);

    // Badan koin (silinder) — elips atas
    canvas.drawOval(
      Rect.fromLTWH(s.width * 0.18, s.height * 0.28, s.width * 0.64, s.height * 0.22),
      p,
    );

    // Sisi silinder
    canvas.drawLine(Offset(s.width * 0.18, s.height * 0.39), Offset(s.width * 0.18, s.height * 0.72), p);
    canvas.drawLine(Offset(s.width * 0.82, s.height * 0.39), Offset(s.width * 0.82, s.height * 0.72), p);

    // Elips bawah
    canvas.drawOval(
      Rect.fromLTWH(s.width * 0.18, s.height * 0.61, s.width * 0.64, s.height * 0.22),
      p,
    );

    // $ di tengah silinder
    final dp = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    final cx = s.width * 0.50;
    final cy = s.height * 0.50;
    final sp = Path();
    sp.moveTo(cx + 3.5, cy - 4);
    sp.cubicTo(cx - 4, cy - 4, cx - 4, cy, cx, cy);
    sp.cubicTo(cx + 4, cy, cx + 4, cy + 4, cx - 3.5, cy + 4);
    canvas.drawPath(sp, dp);
    canvas.drawLine(Offset(cx, cy - 6), Offset(cx, cy + 6), dp);
  }

  @override
  bool shouldRepaint(_IconPainter old) => old.color != color || old.icon != icon;
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

const Color kBrown      = Color(0xFF4A3728);
const Color kBrownLight = Color(0xFF9E8F82);
const Color kBg         = Color(0xFFF5F0EA);
const Color kKeluar     = Color(0xFFB85C38);
const Color kMasuk      = Color(0xFF6BAA8E);

// ── MODEL ─────────────────────────────────────────────────────────────────────

class BudgetKategori {
  final int id;
  final String nama;
  final String icon;
  final Color bg;
  final Color color;
  int limitAmount;    // 0 = belum diset
  final int terpakai; // dummy spending

  BudgetKategori({
    required this.id,
    required this.nama,
    required this.icon,
    required this.bg,
    required this.color,
    this.limitAmount = 0,
    this.terpakai = 0,
  });

  int get sisa        => limitAmount - terpakai;
  double get pctUsed  => limitAmount > 0 ? (terpakai / limitAmount).clamp(0.0, 1.0) : 0;
  bool get hampirHabis => pctUsed >= 0.8 && pctUsed < 1.0;
  bool get habis       => pctUsed >= 1.0;
}

// ── DUMMY DATA ─────────────────────────────────────────────────────────────────

List<BudgetKategori> _buildKategoriList() => [
  BudgetKategori(id: 1, nama: 'Makanan',       icon: '🍔', bg: const Color(0xFFFFF3E0), color: kKeluar,                  terpakai: 325000),
  BudgetKategori(id: 2, nama: 'Transportasi',  icon: '🚗', bg: const Color(0xFFE3F2FD), color: const Color(0xFF42A5F5),  terpakai: 176000),
  BudgetKategori(id: 3, nama: 'Tagihan Rumah', icon: '🏠', bg: const Color(0xFFE8F5E9), color: const Color(0xFF66BB6A),  terpakai: 89000),
  BudgetKategori(id: 4, nama: 'Belanja',       icon: '🛍', bg: const Color(0xFFFCE4EC), color: const Color(0xFFEC407A),  terpakai: 89000),
  BudgetKategori(id: 5, nama: 'Kesehatan',     icon: '❤️', bg: const Color(0xFFFDF3E7), color: const Color(0xFFEF5350),  terpakai: 62500),
  BudgetKategori(id: 6, nama: 'Perawatan',     icon: '💆', bg: const Color(0xFFF3E5F5), color: const Color(0xFFAB47BC),  terpakai: 0),
];

const int _dummyIncome = 5000000; // Rp 5.000.000

// ── HELPERS ───────────────────────────────────────────────────────────────────

String formatRp(int n) {
  if (n == 0) return 'Rp 0';
  return 'Rp ' + n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}

String formatShort(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1).replaceAll('.0', '')}jt';
  if (n >= 1000)    return '${(n / 1000).toStringAsFixed(0)}rb';
  return '$n';
}

// ── BUDGET SCREEN ─────────────────────────────────────────────────────────────

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  int _tab = 0; // 0=Rencana, 1=Sisa
  bool _budgetSet = false;
  List<BudgetKategori> _kategori = _buildKategoriList();

  int get _totalBudget   => _kategori.fold(0, (s, k) => s + k.limitAmount);
  int get _totalTerpakai => _kategori.fold(0, (s, k) => s + k.terpakai);
  int get _totalSisa     => _totalBudget - _totalTerpakai;

  void _openSetBudget() async {
    final result = await Navigator.push<List<BudgetKategori>>(
      context,
      MaterialPageRoute(
        builder: (_) => SetBudgetScreen(
          kategori: _kategori,
          income: _dummyIncome,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _kategori  = result;
        _budgetSet = result.any((k) => k.limitAmount > 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [
        _buildHeader(),
        Expanded(
          child: _budgetSet
              ? (_tab == 0 ? _buildRencana() : _buildSisa())
              : _buildEmptyState(),
        ),
      ]),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: kBrown,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Budget',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
            Text(
              _budgetSet ? 'Mei 2026' : 'Atur pengeluaranmu',
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.65)),
            ),
          ]),
          Row(children: [
            // Bulan navigator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.chevron_left, size: 16, color: Colors.white.withOpacity(0.8)),
                const SizedBox(width: 4),
                Text('Mei', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 16, color: Colors.white.withOpacity(0.8)),
              ]),
            ),
            if (_budgetSet) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _openSetBudget,
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                ),
              ),
            ],
          ]),
        ]),

        if (_budgetSet) ...[
          const SizedBox(height: 16),
          // Donut summary + legend
          _buildDonutSummary(),
          const SizedBox(height: 16),
          // Tab Rencana / Sisa
          _buildTab(),
        ],
      ]),
    );
  }

  Widget _buildDonutSummary() {
    final cats = _kategori.where((k) => k.limitAmount > 0).toList();
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      // Donut
      SizedBox(
        width: 90, height: 90,
        child: CustomPaint(
          painter: _DonutPainter(cats, _totalBudget),
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('BULANAN', style: TextStyle(fontSize: 7, color: Colors.white54, letterSpacing: 0.5)),
            const Text('· TOTAL', style: TextStyle(fontSize: 7, color: Colors.white54, letterSpacing: 0.5)),
            Text(formatShort(_totalBudget),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          ])),
        ),
      ),
      const SizedBox(width: 14),
      // Legend
      Expanded(
        child: Wrap(
          spacing: 8, runSpacing: 4,
          children: cats.map((k) {
            final pct = _totalBudget > 0 ? ((k.limitAmount / _totalBudget) * 100).round() : 0;
            return Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 7, height: 7,
                  decoration: BoxDecoration(color: k.color, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text('${k.nama} $pct%  ${formatShort(k.limitAmount)}',
                  style: const TextStyle(fontSize: 9, color: Colors.white70)),
            ]);
          }).toList(),
        ),
      ),
    ]);
  }

  Widget _buildTab() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(children: [
        _tabBtn('Rencana', 0),
        _tabBtn('Sisa', 1),
      ]),
    );
  }

  Widget _tabBtn(String label, int idx) {
    final sel = _tab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: sel ? const Color(0xFFD4873A) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: sel ? Colors.white : Colors.white60,
              )),
        ),
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Capybara illustration
          Container(
            width: 110, height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE0D4),
              borderRadius: BorderRadius.circular(55),
            ),
            child: const Center(child: Text('🦫', style: TextStyle(fontSize: 60))),
          ),
          const SizedBox(height: 24),
          const Text('Budget belum diatur',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kBrown)),
          const SizedBox(height: 8),
          Text(
            'Yuk atur budget biar keuangan Masbro lebih terencana dan ga kebobolan!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: kBrown.withOpacity(0.6), height: 1.5),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openSetBudget,
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrown,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Atur Sekarang →',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Tab Rencana ────────────────────────────────────────────────────────────

  Widget _buildRencana() {
    final cats = _kategori.where((k) => k.limitAmount > 0).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: cats.map((k) => _RencanaCard(k: k)).toList(),
    );
  }

  // ── Tab Sisa ───────────────────────────────────────────────────────────────

  Widget _buildSisa() {
    final pctUsed = _totalBudget > 0 ? _totalTerpakai / _totalBudget : 0.0;
    final cats = _kategori.where((k) => k.limitAmount > 0).toList()
      ..sort((a, b) => b.pctUsed.compareTo(a.pctUsed));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Gauge card
        _GaugeCard(
          terpakai: _totalTerpakai,
          sisa: _totalSisa,
          total: _totalBudget,
          pct: pctUsed,
        ),
        const SizedBox(height: 14),

        // Kategori header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Row(children: [
              Text('📂', style: TextStyle(fontSize: 14)),
              SizedBox(width: 6),
              Text('Kategori', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kBrown)),
            ]),
            GestureDetector(
              onTap: _openSetBudget,
              child: const Row(children: [
                Icon(Icons.edit_rounded, size: 13, color: kBrownLight),
                SizedBox(width: 4),
                Text('Edit', style: TextStyle(fontSize: 12, color: kBrownLight, fontWeight: FontWeight.w600)),
              ]),
            ),
          ]),
        ),

        ...cats.map((k) => _SisaCard(k: k)),
      ],
    );
  }
}

// ── SET BUDGET SCREEN ─────────────────────────────────────────────────────────

class SetBudgetScreen extends StatefulWidget {
  final List<BudgetKategori> kategori;
  final int income;

  const SetBudgetScreen({super.key, required this.kategori, required this.income});

  @override
  State<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  late List<BudgetKategori> _cats;
  // mode: 'bebas' atau 'persen'
  final Map<int, String> _mode = {};
  final Map<int, TextEditingController> _ctrlNominal = {};
  final Map<int, TextEditingController> _ctrlPersen  = {};

  int get _totalBudget => _cats.fold(0, (s, k) => s + k.limitAmount);

  @override
  void initState() {
    super.initState();
    // Deep copy
    _cats = widget.kategori.map((k) => BudgetKategori(
      id: k.id, nama: k.nama, icon: k.icon,
      bg: k.bg, color: k.color,
      limitAmount: k.limitAmount, terpakai: k.terpakai,
    )).toList();

    for (final k in _cats) {
      _mode[k.id] = 'bebas';
      _ctrlNominal[k.id] = TextEditingController(
          text: k.limitAmount > 0 ? k.limitAmount.toString() : '');
      _ctrlPersen[k.id]  = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _ctrlNominal.values) c.dispose();
    for (final c in _ctrlPersen.values)  c.dispose();
    super.dispose();
  }

  void _onNominalChanged(BudgetKategori k, String val) {
    final amount = int.tryParse(val.replaceAll('.', '')) ?? 0;
    setState(() => k.limitAmount = amount);
  }

  void _onPersenChanged(BudgetKategori k, String val) {
    final pct    = double.tryParse(val) ?? 0;
    final amount = (widget.income * pct / 100).round();
    setState(() {
      k.limitAmount = amount;
      _ctrlNominal[k.id]!.text = amount > 0 ? amount.toString() : '';
    });
  }

  void _toggleMode(BudgetKategori k, String mode) {
    setState(() {
      _mode[k.id] = mode;
      if (mode == 'bebas') {
        _ctrlPersen[k.id]!.clear();
      } else {
        _ctrlNominal[k.id]!.clear();
        k.limitAmount = 0;
      }
    });
  }

  void _konfirmasi() {
    Navigator.pop(context, _cats);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [
        // Header
        Container(
          color: kBrown,
          padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 16),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.chevron_left, color: Colors.white),
              ),
            ),
            const Expanded(
              child: Text('Set Budget',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.chevron_left, size: 14, color: Colors.white.withOpacity(0.8)),
                const SizedBox(width: 4),
                Text('Mei', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 14, color: Colors.white.withOpacity(0.8)),
              ]),
            ),
          ]),
        ),

        // Total preview
        Container(
          width: double.infinity,
          color: kBrown,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [
              const Text('BULANAN · TOTAL',
                  style: TextStyle(fontSize: 10, color: Colors.white54, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(formatRp(_totalBudget),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 4),
              Text('Isi limit tiap kategori di bawah',
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.55))),
            ]),
          ),
        ),

        // List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text('LIMIT PER KATEGORI',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: kBrownLight, letterSpacing: 0.8)),
              ),
              ..._cats.map((k) => _KategoriInputCard(
                k: k,
                mode: _mode[k.id]!,
                ctrlNominal: _ctrlNominal[k.id]!,
                ctrlPersen:  _ctrlPersen[k.id]!,
                income: widget.income,
                onToggleMode: (m) => _toggleMode(k, m),
                onNominalChanged: (v) => _onNominalChanged(k, v),
                onPersenChanged:  (v) => _onPersenChanged(k, v),
              )),
            ],
          ),
        ),
      ]),

      // Bottom konfirmasi
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _konfirmasi,
            style: ElevatedButton.styleFrom(
              backgroundColor: kBrown,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Konfirmasi Budget 💾',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

// ── KATEGORI INPUT CARD ───────────────────────────────────────────────────────

class _KategoriInputCard extends StatelessWidget {
  final BudgetKategori k;
  final String mode;
  final TextEditingController ctrlNominal;
  final TextEditingController ctrlPersen;
  final int income;
  final void Function(String) onToggleMode;
  final void Function(String) onNominalChanged;
  final void Function(String) onPersenChanged;

  const _KategoriInputCard({
    required this.k, required this.mode,
    required this.ctrlNominal, required this.ctrlPersen,
    required this.income,
    required this.onToggleMode, required this.onNominalChanged, required this.onPersenChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Row: icon + nama + mode toggle
        Row(children: [
          Container(width: 38, height: 38,
            decoration: BoxDecoration(color: k.bg, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(k.icon, style: const TextStyle(fontSize: 18)))),
          const SizedBox(width: 10),
          Expanded(child: Text(k.nama,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D2218)))),
          // Mode toggle
          _ModeToggle(current: mode, onToggle: onToggleMode),
        ]),

        const SizedBox(height: 10),

        // Input
        if (mode == 'bebas')
          _NominalInput(ctrl: ctrlNominal, onChanged: onNominalChanged)
        else
          _PersenInput(
            ctrl: ctrlPersen,
            income: income,
            computed: k.limitAmount,
            onChanged: onPersenChanged,
          ),
      ]),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final String current;
  final void Function(String) onToggle;
  const _ModeToggle({required this.current, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0EA),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _ModeBtn(label: 'Bebas', sel: current == 'bebas', onTap: () => onToggle('bebas')),
        _ModeBtn(label: '% Income', sel: current == 'persen', onTap: () => onToggle('persen')),
      ]),
    );
  }
}

class _ModeBtn extends StatelessWidget {
  final String label;
  final bool sel;
  final VoidCallback onTap;
  const _ModeBtn({required this.label, required this.sel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: sel ? kBrown : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: sel ? Colors.white : kBrownLight,
            )),
      ),
    );
  }
}

class _NominalInput extends StatelessWidget {
  final TextEditingController ctrl;
  final void Function(String) onChanged;
  const _NominalInput({required this.ctrl, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kBrown),
      decoration: InputDecoration(
        prefixText: 'Rp  ',
        prefixStyle: const TextStyle(fontSize: 13, color: kBrownLight),
        hintText: '0',
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFCCC0B4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: const Color(0xFFF5F0EA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kBrown, width: 1.5),
        ),
      ),
    );
  }
}

class _PersenInput extends StatelessWidget {
  final TextEditingController ctrl;
  final int income;
  final int computed;
  final void Function(String) onChanged;
  const _PersenInput({
    required this.ctrl, required this.income,
    required this.computed, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            onChanged: onChanged,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kBrown),
            decoration: InputDecoration(
              suffixText: '%',
              suffixStyle: const TextStyle(fontSize: 13, color: kBrownLight),
              hintText: '0',
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFCCC0B4)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: const Color(0xFFF5F0EA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kBrown, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Result preview
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F0EA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            computed > 0 ? formatShort(computed) : '0',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kBrown),
          ),
        ),
      ]),
      const SizedBox(height: 6),
      Text('Income: ${formatRp(income)}',
          style: TextStyle(fontSize: 10, color: kBrownLight)),
    ]);
  }
}

// ── RENCANA CARD ──────────────────────────────────────────────────────────────

class _RencanaCard extends StatelessWidget {
  final BudgetKategori k;
  const _RencanaCard({required this.k});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(children: [
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: k.bg, borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(k.icon, style: const TextStyle(fontSize: 18)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(k.nama,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D2218))),
          const Text('Bulanan',
              style: TextStyle(fontSize: 11, color: kBrownLight)),
        ])),
        Text(formatShort(k.limitAmount),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kBrown)),
      ]),
    );
  }
}

// ── SISA CARD ─────────────────────────────────────────────────────────────────

class _SisaCard extends StatelessWidget {
  final BudgetKategori k;
  const _SisaCard({required this.k});

  @override
  Widget build(BuildContext context) {
    final pctInt    = (k.pctUsed * 100).round();
    final sisaInt   = k.sisa.clamp(0, k.limitAmount);
    final barColor  = k.habis ? const Color(0xFFEF5350)
                    : k.hampirHabis ? const Color(0xFFF57C00)
                    : k.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(color: k.bg, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(k.icon, style: const TextStyle(fontSize: 18)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(k.nama,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D2218))),
            Text('Bulanan · ${formatRp(k.limitAmount)}',
                style: const TextStyle(fontSize: 11, color: kBrownLight)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$pctInt%',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: barColor)),
            Text('sisa ${formatShort(sisaInt)}',
                style: const TextStyle(fontSize: 10, color: kBrownLight)),
          ]),
        ]),

        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: k.pctUsed,
            minHeight: 6,
            backgroundColor: const Color(0xFFF0E9E2),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),

        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Terpakai: ${formatRp(k.terpakai)}',
              style: const TextStyle(fontSize: 10, color: kBrownLight)),
          Text('Sisa: ${formatRp(sisaInt)}',
              style: const TextStyle(fontSize: 10, color: kBrownLight)),
        ]),

        if (k.hampirHabis)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(children: const [
              Icon(Icons.warning_amber_rounded, size: 13, color: Color(0xFFF57C00)),
              SizedBox(width: 4),
              Text('Hampir habis!',
                  style: TextStyle(fontSize: 11, color: Color(0xFFF57C00), fontWeight: FontWeight.w600)),
            ]),
          ),

        if (k.habis)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(children: const [
              Icon(Icons.cancel_rounded, size: 13, color: Color(0xFFEF5350)),
              SizedBox(width: 4),
              Text('Budget habis!',
                  style: TextStyle(fontSize: 11, color: Color(0xFFEF5350), fontWeight: FontWeight.w600)),
            ]),
          ),
      ]),
    );
  }
}

// ── GAUGE CARD ────────────────────────────────────────────────────────────────

class _GaugeCard extends StatelessWidget {
  final int terpakai, sisa, total;
  final double pct;
  const _GaugeCard({
    required this.terpakai, required this.sisa,
    required this.total, required this.pct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
      ),
      child: Column(children: [
        // Gauge
        SizedBox(
          height: 120,
          child: CustomPaint(
            painter: _GaugePainter(pct),
            child: Align(
              alignment: const Alignment(0, 0.4),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('TERPAKAI', style: TextStyle(fontSize: 9, color: kBrownLight, letterSpacing: 0.5)),
                Text(formatShort(terpakai),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kBrown)),
                Text('${(pct * 100).toStringAsFixed(0)}% dari budget',
                    style: const TextStyle(fontSize: 10, color: kBrownLight)),
              ]),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Stats row
        Row(children: [
          Expanded(child: _StatItem(label: 'Terpakai', value: formatShort(terpakai), color: kKeluar)),
          Container(width: 1, height: 32, color: const Color(0xFFF0E9E2)),
          Expanded(child: _StatItem(label: 'Sisa', value: formatShort(sisa > 0 ? sisa : 0), color: kMasuk)),
          Container(width: 1, height: 32, color: const Color(0xFFF0E9E2)),
          Expanded(child: _StatItem(label: 'Total', value: formatShort(total), color: kBrown)),
        ]),
      ]),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 10, color: kBrownLight)),
    ]);
  }
}

class _GaugePainter extends CustomPainter {
  final double pct;
  _GaugePainter(this.pct);

  @override
  void paint(Canvas canvas, Size size) {
    final cx     = size.width / 2;
    final cy     = size.height * 1.1;
    final radius = size.width * 0.42;
    const stroke = 16.0;
    const startA = math.pi;
    const sweepA = math.pi;

    // Background arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startA, sweepA, false,
      Paint()
        ..color = const Color(0xFFF0E9E2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );

    // Filled arc
    final fillColor = pct > 0.9 ? const Color(0xFFEF5350)
                    : pct > 0.7 ? const Color(0xFFF57C00)
                    : kKeluar;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startA, sweepA * pct.clamp(0, 1), false,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_) => true;
}

// ── DONUT PAINTER ─────────────────────────────────────────────────────────────

class _DonutPainter extends CustomPainter {
  final List<BudgetKategori> cats;
  final int total;
  _DonutPainter(this.cats, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    double startAngle = -math.pi / 2;

    for (final k in cats) {
      final sweep = 2 * math.pi * k.limitAmount / total;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweep - 0.04, false,
        Paint()
          ..color = k.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 13
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
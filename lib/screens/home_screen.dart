import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'setting_screen.dart';
import 'rincian_screen.dart';
import 'category_detail_screen.dart';

const Color kBrown      = Color(0xFF4A3728);
const Color kBrownLight = Color(0xFF9E8F82);
const Color kBg         = Color(0xFFF5F0EA);

const List<String> _bulanNames = [
  '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

// ── ADD CATEGORY MODAL ────────────────────────────────────────────────────────

class AddCategoryModal extends StatefulWidget {
  final VoidCallback onClose;
  final void Function(CategoryData) onAdd;
  final String type;

  const AddCategoryModal({
    super.key,
    required this.onClose,
    required this.onAdd,
    this.type = 'expense',
  });

  @override
  State<AddCategoryModal> createState() => _AddCategoryModalState();
}

class _AddCategoryModalState extends State<AddCategoryModal> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedIcon = _iconOptions[0];
  _ColorScheme _selectedScheme = _colorSchemes[0];

  void _handleSubmit() {
    if (_nameController.text.trim().isEmpty) return;
    widget.onAdd(CategoryData(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      bg: _selectedScheme.bg,
      color: _selectedScheme.color,
      type: widget.type,
    ));
    widget.onClose();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.type == 'income';
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black.withValues(alpha: 0.45),
        child: GestureDetector(
          onTap: () {},
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isIncome ? 'Tambah Sumber Pemasukan' : 'Tambah Kategori',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2D2218)),
                      ),
                      GestureDetector(
                          onTap: widget.onClose,
                          child: const Icon(Icons.close, size: 20, color: Color(0xFF9E8F82))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Nama', style: TextStyle(fontSize: 11, color: kBrownLight)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: isIncome ? 'cth: Gaji, Freelance...' : 'cth: Hiburan',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFCCC0B4)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0D6CC))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0D6CC))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBrown)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Pilih Ikon', style: TextStyle(fontSize: 11, color: kBrownLight)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _iconOptions.map((ic) {
                      final selected = _selectedIcon == ic;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = ic),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFFF5F0EA) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: selected ? kBrown : const Color(0xFFE0D6CC), width: selected ? 2 : 1.5),
                          ),
                          child: Center(child: Text(ic, style: const TextStyle(fontSize: 17))),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  const Text('Warna', style: TextStyle(fontSize: 11, color: kBrownLight)),
                  const SizedBox(height: 6),
                  Row(
                    children: _colorSchemes.map((s) {
                      final selected = _selectedScheme == s;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedScheme = s),
                          child: Container(
                            width: 26, height: 26,
                            decoration: BoxDecoration(
                              color: s.color, shape: BoxShape.circle,
                              border: selected ? Border.all(color: Colors.white, width: 2) : null,
                              boxShadow: selected ? [BoxShadow(color: s.color.withValues(alpha: 0.7), blurRadius: 0, spreadRadius: 2)] : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrown,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('Tambah', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const List<String> _iconOptions = [
  '🍔','🚗','🏠','🛍','❤️','💆','🎓','✈️','🎮','💡','🐶','📱','🎵','💪','🧴',
  '💼','💰','🏦','📈','🎁','🔧','🌐','🏋️','🎯','🧾',
];

class _ColorScheme {
  final Color bg;
  final Color color;
  const _ColorScheme(this.bg, this.color);
}

const List<_ColorScheme> _colorSchemes = [
  _ColorScheme(Color(0xFFFFF3E0), Color(0xFFF4A03A)),
  _ColorScheme(Color(0xFFE3F2FD), Color(0xFF42A5F5)),
  _ColorScheme(Color(0xFFE8F5E9), Color(0xFF66BB6A)),
  _ColorScheme(Color(0xFFFCE4EC), Color(0xFFEC407A)),
  _ColorScheme(Color(0xFFFDF3E7), Color(0xFFEF5350)),
  _ColorScheme(Color(0xFFF3E5F5), Color(0xFFAB47BC)),
  _ColorScheme(Color(0xFFE8EAF6), Color(0xFF5C6BC0)),
  _ColorScheme(Color(0xFFE0F7FA), Color(0xFF00ACC1)),
  _ColorScheme(Color(0xFFE0F2F1), Color(0xFF26A69A)),
];

// ── HOME SCREEN ───────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String? _modalType;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _pickMonth(BuildContext context, AppState state) {
    final now = DateTime.now();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        int tempMonth = state.selectedMonth;
        int tempYear  = state.selectedYear;
        return StatefulBuilder(builder: (ctx, setModal) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pilih Bulan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF2D2218))),
                    GestureDetector(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close, size: 20, color: kBrownLight)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(onTap: () => setModal(() => tempYear--), child: const Icon(Icons.chevron_left, color: kBrown)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('$tempYear', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kBrown)),
                    ),
                    GestureDetector(
                      onTap: () { if (tempYear < now.year) setModal(() => tempYear++); },
                      child: Icon(Icons.chevron_right, color: tempYear < now.year ? kBrown : kBrownLight),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 4, shrinkWrap: true, childAspectRatio: 2.2,
                  mainAxisSpacing: 8, crossAxisSpacing: 8,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(12, (i) {
                    final m = i + 1;
                    final isSelected = m == tempMonth && tempYear == state.selectedYear;
                    final isFuture = tempYear == now.year && m > now.month;
                    return GestureDetector(
                      onTap: isFuture ? null : () => setModal(() => tempMonth = m),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? kBrown : (isFuture ? const Color(0xFFF5F0EA) : const Color(0xFFF0EBE4)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(child: Text(
                          _bulanNames[m].substring(0, 3),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : (isFuture ? kBrownLight : kBrown)),
                        )),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () { Navigator.pop(ctx); state.setMonth(tempMonth, tempYear); },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrown,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Terapkan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: kBg,
          body: Stack(
            children: [
              Column(children: [
                _buildHeader(context, state),
                _buildTabs(context, state),
              ]),
              if (_modalType != null)
                AddCategoryModal(
                  type: _modalType!,
                  onClose: () => setState(() => _modalType = null),
                  onAdd: (cat) { state.tambahCategory(cat); setState(() => _modalType = null); },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppState state) {
    final bulanLabel = '${_bulanNames[state.selectedMonth]} ${state.selectedYear}';
    return Container(
      color: kBrown,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Baris: Total Saldo | Bulan + Settings ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Saldo',
              style: TextStyle(fontSize: 10, letterSpacing: 0.5, color: Colors.white.withValues(alpha: 0.55)),
            ),
            Row(mainAxisSize: MainAxisSize.min, children: [
              GestureDetector(
                onTap: () => _pickMonth(context, state),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(bulanLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.85))),
                  const SizedBox(width: 3),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.white.withValues(alpha: 0.7)),
                ]),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingScreen())),
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(Icons.settings_outlined, size: 15, color: Colors.white.withValues(alpha: 0.8)),
                ),
              ),
            ]),
          ],
        ),
        const SizedBox(height: 4),
        // ── Angka saldo ──
        state.isLoading
            ? Container(height: 34, width: 180, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)))
            : Text(_formatRp(state.totalSaldo),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _summaryCard('Pemasukan', state.isLoading ? '—' : _formatRp(state.monthIncome), const Color(0xFF7EE8A2), Icons.arrow_downward_rounded)),
          const SizedBox(width: 10),
          Expanded(child: _summaryCard('Pengeluaran', state.isLoading ? '—' : '-${_formatRp(state.monthExpense)}', const Color(0xFFF8A5A5), Icons.arrow_upward_rounded)),
        ]),
        const SizedBox(height: 10),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RincianScreen(onBack: () => Navigator.pop(context)))),
          child: Align(
            alignment: Alignment.centerRight,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('Rincian', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6))),
              const SizedBox(width: 3),
              Icon(Icons.chevron_right, size: 14, color: Colors.white.withValues(alpha: 0.4)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _summaryCard(String label, String value, Color valueColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: valueColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 14, color: valueColor),
        ),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.6))),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor)),
        ]),
      ]),
    );
  }

  Widget _buildTabs(BuildContext context, AppState state) {
    return Expanded(
      child: Column(children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: kBrown, indicatorWeight: 2.5,
            labelColor: kBrown, unselectedLabelColor: kBrownLight,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            tabs: const [Tab(text: 'Pengeluaran'), Tab(text: 'Pemasukan')],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryList(context, state, categories: state.expenseCategories, total: state.monthExpense, type: 'expense', emptyLabel: 'Belum ada pengeluaran bulan ini'),
              _buildCategoryList(context, state, categories: state.incomeCategories,  total: state.monthIncome,  type: 'income',  emptyLabel: 'Belum ada pemasukan bulan ini'),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildCategoryList(BuildContext context, AppState state, {
    required List<CategoryData> categories,
    required int total,
    required String type,
    required String emptyLabel,
  }) {
    if (state.isLoading) return const Center(child: CircularProgressIndicator(color: kBrown, strokeWidth: 2));

    final active = categories.where((c) => c.amount > 0).toList();
    final empty  = categories.where((c) => c.amount == 0).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (active.isEmpty && empty.isEmpty)
          _emptyState(emptyLabel)
        else ...[
          if (active.isNotEmpty) ...[
            ...active.map((cat) => _categoryCard(context, state, cat, total, type)),
            const SizedBox(height: 8),
          ],
          if (empty.isNotEmpty) ...[
            if (active.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('Tidak ada aktivitas', style: TextStyle(fontSize: 11, color: kBrownLight.withValues(alpha: 0.7))),
              ),
            ...empty.map((cat) => _categoryCard(context, state, cat, total, type)),
          ],
        ],
        _addButton(type),
      ],
    );
  }

  Widget _categoryCard(BuildContext context, AppState state, CategoryData cat, int total, String type) {
    final pct       = cat.pct(total);
    final hasAmount = cat.amount > 0;
    final isIncome  = type == 'income';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryDetailScreen(
            category: cat,
            type: type,
            month: state.selectedMonth,
            year: state.selectedYear,
          ),
        ),
      ).then((_) => state.loadData()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 0.5),
        ),
        child: Column(children: [
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: cat.bg, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(cat.icon, style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(cat.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D2218))),
                const SizedBox(height: 2),
                Text(
                  hasAmount ? '$pct% dari total ${isIncome ? "pemasukan" : "pengeluaran"}' : 'Belum ada transaksi',
                  style: TextStyle(fontSize: 10, color: hasAmount ? kBrownLight : kBrown.withValues(alpha: 0.35), fontStyle: hasAmount ? FontStyle.normal : FontStyle.italic),
                ),
              ]),
            ),
            Row(children: [
              Text(
                hasAmount ? (isIncome ? '+' : '-') + _formatRp(cat.amount) : '—',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: hasAmount ? (isIncome ? const Color(0xFF43A047) : const Color(0xFFEF5350)) : kBrownLight),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 14, color: kBrownLight.withValues(alpha: 0.5)),
            ]),
          ]),
          if (hasAmount) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (pct / 100).clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: const Color(0xFFF0E9E2),
                valueColor: AlwaysStoppedAnimation<Color>(cat.color),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _addButton(String type) {
    final isIncome = type == 'income';
    return GestureDetector(
      onTap: () => setState(() => _modalType = type),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC9B9A8), width: 1.5),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 22, height: 22,
            decoration: const BoxDecoration(color: kBrown, shape: BoxShape.circle),
            child: const Center(child: Text('+', style: TextStyle(color: Colors.white, fontSize: 16, height: 1))),
          ),
          const SizedBox(width: 8),
          Text(isIncome ? 'Tambah Sumber Pemasukan' : 'Tambah Kategori',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kBrown)),
        ]),
      ),
    );
  }

  Widget _emptyState(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(child: Column(children: [
        const Text('📭', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 13, color: kBrownLight)),
      ])),
    );
  }

  String _formatRp(int num) {
    final s = num.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $s';
  }
}
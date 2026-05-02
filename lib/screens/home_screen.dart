import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'setting_screen.dart';
import 'category_input_screen.dart';

const Color kBrown = Color(0xFF4A3728);
const Color kBrownLight = Color(0xFF9E8F82);
const Color kBg = Color(0xFFF5F0EA);

// ── ADD CATEGORY MODAL ────────────────────────────────────────────────────────

class AddCategoryModal extends StatefulWidget {
  final VoidCallback onClose;
  final void Function(CategoryData) onAdd;

  const AddCategoryModal({super.key, required this.onClose, required this.onAdd});

  @override
  State<AddCategoryModal> createState() => _AddCategoryModalState();
}

class _AddCategoryModalState extends State<AddCategoryModal> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedIcon = iconOptions[0];
  _ColorScheme _selectedScheme = colorSchemes[0];

  void _handleSubmit() {
    if (_nameController.text.trim().isEmpty) return;
    widget.onAdd(CategoryData(
      id: DateTime.now().millisecondsSinceEpoch,
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      bg: _selectedScheme.bg,
      color: _selectedScheme.color,
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
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black.withOpacity(0.45),
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
                      const Text('Tambah Kategori',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2D2218))),
                      GestureDetector(onTap: widget.onClose, child: const Icon(Icons.close, size: 20, color: Color(0xFF9E8F82))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Nama Kategori', style: TextStyle(fontSize: 11, color: kBrownLight)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'cth: Hiburan',
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
                    children: iconOptions.map((ic) {
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
                    children: colorSchemes.map((s) {
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
                              boxShadow: selected ? [BoxShadow(color: s.color.withOpacity(0.7), blurRadius: 0, spreadRadius: 2)] : null,
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

const List<String> iconOptions = ["🍔","🚗","🏠","🛍","❤️","💆","🎓","✈️","🎮","💡","🐶","📱","🎵","💪","🧴"];

class _ColorScheme {
  final Color bg;
  final Color color;
  const _ColorScheme(this.bg, this.color);
}

const List<_ColorScheme> colorSchemes = [
  _ColorScheme(Color(0xFFFFF3E0), Color(0xFFF4A03A)),
  _ColorScheme(Color(0xFFE3F2FD), Color(0xFF42A5F5)),
  _ColorScheme(Color(0xFFE8F5E9), Color(0xFF66BB6A)),
  _ColorScheme(Color(0xFFFCE4EC), Color(0xFFEC407A)),
  _ColorScheme(Color(0xFFFDF3E7), Color(0xFFEF5350)),
  _ColorScheme(Color(0xFFF3E5F5), Color(0xFFAB47BC)),
  _ColorScheme(Color(0xFFE8EAF6), Color(0xFF5C6BC0)),
  _ColorScheme(Color(0xFFE0F7FA), Color(0xFF00ACC1)),
];

// ── HOME SCREEN ───────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  final VoidCallback? onRincian;
  const HomeScreen({super.key, this.onRincian});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showModal = false;

  String _formatRp(int num) {
    final s = num.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $s';
  }

  void _openCategoryInput(BuildContext context, CategoryData cat, int totalSaldo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryInputScreen(
          category: cat,
          totalSaldo: totalSaldo,
          onSave: (amount) {
            context.read<AppState>().setAmount(cat.id, amount);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final totalSaldo = state.totalSaldo;
        final totalPengeluaran = state.categories.fold(0, (sum, c) => sum + c.amount);

        return Scaffold(
          backgroundColor: kBg,
          body: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(state, totalSaldo, totalPengeluaran),
                  _buildBody(context, state, totalSaldo),
                ],
              ),
              if (_showModal)
                AddCategoryModal(
                  onClose: () => setState(() => _showModal = false),
                  onAdd: (cat) {
                    state.tambahCategory(cat);
                    setState(() => _showModal = false);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppState state, int totalSaldo, int totalPengeluaran) {
    final sisaSaldo = totalSaldo - totalPengeluaran;
    return Container(
      color: kBrown,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search + gear
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 14, color: Colors.white.withOpacity(0.7)),
                      const SizedBox(width: 8),
                      Text('Cari Transaksi...',
                          style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.white.withOpacity(0.5))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingScreen())),
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.settings_outlined, size: 15, color: Colors.white.withOpacity(0.8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Period
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('April', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7))),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, size: 14, color: Colors.white.withOpacity(0.7)),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Total saldo (dinamis dari AppState)
          Text('Total Saldo', style: TextStyle(fontSize: 10, letterSpacing: 0.5, color: Colors.white.withOpacity(0.55))),
          const SizedBox(height: 4),
          Text(_formatRp(totalSaldo),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5)),
          const SizedBox(height: 16),

          // Pemasukan / Pengeluaran
          Row(
            children: [
              Expanded(child: _buildSummaryCard('Pemasukan',   _formatRp(totalSaldo),        const Color(0xFF7EE8A2))),
              const SizedBox(width: 10),
              Expanded(child: _buildSummaryCard('Pengeluaran', '-${_formatRp(totalPengeluaran)}', const Color(0xFFF8A5A5))),
            ],
          ),
          const SizedBox(height: 10),

          // Rincian
          GestureDetector(
            onTap: widget.onRincian,
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Rincian', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6))),
                  const SizedBox(width: 3),
                  Icon(Icons.chevron_right, size: 14, color: Colors.white.withOpacity(0.4)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppState state, int totalSaldo) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Text('Pengeluaran per Kategori',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3A2E25))),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              children: [
                ...state.categories.map((cat) => _buildCategoryCard(context, cat, totalSaldo)),
                _buildAddButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryData cat, int totalSaldo) {
    final pct = cat.pct(totalSaldo);
    final hasAmount = cat.amount > 0;

    return GestureDetector(
      onTap: () => _openCategoryInput(context, cat, totalSaldo),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.5),
        ),
        child: Row(
          children: [
            // Icon bubble
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: cat.bg, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(cat.icon, style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),

            // Name + progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cat.name,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D2218))),
                  const SizedBox(height: 2),
                  Text(
                    hasAmount ? '$pct% dari total saldo' : 'Tap untuk isi pengeluaran',
                    style: TextStyle(
                      fontSize: 10,
                      color: hasAmount ? const Color(0xFF9E8F82) : kBrown.withOpacity(0.5),
                      fontStyle: hasAmount ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                  if (hasAmount) ...[
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (pct / 100).clamp(0.0, 1.0),
                        minHeight: 3,
                        backgroundColor: const Color(0xFFF0E9E2),
                        valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Amount
            hasAmount
                ? Text(_formatRp(cat.amount),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D2218)))
                : Icon(Icons.add_circle_outline, size: 18, color: kBrown.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => setState(() => _showModal = true),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC9B9A8), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22, height: 22,
              decoration: const BoxDecoration(color: kBrown, shape: BoxShape.circle),
              child: const Center(child: Text('+', style: TextStyle(color: Colors.white, fontSize: 16, height: 1))),
            ),
            const SizedBox(width: 8),
            const Text('Tambah Kategori', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kBrown)),
          ],
        ),
      ),
    );
  }
}
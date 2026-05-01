import 'package:flutter/material.dart';
import 'setting_screen.dart';
import 'rincian_screen.dart';

// ── DATA ──────────────────────────────────────────────────────────────────────

class Category {
  final int id;
  final String name;
  final String icon;
  final Color bg;
  final Color color;
  final int amount;
  final int pct;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.bg,
    required this.color,
    required this.amount,
    required this.pct,
  });

  Category copyWith({String? name, String? icon, Color? bg, Color? color, int? amount, int? pct}) {
    return Category(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      bg: bg ?? this.bg,
      color: color ?? this.color,
      amount: amount ?? this.amount,
      pct: pct ?? this.pct,
    );
  }
}

final List<Category> defaultCategories = [
  Category(id: 1, name: "Makanan dan Minuman", icon: "🍔", bg: const Color(0xFFFFF3E0), color: const Color(0xFFF4A03A), amount: 325000, pct: 52),
  Category(id: 2, name: "Transportasi",        icon: "🚗", bg: const Color(0xFFE3F2FD), color: const Color(0xFF42A5F5), amount: 176000, pct: 27),
  Category(id: 3, name: "Biaya Utilitas",      icon: "🏠", bg: const Color(0xFFE8F5E9), color: const Color(0xFF66BB6A), amount: 89000,  pct: 14),
  Category(id: 4, name: "Belanja",             icon: "🛍", bg: const Color(0xFFFCE4EC), color: const Color(0xFFEC407A), amount: 89000,  pct: 14),
  Category(id: 5, name: "Kesehatan",           icon: "❤️", bg: const Color(0xFFFDF3E7), color: const Color(0xFFEF5350), amount: 62500,  pct: 10),
  Category(id: 6, name: "Perawatan",           icon: "💆", bg: const Color(0xFFF3E5F5), color: const Color(0xFFAB47BC), amount: 0,      pct: 0),
];

const List<String> iconOptions = [
  "🍔","🚗","🏠","🛍","❤️","💆","🎓","✈️","🎮","💡","🐶","📱","🎵","💪","🧴"
];

class ColorSchemeOption {
  final Color bg;
  final Color color;
  const ColorSchemeOption(this.bg, this.color);
}

const List<ColorSchemeOption> bgOptions = [
  ColorSchemeOption(Color(0xFFFFF3E0), Color(0xFFF4A03A)),
  ColorSchemeOption(Color(0xFFE3F2FD), Color(0xFF42A5F5)),
  ColorSchemeOption(Color(0xFFE8F5E9), Color(0xFF66BB6A)),
  ColorSchemeOption(Color(0xFFFCE4EC), Color(0xFFEC407A)),
  ColorSchemeOption(Color(0xFFFDF3E7), Color(0xFFEF5350)),
  ColorSchemeOption(Color(0xFFF3E5F5), Color(0xFFAB47BC)),
  ColorSchemeOption(Color(0xFFE8EAF6), Color(0xFF5C6BC0)),
  ColorSchemeOption(Color(0xFFE0F7FA), Color(0xFF00ACC1)),
];

// ── HELPERS ───────────────────────────────────────────────────────────────────

String formatRp(int num) {
  final s = num.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return 'Rp $s';
}

const Color kBrown = Color(0xFF4A3728);
const Color kBrownLight = Color(0xFF9E8F82);
const Color kBg = Color(0xFFF5F0EA);

// ── ADD MODAL ─────────────────────────────────────────────────────────────────

class AddModal extends StatefulWidget {
  final VoidCallback onClose;
  final void Function(Category) onAdd;

  const AddModal({super.key, required this.onClose, required this.onAdd});

  @override
  State<AddModal> createState() => _AddModalState();
}

class _AddModalState extends State<AddModal> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedIcon = iconOptions[0];
  ColorSchemeOption _selectedScheme = bgOptions[0];

  void _handleSubmit() {
    if (_nameController.text.trim().isEmpty) return;
    widget.onAdd(Category(
      id: DateTime.now().millisecondsSinceEpoch,
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      bg: _selectedScheme.bg,
      color: _selectedScheme.color,
      amount: 0,
      pct: 0,
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
          onTap: () {}, // prevent close when tapping modal content
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
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tambah Kategori',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2D2218)),
                      ),
                      GestureDetector(
                        onTap: widget.onClose,
                        child: const Icon(Icons.close, size: 20, color: Color(0xFF9E8F82)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Nama
                  const Text('Nama Kategori', style: TextStyle(fontSize: 11, color: kBrownLight)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'cth: Hiburan',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFCCC0B4)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0D6CC)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0D6CC)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kBrown),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Pilih Ikon
                  const Text('Pilih Ikon', style: TextStyle(fontSize: 11, color: kBrownLight)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: iconOptions.map((ic) {
                      final selected = _selectedIcon == ic;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = ic),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFFF5F0EA) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected ? kBrown : const Color(0xFFE0D6CC),
                              width: selected ? 2 : 1.5,
                            ),
                          ),
                          child: Center(child: Text(ic, style: const TextStyle(fontSize: 17))),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Warna
                  const Text('Warna', style: TextStyle(fontSize: 11, color: kBrownLight)),
                  const SizedBox(height: 6),
                  Row(
                    children: bgOptions.map((s) {
                      final selected = _selectedScheme == s;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedScheme = s),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: s.color,
                              shape: BoxShape.circle,
                              border: selected
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                              boxShadow: selected
                                  ? [BoxShadow(color: s.color.withOpacity(0.7), blurRadius: 0, spreadRadius: 2)]
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // Submit
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
                      child: const Text(
                        'Tambah',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
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

// ── HOME SCREEN ───────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> _categories = List.from(defaultCategories);
  bool _showModal = false;

  void _handleAdd(Category cat) {
    setState(() => _categories.add(cat));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              _buildBody(),
            ],
          ),
          if (_showModal)
            AddModal(
              onClose: () => setState(() => _showModal = false),
              onAdd: _handleAdd,
            ),
        ],
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
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
                      Text(
                        'Cari Transaksi...',
                        style: TextStyle(
                          fontSize: 11, fontStyle: FontStyle.italic,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingScreen()),
            ),
            child: Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
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

          // Total saldo
          Text(
            'Total Saldo',
            style: TextStyle(
              fontSize: 10, letterSpacing: 0.5, color: Colors.white.withOpacity(0.55),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Rp 2.350.000',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5),
          ),
          const SizedBox(height: 16),

          // Income / expense cards
          Row(
            children: [
              Expanded(child: _buildSummaryCard('Pemasukan',   '+1.000.000', const Color(0xFF7EE8A2))),
              const SizedBox(width: 10),
              Expanded(child: _buildSummaryCard('Pengeluaran', '-650.000',   const Color(0xFFF8A5A5))),
            ],
          ),
          const SizedBox(height: 10),

          // Rincian
          // SESUDAH
GestureDetector(
  onTap: () => Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => const RincianScreen(),
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    ),
  ),
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

  // ── BODY ────────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Text(
              'Pengeluaran per Kategori',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3A2E25)),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              children: [
                ..._categories.map(_buildCategoryCard),
                _buildAddButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Category cat) {
    return Container(
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
            decoration: BoxDecoration(
              color: cat.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(cat.icon, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),

          // Name + progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D2218)),
                ),
                const SizedBox(height: 2),
                Text(
                  '${cat.pct}% dari total',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF9E8F82)),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: cat.pct / 100,
                    minHeight: 3,
                    backgroundColor: const Color(0xFFF0E9E2),
                    valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Amount
          Text(
            formatRp(cat.amount),
            style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D2218),
            ),
          ),
        ],
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
          border: Border.all(color: const Color(0xFFC9B9A8), width: 1.5, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22, height: 22,
              decoration: const BoxDecoration(color: kBrown, shape: BoxShape.circle),
              child: const Center(
                child: Text('+', style: TextStyle(color: Colors.white, fontSize: 16, height: 1)),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Tambah Kategori',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kBrown),
            ),
          ],
        ),
      ),
    );
  }
}
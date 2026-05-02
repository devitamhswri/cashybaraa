import 'package:flutter/material.dart';

const Color kBrown = Color(0xFF4A3728);
const Color kBrownDark = Color(0xFF3A2218);

class AkunItem {
  final String nama;
  final String tipe;
  final int saldo;
  final Color bgColor;

  AkunItem({
    required this.nama,
    required this.tipe,
    required this.saldo,
    required this.bgColor,
  });
}

class RincianScreen extends StatefulWidget {
  final VoidCallback onBack;
  const RincianScreen({super.key, required this.onBack});

  @override
  State<RincianScreen> createState() => _RincianScreenState();
}

class _RincianScreenState extends State<RincianScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  final List<AkunItem> _akunList = [
    AkunItem(nama: 'Bank BCA',   tipe: 'bank', saldo: 1000000, bgColor: const Color(0xFFE8F4FF)),
    AkunItem(nama: 'Uang Tunai', tipe: 'cash', saldo: 1350000, bgColor: const Color(0xFFE8F5E9)),
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  int get _totalSaldo => _akunList.fold(0, (sum, a) => sum + a.saldo);

  String _formatRp(int num) {
    final s = num.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $s';
  }

  void _goBack() async {
    await _slideController.reverse();
    widget.onBack();
  }

  void _showTambahAkun() {
    final namaController = TextEditingController();
    final saldoController = TextEditingController();
    String selectedType = 'bank';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
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
                    const Text('Tambah Akun',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2D2218))),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close, size: 20, color: Color(0xFF9E8F82)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Text('Jenis Akun', style: TextStyle(fontSize: 11, color: Color(0xFF9E8F82))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _typeChip('Bank',       'bank',    selectedType, (v) => setModal(() => selectedType = v)),
                    const SizedBox(width: 8),
                    _typeChip('Uang Tunai', 'cash',    selectedType, (v) => setModal(() => selectedType = v)),
                    const SizedBox(width: 8),
                    _typeChip('E-Wallet',   'ewallet', selectedType, (v) => setModal(() => selectedType = v)),
                  ],
                ),
                const SizedBox(height: 14),

                const Text('Nama Akun', style: TextStyle(fontSize: 11, color: Color(0xFF9E8F82))),
                const SizedBox(height: 4),
                _buildInput(controller: namaController, hint: 'cth: Bank BRI, OVO...'),
                const SizedBox(height: 12),

                const Text('Saldo Awal', style: TextStyle(fontSize: 11, color: Color(0xFF9E8F82))),
                const SizedBox(height: 4),
                _buildInput(controller: saldoController, hint: '0', keyboardType: TextInputType.number, prefix: 'Rp '),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final nama = namaController.text.trim();
                      final saldo = int.tryParse(saldoController.text.replaceAll('.', '').trim()) ?? 0;
                      if (nama.isEmpty) return;
                      setState(() {
                        _akunList.add(AkunItem(
                          nama: nama,
                          tipe: selectedType,
                          saldo: saldo,
                          bgColor: selectedType == 'bank'
                              ? const Color(0xFFE8F4FF)
                              : selectedType == 'cash'
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFF3E5F5),
                        ));
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrown,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Tambah',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String label, String value, String selected, void Function(String) onTap) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kBrown : const Color(0xFFF5F0EA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF9E8F82),
            )),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? prefix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13, color: Color(0xFF2D2218)),
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefix,
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBDB0A6)),
        filled: true,
        fillColor: const Color(0xFFF5F0EA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E0D8))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBrown, width: 1.5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnim,
      child: Container(
        color: kBrownDark,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: kBrownDark,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _goBack,
                child: Row(
                  children: [
                    Icon(Icons.chevron_left, size: 18, color: Colors.white.withOpacity(0.8)),
                    const SizedBox(width: 2),
                    Text('Ringkasan',
                        style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Icon(Icons.settings_outlined, size: 20, color: Colors.white.withOpacity(0.7)),
            ],
          ),
          const SizedBox(height: 20),

          Text('TOTAL SALDO SAAT INI',
              style: TextStyle(fontSize: 10, letterSpacing: 1, color: Colors.white.withOpacity(0.55))),
          const SizedBox(height: 6),
          Text(_formatRp(_totalSaldo),
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _showTambahAkun,
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(Icons.add, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      color: kBrownDark,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        itemCount: _akunList.length,
        itemBuilder: (_, i) => _buildAkunCard(_akunList[i]),
      ),
    );
  }

  Widget _buildAkunCard(AkunItem akun) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF5A3D2B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: akun.bgColor, borderRadius: BorderRadius.circular(12)),
            child: Center(child: _akunIcon(akun.tipe)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(akun.nama,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
          Text(_formatRp(akun.saldo),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF7EE8A2))),
        ],
      ),
    );
  }

  Widget _akunIcon(String tipe) {
    switch (tipe) {
      case 'bca':
      case 'bank':    return const Text('🏦', style: TextStyle(fontSize: 22));
      case 'cash':    return const Text('💵', style: TextStyle(fontSize: 22));
      case 'ewallet': return const Text('📱', style: TextStyle(fontSize: 22));
      default:        return const Icon(Icons.account_balance_wallet_outlined, size: 22, color: Color(0xFF9E8F82));
    }
  }
}
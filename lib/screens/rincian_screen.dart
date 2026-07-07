import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../services/firebase_service.dart';
import 'app_state.dart';

const Color _kBrown = Color(0xFF4A3728);

class RincianScreen extends StatefulWidget {
  final VoidCallback onBack;
  const RincianScreen({super.key, required this.onBack});

  @override
  State<RincianScreen> createState() => _RincianScreenState();
}

class _RincianScreenState extends State<RincianScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnim = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _slideController, curve: Curves.easeOutCubic));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

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

  // ─── Tambah Akun ──────────────────────────────────────────────────────────
  void _showTambahAkun(AppState state) {
    final namaController  = TextEditingController();
    final saldoController = TextEditingController();
    String selectedType   = 'bank';

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
                        child: const Icon(Icons.close, size: 20, color: Color(0xFF9E8F82))),
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
                if (selectedType != 'cash') ...[
                  const Text('Nama Akun', style: TextStyle(fontSize: 11, color: Color(0xFF9E8F82))),
                  const SizedBox(height: 4),
                  _buildInput(
                      controller: namaController,
                      hint: selectedType == 'bank' ? 'cth: BCA, BRI, Mandiri...' : 'cth: OVO, GoPay, Dana...'),
                  const SizedBox(height: 12),
                ],
                const Text('Saldo Awal', style: TextStyle(fontSize: 11, color: Color(0xFF9E8F82))),
                const SizedBox(height: 4),
                _buildInput(controller: saldoController, hint: '0', keyboardType: TextInputType.number, prefix: 'Rp '),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final nama  = selectedType == 'cash' ? 'Uang Tunai' : namaController.text.trim();
                      final saldo = int.tryParse(saldoController.text.replaceAll('.', '').trim()) ?? 0;
                      if (nama.isEmpty) return;
                      state.tambahAkun(AkunItem(
                        nama: nama, tipe: selectedType, saldo: saldo,
                        bgColor: selectedType == 'bank'
                            ? const Color(0xFFE8F4FF)
                            : selectedType == 'cash'
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFF3E5F5),
                      ));
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kBrown,
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

  // ─── Tambah Saldo — tercatat sebagai transaksi pemasukan ──────────────────
  void _showTambahSaldo(AppState state, int index) {
    final akun            = state.akunList[index];
    final saldoController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                  Expanded(
                    child: Text('Tambah Saldo — ${akun.nama}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2D2218)),
                        overflow: TextOverflow.ellipsis),
                  ),
                  GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 20, color: Color(0xFF9E8F82))),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                    color: const Color(0xFFF5F0EA), borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Saldo saat ini', style: TextStyle(fontSize: 10, color: Color(0xFF9E8F82))),
                    const SizedBox(height: 2),
                    Text(_formatRp(akun.saldo),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2D2218))),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text('Jumlah yang Ditambahkan', style: TextStyle(fontSize: 11, color: Color(0xFF9E8F82))),
              const SizedBox(height: 4),
              _buildInput(controller: saldoController, hint: '0', keyboardType: TextInputType.number, prefix: 'Rp '),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final tambah = int.tryParse(saldoController.text.replaceAll('.', '').trim()) ?? 0;
                    if (tambah <= 0) return;

                    // Tutup modal dulu sebelum async gap
                    Navigator.pop(context);

                    final now     = DateTime.now();
                    final dateStr = '${now.year}-'
                        '${now.month.toString().padLeft(2, '0')}-'
                        '${now.day.toString().padLeft(2, '0')}';

                    // 1. Catat sebagai transaksi income di Firestore
                    await FirebaseService.addTransaction({
                      'category_id': '',
                      'type':        'income',
                      'amount':      tambah,
                      'date':        dateStr,
                      'note':        'Tambah saldo ${akun.nama}',
                      'akun':        akun.nama,
                    });

                    // 2. Update saldo akun
                    final saldoBaru = akun.saldo + tambah;
                    await FirebaseService.updateSaldoAkun(akun.id, saldoBaru);

                    // 3. Reload — pakai mounted check
                    if (mounted) {
                      await state.loadData();
                      Provider.of<TransactionProvider>(context, listen: false)
                          .loadMonth(now.year, now.month);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBrown,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Simpan',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
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
          color: isSelected ? _kBrown : const Color(0xFFF5F0EA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF9E8F82))),
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
        hintText: hint, prefixText: prefix,
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBDB0A6)),
        filled: true, fillColor: const Color(0xFFF5F0EA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8E0D8))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kBrown, width: 1.5)),
      ),
    );
  }

  Widget _akunIcon(String tipe) {
    switch (tipe) {
      case 'bank':    return const Text('🏦', style: TextStyle(fontSize: 24));
      case 'cash':    return const Text('💵', style: TextStyle(fontSize: 24));
      case 'ewallet': return const Text('📱', style: TextStyle(fontSize: 24));
      default:
        return const Icon(Icons.account_balance_wallet_outlined, size: 24, color: Color(0xFF9E8F82));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return SlideTransition(
          position: _slideAnim,
          child: Scaffold(
            backgroundColor: _kBrown,
            body: Column(
              children: [
                // ── Header ────────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      20, MediaQuery.of(context).padding.top + 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _goBack,
                            child: Row(
                              children: [
                                Icon(Icons.chevron_left, size: 18, color: Colors.white.withValues(alpha: 0.8)),
                                const SizedBox(width: 2),
                                Text('Ringkasan',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Bubble Total Saldo ──────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TOTAL SALDO SAAT INI',
                                    style: TextStyle(
                                        fontSize: 10, letterSpacing: 1.2,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withValues(alpha: 0.55)),
                                  ),
                                  const SizedBox(height: 8),
                                  state.isLoading
                                      ? Container(
                                          height: 36, width: 160,
                                          decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(8)))
                                      : Text(
                                          _formatRp(state.totalSaldo),
                                          style: const TextStyle(
                                              fontSize: 30, fontWeight: FontWeight.w800,
                                              color: Colors.white, letterSpacing: -0.5),
                                        ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showTambahAkun(state),
                              child: Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                                ),
                                child: const Icon(Icons.add, size: 20, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // ── List Akun ─────────────────────────────────────────────
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F0EA),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: state.akunList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.account_balance_wallet_outlined,
                                    size: 48, color: Colors.brown.withValues(alpha: 0.3)),
                                const SizedBox(height: 12),
                                Text('Belum ada akun',
                                    style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                                const SizedBox(height: 4),
                                Text('Tap + untuk menambahkan akun',
                                    style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                            itemCount: state.akunList.length,
                            itemBuilder: (_, i) {
                              final akun = state.akunList[i];
                              return GestureDetector(
                                onTap: () => _showTambahSaldo(state, i),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 10, offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48, height: 48,
                                        decoration: BoxDecoration(
                                            color: akun.bgColor,
                                            borderRadius: BorderRadius.circular(14)),
                                        child: Center(child: _akunIcon(akun.tipe)),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(akun.nama,
                                            style: const TextStyle(
                                                fontSize: 15, fontWeight: FontWeight.w600,
                                                color: Color(0xFF2D2218))),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(_formatRp(akun.saldo),
                                              style: const TextStyle(
                                                  fontSize: 15, fontWeight: FontWeight.w700,
                                                  color: Color(0xFF2D8A50))),
                                          const SizedBox(height: 2),
                                          Text('Tap untuk tambah',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.black.withValues(alpha: 0.3))),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
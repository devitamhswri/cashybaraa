import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import 'app_state.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  static const Color kBrown = Color(0xFF4A3728);
  static const Color kBrownLight = Color(0xFF9E8F82);

  String _tipe = 'pengeluaran';
  DateTime _tanggal = DateTime.now();
  String? _kategoriNama;
  String? _kategoriId;   // ← kirim ke Firebase
  String? _akun;
  final _namaController = TextEditingController();
  final _biayaController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _namaController.dispose();
    _biayaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatTanggal(DateTime d) {
    final bulan = ['','Jan','Feb','Mar','Apr','Mei','Jun',
        'Jul','Agu','Sep','Okt','Nov','Des'][d.month];
    return '${d.day} $bulan ${d.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: kBrown),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _simpan() async {
    if (_namaController.text.trim().isEmpty) {
      _showSnack('Nama transaksi tidak boleh kosong'); return;
    }
    if (_kategoriId == null) {
      _showSnack('Pilih kategori dulu'); return;
    }
    if (_akun == null) {
      _showSnack('Pilih akun dulu'); return;
    }
    final biaya = double.tryParse(
      _biayaController.text.replaceAll('.', '').replaceAll(',', '.'),
    );
    if (biaya == null || biaya <= 0) {
      _showSnack('Masukkan biaya yang valid'); return;
    }

    setState(() => _isSaving = true);

    final appState = context.read<AppState>();

    await context.read<TransactionProvider>().addTransactionFull(
      title: _namaController.text.trim(),
      amount: biaya,
      tipe: _tipe,
      kategori: _kategoriNama!,
      categoryId: _kategoriId!,   // ← penting untuk Firebase
      akun: _akun!,
      tanggal: _tanggal,
      notes: _notesController.text.trim(),
      onSuccess: () {
        // Refresh AppState supaya home screen ikut update
        appState.loadData();
      },
    );

    if (mounted) Navigator.pop(context);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: kBrown),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // Pakai objek lengkap supaya bisa ambil id
    final kategoriList = state.categories;
    final akunList = state.akunList.map((a) => a.nama).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EA),
      appBar: AppBar(
        backgroundColor: kBrown,
        foregroundColor: Colors.white,
        title: const Text('Tambah Transaksi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        centerTitle: true,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close),
        ),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
              : TextButton(
                  onPressed: _simpan,
                  child: const Text('Simpan',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TIPE
            _buildCard(
              child: Row(
                children: [
                  Expanded(child: _tipeButton('pengeluaran', 'Pengeluaran', const Color(0xFFEF5350))),
                  const SizedBox(width: 10),
                  Expanded(child: _tipeButton('pemasukan', 'Pemasukan', const Color(0xFF4CAF50))),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // TANGGAL
            _buildCard(
              child: _buildRow(
                icon: Icons.calendar_today_outlined,
                label: 'Tanggal',
                child: GestureDetector(
                  onTap: _pickDate,
                  child: Text(_formatTanggal(_tanggal),
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600, color: kBrown)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // KATEGORI — pakai id bukan hanya nama
            _buildCard(
              child: _buildRow(
                icon: Icons.grid_view_rounded,
                label: 'Kategori',
                child: DropdownButton<String>(
                  value: _kategoriId,
                  hint: const Text('Pilih kategori',
                      style: TextStyle(fontSize: 13, color: Color(0xFFBDB0A6))),
                  underline: const SizedBox(),
                  isDense: true,
                  items: kategoriList.map((k) => DropdownMenuItem(
                    value: k.id,
                    child: Text(k.name, style: const TextStyle(fontSize: 13)),
                  )).toList(),
                  onChanged: (v) {
                    final cat = kategoriList.firstWhere((k) => k.id == v);
                    setState(() {
                      _kategoriId   = v;
                      _kategoriNama = cat.name;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // AKUN
            _buildCard(
              child: _buildRow(
                icon: Icons.account_balance_wallet_outlined,
                label: _tipe == 'pengeluaran' ? 'Dari Akun' : 'Ke Akun',
                child: DropdownButton<String>(
                  value: _akun,
                  hint: const Text('Pilih akun',
                      style: TextStyle(fontSize: 13, color: Color(0xFFBDB0A6))),
                  underline: const SizedBox(),
                  isDense: true,
                  items: akunList.map((a) =>
                      DropdownMenuItem(value: a, child: Text(a, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (v) => setState(() => _akun = v),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // NAMA
            _buildCard(
              child: _buildRow(
                icon: Icons.edit_outlined,
                label: 'Nama',
                child: Expanded(
                  child: TextField(
                    controller: _namaController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'cth: Makan siang',
                      hintStyle: TextStyle(fontSize: 13, color: Color(0xFFBDB0A6)),
                      border: InputBorder.none, isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // BIAYA
            _buildCard(
              child: _buildRow(
                icon: Icons.payments_outlined,
                label: 'Biaya',
                child: Expanded(
                  child: TextField(
                    controller: _biayaController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '0', prefixText: 'Rp ',
                      hintStyle: TextStyle(fontSize: 13, color: Color(0xFFBDB0A6)),
                      border: InputBorder.none, isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // NOTES
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.notes_outlined, size: 18, color: kBrownLight),
                      SizedBox(width: 10),
                      Text('Notes', style: TextStyle(fontSize: 12, color: kBrownLight)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Tambahkan catatan...',
                      hintStyle: TextStyle(fontSize: 13, color: Color(0xFFBDB0A6)),
                      border: InputBorder.none, isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // SIMPAN
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrown,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan Transaksi',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _tipeButton(String value, String label, Color color) {
    final isSelected = _tipe == value;
    return GestureDetector(
      onTap: () => setState(() => _tipe = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE0D6CC),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : const Color(0xFF9E8F82))),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 0.5),
      ),
      child: child,
    );
  }

  Widget _buildRow({required IconData icon, required String label, required Widget child}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kBrownLight),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 12, color: kBrownLight)),
        const SizedBox(width: 16),
        child,
      ],
    );
  }
}
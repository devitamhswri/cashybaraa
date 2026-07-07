import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'login_screen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F0EA),
          body: Column(
            children: [
              _buildHeader(context, state),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildMenuCard(context, state),
                      const SizedBox(height: 16),
                      _buildDangerCard(context, state),
                      const SizedBox(height: 16),
                      _buildLogoutButton(context, state),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppState state) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF4A3728),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 32),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios_rounded, size: 13, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Back', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 84, height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFFE8D5C0),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SvgPicture.asset('assets/image/cashybara-logo.svg', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 14),
          Text(state.userName.isEmpty ? '' : state.userName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.2)),
          const SizedBox(height: 4),
          Text(state.userEmail.isEmpty ? '' : state.userEmail,
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.65))),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, AppState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline, iconBg: const Color(0xFFF0E8FF), iconColor: const Color(0xFF9B59B6),
            title: 'Edit Profil', subtitle: 'Nama & email', isLast: false,
            onTap: () => _showEditProfil(context, state),
          ),
          _buildMenuItem(
            icon: Icons.lock_outline, iconBg: const Color(0xFFFFEDE8), iconColor: const Color(0xFFE07B54),
            title: 'Kata Sandi', subtitle: 'Ubah kata sandi akun', isLast: true,
            onTap: () => _showUbahPassword(context, state),
          ),
        ],
      ),
    );
  }

  // ── DANGER CARD: Reset Data + Hapus Akun ─────────────────────────────────
  Widget _buildDangerCard(BuildContext context, AppState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.refresh_rounded,
            iconBg: const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFF4A03A),
            title: 'Reset Data',
            subtitle: 'Hapus semua transaksi & reset saldo',
            isLast: false,
            onTap: () => _showResetData(context, state),
          ),
          _buildMenuItem(
            icon: Icons.delete_forever_outlined,
            iconBg: const Color(0xFFFFEBEE),
            iconColor: const Color(0xFFE05555),
            title: 'Hapus Akun',
            subtitle: 'Hapus akun & semua data permanen',
            isLast: true,
            onTap: () => _showHapusAkun(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon, required Color iconBg, required Color iconColor,
    required String title, required String subtitle,
    required VoidCallback onTap, required bool isLast,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF0EAE4), width: 1)),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2D2218))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF9E8F82))),
              ]),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFBDB0A6)),
          ],
        ),
      ),
    );
  }

  // ── RESET DATA ────────────────────────────────────────────────────────────
  void _showResetData(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Semua Data?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2D2218))),
        content: const Text(
          'Semua transaksi akan dihapus dan saldo semua akun akan di-reset ke 0.\n\nAkun bank/dompet kamu tetap ada.',
          style: TextStyle(fontSize: 13, color: Color(0xFF9E8F82)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Color(0xFF9E8F82)))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await state.resetData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data berhasil direset'), backgroundColor: Color(0xFF4A3728)),
                );
              }
            },
            child: const Text('Reset', style: TextStyle(color: Color(0xFFE05555), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── HAPUS AKUN ────────────────────────────────────────────────────────────
  void _showHapusAkun(BuildContext context, AppState state) {
    final passController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Hapus Akun Permanen?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2D2218))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Semua data akan dihapus permanen dan tidak bisa dikembalikan.\n\nMasukkan password untuk konfirmasi:',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9E8F82))),
              const SizedBox(height: 12),
              TextField(
                controller: passController,
                obscureText: true,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBDB0A6)),
                  filled: true, fillColor: const Color(0xFFF5F0EA),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E0D8))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4A3728), width: 1.5)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Color(0xFF9E8F82)))),
            TextButton(
              onPressed: () async {
                if (passController.text.isEmpty) return;
                Navigator.pop(ctx);
                final error = await state.hapusAkun(password: passController.text);
                if (context.mounted) {
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error), backgroundColor: const Color(0xFF4A3728)),
                    );
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                }
              },
              child: const Text('Hapus Permanen', style: TextStyle(color: Color(0xFFE05555), fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfil(BuildContext context, AppState state) {
    final namaController  = TextEditingController(text: state.userName);
    final emailController = TextEditingController(text: state.userEmail);
    bool isSaving = false;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Edit Profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2D2218))),
                    GestureDetector(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close, size: 20, color: Color(0xFF9E8F82))),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Nama', style: TextStyle(fontSize: 11, color: Color(0xFF9E8F82))),
                const SizedBox(height: 6),
                _inputField(controller: namaController, hint: 'Nama lengkap'),
                const SizedBox(height: 14),
                const Text('Email', style: TextStyle(fontSize: 11, color: Color(0xFF9E8F82))),
                const SizedBox(height: 6),
                _inputField(controller: emailController, hint: 'Email', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : () async {
                      setModal(() => isSaving = true);
                      final error = await state.updateProfil(nama: namaController.text.trim(), email: emailController.text.trim());
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        if (error != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: const Color(0xFF4A3728)));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A3728), padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                    child: isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Simpan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUbahPassword(BuildContext context, AppState state) {
    final lamaController = TextEditingController();
    final baruController = TextEditingController();
    final konfController = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ubah Kata Sandi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2D2218))),
                    GestureDetector(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close, size: 20, color: Color(0xFF9E8F82))),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Password Lama', style: TextStyle(fontSize: 11, color: Color(0xFF9E8F82))),
                const SizedBox(height: 6),
                _inputField(controller: lamaController, hint: '••••••••', obscure: true),
                const SizedBox(height: 14),
                const Text('Password Baru', style: TextStyle(fontSize: 11, color: Color(0xFF9E8F82))),
                const SizedBox(height: 6),
                _inputField(controller: baruController, hint: '••••••••', obscure: true),
                const SizedBox(height: 14),
                const Text('Konfirmasi Password Baru', style: TextStyle(fontSize: 11, color: Color(0xFF9E8F82))),
                const SizedBox(height: 6),
                _inputField(controller: konfController, hint: '••••••••', obscure: true),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : () async {
                      if (baruController.text != konfController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password baru tidak cocok'), backgroundColor: Color(0xFF4A3728)));
                        return;
                      }
                      setModal(() => isSaving = true);
                      final error = await state.updatePassword(passwordLama: lamaController.text, passwordBaru: baruController.text);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(error ?? 'Password berhasil diubah'),
                          backgroundColor: error != null ? const Color(0xFF4A3728) : const Color(0xFF43A047),
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A3728), padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                    child: isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Simpan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({required TextEditingController controller, required String hint, TextInputType keyboardType = TextInputType.text, bool obscure = false}) {
    return TextField(
      controller: controller, keyboardType: keyboardType, obscureText: obscure,
      style: const TextStyle(fontSize: 13, color: Color(0xFF2D2218)),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBDB0A6)),
        filled: true, fillColor: const Color(0xFFF5F0EA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E0D8))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4A3728), width: 1.5)),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppState state) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Keluar dari Akun?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2D2218))),
          content: const Text('Kamu akan keluar dari CashyBara.', style: TextStyle(fontSize: 13, color: Color(0xFF9E8F82))),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Color(0xFF9E8F82)))),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await state.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
                }
              },
              child: const Text('Keluar', style: TextStyle(color: Color(0xFFE05555), fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD6D6), width: 1),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 18, color: Color(0xFFE05555)),
            SizedBox(width: 8),
            Text('Keluar dari Akun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFE05555))),
          ],
        ),
      ),
    );
  }
}
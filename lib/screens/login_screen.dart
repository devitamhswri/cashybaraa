import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure       = true;
  bool _isLoading     = false;
  bool _isGoogleLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Email dan password wajib diisi.');
      return;
    }

    setState(() { _isLoading = true; _error = null; });
    final error = await context.read<AppState>().login(email, password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      setState(() => _error = error);
    }
  }

  Future<void> _loginGoogle() async {
    setState(() { _isGoogleLoading = true; _error = null; });
    final error = await context.read<AppState>().loginWithGoogle();
    if (!mounted) return;
    setState(() => _isGoogleLoading = false);

    if (error == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EA),
      body: SingleChildScrollView(
        child: Column(children: [
          _buildTop(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                )],
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Text('Sign in',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D2218))),
                const SizedBox(height: 24),

                // Email
                _InputField(
                  controller: _emailCtrl,
                  hint: 'Username / Email',
                  icon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),

                // Password
                _InputField(
                  controller: _passwordCtrl,
                  hint: 'Kata Sandi',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure,
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 18, color: const Color(0xFF9E8F82),
                    ),
                  ),
                ),

                // Lupa password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: const Text('Lupa Kata Sandi?',
                        style: TextStyle(fontSize: 12, color: Color(0xFF9E8F82))),
                  ),
                ),

                // Error
                if (_error != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFCE4EC),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(_error!,
                        style: const TextStyle(fontSize: 12, color: Color(0xFFC62828)),
                        textAlign: TextAlign.center),
                  ),
                ],

                const SizedBox(height: 20),

                // Login button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A3728),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Login',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),

                const SizedBox(height: 20),

                // Divider
                Row(children: [
                  const Expanded(child: Divider(color: Color(0xFFE0D6CC))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Atau login dengan...',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE0D6CC))),
                ]),

                const SizedBox(height: 16),

                // Google Sign-In button — full width
                SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _isGoogleLoading ? null : _loginGoogle,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE0D6CC)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      backgroundColor: Colors.white,
                    ),
                    child: _isGoogleLoading
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF4285F4)))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo Google pakai teks G berwarna
                              const Text('G',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4285F4))),
                              const SizedBox(width: 10),
                              Text('Masuk dengan Google',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700])),
                            ],
                          ),
                  ),
                ),
              ]),
            ),
          ),

          // Sign up
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B5E52)),
                children: [
                  const TextSpan(text: 'Tidak punya akun? '),
                  TextSpan(
                    text: 'SignUp',
                    style: const TextStyle(
                        color: Color(0xFF4A3728),
                        fontWeight: FontWeight.w700),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildTop() {
    return Stack(children: [
      Container(
        width: double.infinity,
        color: const Color(0xFF4A3728),
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 80),
        child: Column(children: [
          Container(
            width: 130, height: 130,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Center(child: Text('🦫', style: TextStyle(fontSize: 72))),
          ),
          const SizedBox(height: 16),
          const Text('CashyBara',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5)),
          const SizedBox(height: 6),
          const Text('Kelola Keuangan Se-santai Masbro',
              style: TextStyle(fontSize: 13, color: Color(0xCCFFFFFF))),
        ]),
      ),
      Positioned(
        bottom: 0, left: 0, right: 0,
        child: CustomPaint(
            size: const Size(double.infinity, 40),
            painter: _WavePainter()),
      ),
    ]);
  }
}

// ── REGISTER, INPUT FIELD, SOCIAL BTN, WAVE PAINTER — sama seperti sebelumnya
// (tidak ada perubahan, copy dari kode lama)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool _obscure   = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passwordCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name     = _nameCtrl.text.trim();
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm  = _confirmCtrl.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Semua field wajib diisi.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Password tidak sama.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password minimal 6 karakter.');
      return;
    }

    setState(() { _isLoading = true; _error = null; });
    final error = await context.read<AppState>().register(name, email, password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (_) => false,
      );
    } else {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_rounded,
                color: Color(0xFF4A3728)),
          ),
          const SizedBox(height: 24),
          const Text('Buat Akun',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2218))),
          const SizedBox(height: 4),
          const Text('Daftar dan mulai kelola keuanganmu!',
              style: TextStyle(fontSize: 13, color: Color(0xFF9E8F82))),
          const SizedBox(height: 28),

          _InputField(
              controller: _nameCtrl,
              hint: 'Nama Lengkap',
              icon: Icons.person_outline_rounded),
          const SizedBox(height: 12),
          _InputField(
              controller: _emailCtrl,
              hint: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _InputField(
            controller: _passwordCtrl,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            obscure: _obscure,
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscure = !_obscure),
              child: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: const Color(0xFF9E8F82)),
            ),
          ),
          const SizedBox(height: 12),
          _InputField(
              controller: _confirmCtrl,
              hint: 'Konfirmasi Password',
              icon: Icons.lock_outline_rounded,
              obscure: true),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(_error!,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFFC62828)),
                  textAlign: TextAlign.center),
            ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A3728),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Daftar Sekarang',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Color(0xFF2D2218)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(fontSize: 14, color: Color(0xFFBBB0A6)),
        prefixIcon:
            Icon(icon, size: 18, color: const Color(0xFF9E8F82)),
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: const Color(0xFFF5F0EA),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0D6CC))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0D6CC))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFF4A3728), width: 1.5)),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFF5F0EA);
    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
          size.width * 0.25, 0, size.width * 0.5, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.75, size.height * 1.2,
          size.width, size.height * 0.3)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
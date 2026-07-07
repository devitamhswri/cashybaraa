import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import '../main.dart';
import '../services/firebase_service.dart';

const Color _kBrown      = Color(0xFF4A3728);
const Color _kBrownLight = Color(0xFF9E8F82);
const Color _kBg         = Color(0xFFF5F0EA);
const Color _kError      = Color(0xFFC62828);
const Color _kErrorBg    = Color(0xFFFCE4EC);

// ─────────────────────────────────────────────────────────────────────────────
// LOGIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure         = true;
  bool _isLoading       = false;
  bool _isGoogleLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(email);

  Future<void> _login() async {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty && password.isEmpty) {
      setState(() => _error = 'Email dan kata sandi wajib diisi.');
      return;
    }
    if (email.isEmpty) {
      setState(() => _error = 'Email wajib diisi.');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _error = 'Format email tidak valid. Contoh: nama@email.com');
      return;
    }
    if (password.isEmpty) {
      setState(() => _error = 'Kata sandi wajib diisi.');
      return;
    }

    setState(() { _isLoading = true; _error = null; });
    final error = await context.read<AppState>().login(email, password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const MainScreen()));
    } else {
      setState(() => _error = error);
    }
  }

  // Sign out Google dulu agar picker akun selalu muncul
  Future<void> _loginGoogle() async {
    setState(() { _isGoogleLoading = true; _error = null; });
    final error = await context.read<AppState>().loginWithGoogle();
    if (!mounted) return;
    setState(() => _isGoogleLoading = false);

    if (error == null) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const MainScreen()));
    } else if (error != 'Login dibatalkan') {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SingleChildScrollView(
        child: Column(children: [
          _buildTop(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20, offset: const Offset(0, 4),
                )],
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Text('Masuk',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                        color: Color(0xFF2D2218))),
                const SizedBox(height: 4),
                const Text('Selamat datang kembali!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: _kBrownLight)),
                const SizedBox(height: 24),

                _InputField(controller: _emailCtrl, hint: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),

                _InputField(
                  controller: _passwordCtrl, hint: 'Kata Sandi',
                  icon: Icons.lock_outline_rounded, obscure: _obscure,
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Icon(_obscure
                        ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 18, color: _kBrownLight),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: const Text('Lupa Kata Sandi?',
                        style: TextStyle(fontSize: 12, color: _kBrownLight)),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 4),
                  _ErrorBox(message: _error!),
                ],

                const SizedBox(height: 16),
                _PrimaryButton(label: 'Masuk', isLoading: _isLoading, onTap: _login),
                const SizedBox(height: 20),

                Row(children: [
                  const Expanded(child: Divider(color: Color(0xFFE0D6CC))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('atau', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE0D6CC))),
                ]),
                const SizedBox(height: 16),

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
                                strokeWidth: 2, color: Color(0xFF4285F4)))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('G',
                                  style: TextStyle(fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF4285F4))),
                              const SizedBox(width: 10),
                              Text('Masuk dengan Google',
                                  style: TextStyle(fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700])),
                            ],
                          ),
                  ),
                ),
              ]),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B5E52)),
                children: [
                  const TextSpan(text: 'Belum punya akun? '),
                  TextSpan(
                    text: 'Daftar',
                    style: const TextStyle(color: _kBrown, fontWeight: FontWeight.w700),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen())),
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
        width: double.infinity, color: _kBrown,
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 80),
        child: Column(children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: const Center(child: Text('🦫', style: TextStyle(fontSize: 64))),
          ),
          const SizedBox(height: 14),
          const Text('CashyBara',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                  color: Colors.white, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          const Text('Kelola Keuangan Se-santai Masbro',
              style: TextStyle(fontSize: 12, color: Color(0xCCFFFFFF))),
        ]),
      ),
      Positioned(
        bottom: 0, left: 0, right: 0,
        child: CustomPaint(
            size: const Size(double.infinity, 40), painter: _WavePainter()),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FORGOT PASSWORD SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _isLoading  = false;
  bool _sent       = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(email);

  Future<void> _send() async {
    final email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      setState(() => _error = 'Email wajib diisi.');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _error = 'Format email tidak valid. Contoh: nama@email.com');
      return;
    }

    setState(() { _isLoading = true; _error = null; });
    final error = await FirebaseService.sendPasswordReset(email);
    if (!mounted) return;
    if (error != null) {
      setState(() { _isLoading = false; _error = error; });
    } else {
      setState(() { _isLoading = false; _sent = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE0D6CC))),
              child: const Icon(Icons.arrow_back_ios_rounded, size: 14, color: _kBrown),
            ),
          ),
          const SizedBox(height: 28),

          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
                color: const Color(0xFFF5F0EA),
                borderRadius: BorderRadius.circular(18)),
            child: const Center(child: Text('🔑', style: TextStyle(fontSize: 32))),
          ),
          const SizedBox(height: 16),

          const Text('Lupa Kata Sandi?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2218))),
          const SizedBox(height: 6),
          const Text(
            'Masukkan email yang terdaftar.\nKami akan mengirimkan link untuk reset kata sandi.',
            style: TextStyle(fontSize: 13, color: _kBrownLight, height: 1.5),
          ),
          const SizedBox(height: 32),

          if (_sent) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFA5D6A7))),
              child: Column(children: [
                const Text('📬', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                const Text('Email Terkirim!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                        color: Color(0xFF2E7D32))),
                const SizedBox(height: 6),
                Text(
                  'Link reset kata sandi telah dikirim ke\n${_emailCtrl.text.trim()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF388E3C), height: 1.5),
                ),
                const SizedBox(height: 4),
                const Text('Cek folder Spam jika tidak muncul di inbox.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Color(0xFF66BB6A))),
              ]),
            ),
            const SizedBox(height: 24),
            _PrimaryButton(label: 'Kembali ke Login',
                onTap: () => Navigator.pop(context)),
          ] else ...[
            _InputField(controller: _emailCtrl, hint: 'Email terdaftar',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),

            if (_error != null) ...[
              const SizedBox(height: 12),
              _ErrorBox(message: _error!),
            ],

            const SizedBox(height: 24),
            _PrimaryButton(label: 'Kirim Link Reset',
                isLoading: _isLoading, onTap: _send),
            const SizedBox(height: 14),

            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali ke Login',
                    style: TextStyle(fontSize: 13, color: _kBrownLight,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REGISTER SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _isLoading      = false;
  String? _error;

  bool get _hasMinLength => _passwordCtrl.text.length >= 8;
  bool get _hasUppercase => _passwordCtrl.text.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => _passwordCtrl.text.contains(RegExp(r'[a-z]'));
  bool get _hasDigit     => _passwordCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial   => _passwordCtrl.text.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'));

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passwordCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String e) =>
      RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$').hasMatch(e);

  bool _isValidEmailDomain(String email) {
    if (!_isValidEmail(email)) return false;
    final domain = email.split('@').last.toLowerCase();
    const allowed = [
      'gmail.com', 'yahoo.com', 'yahoo.co.id', 'hotmail.com',
      'outlook.com', 'icloud.com', 'live.com', 'protonmail.com',
      'proton.me', 'mail.com', 'ymail.com', 'googlemail.com',
    ];
    if (domain.endsWith('.ac.id') || domain.endsWith('.edu') ||
        domain.endsWith('.co.id') || domain.endsWith('.go.id') ||
        domain.endsWith('.sch.id')) return true;
    return allowed.contains(domain);
  }

  bool _isValidName(String n) =>
      RegExp(r'^[a-zA-Z\s]+$').hasMatch(n) && n.trim().isNotEmpty;

  Future<void> _register() async {
    final name     = _nameCtrl.text.trim();
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm  = _confirmCtrl.text;

    if (name.isEmpty) {
      setState(() => _error = 'Nama lengkap wajib diisi.');
      return;
    }
    if (!_isValidName(name)) {
      setState(() => _error = 'Nama lengkap hanya boleh mengandung huruf dan spasi. Angka dan simbol tidak diperbolehkan.');
      return;
    }
    if (email.isEmpty) {
      setState(() => _error = 'Email wajib diisi.');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _error = 'Format email tidak valid. Contoh: nama@gmail.com');
      return;
    }
    if (!_isValidEmailDomain(email)) {
      setState(() => _error = 'Domain email tidak didukung. Gunakan Gmail, Yahoo, Outlook, iCloud, atau email instansi (.ac.id, .edu, dll).');
      return;
    }
    if (password.isEmpty) {
      setState(() => _error = 'Kata sandi wajib diisi.');
      return;
    }
    if (!_hasMinLength) {
      setState(() => _error = 'Kata sandi minimal 8 karakter.');
      return;
    }
    if (!_hasUppercase) {
      setState(() => _error = 'Kata sandi harus mengandung minimal 1 huruf kapital (A-Z).');
      return;
    }
    if (!_hasLowercase) {
      setState(() => _error = 'Kata sandi harus mengandung minimal 1 huruf kecil (a-z).');
      return;
    }
    if (!_hasDigit) {
      setState(() => _error = 'Kata sandi harus mengandung minimal 1 angka (0-9).');
      return;
    }
    if (!_hasSpecial) {
      setState(() => _error = 'Kata sandi harus mengandung minimal 1 karakter khusus (contoh: !@#\$%).');
      return;
    }
    if (confirm.isEmpty) {
      setState(() => _error = 'Konfirmasi kata sandi wajib diisi.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Konfirmasi kata sandi tidak cocok dengan kata sandi yang dimasukkan.');
      return;
    }

    setState(() { _isLoading = true; _error = null; });
    final error = await context.read<AppState>().register(name, email, password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const MainScreen()), (_) => false);
    } else {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE0D6CC))),
              child: const Icon(Icons.arrow_back_ios_rounded, size: 14, color: _kBrown),
            ),
          ),
          const SizedBox(height: 24),

          const Text('Buat Akun',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2218))),
          const SizedBox(height: 4),
          const Text('Daftar dan mulai kelola keuanganmu!',
              style: TextStyle(fontSize: 13, color: _kBrownLight)),
          const SizedBox(height: 28),

          // Nama Lengkap
          const _FieldLabel(label: 'Nama Lengkap'),
          const SizedBox(height: 6),
          _InputField(controller: _nameCtrl,
              hint: 'Contoh: Budi Santoso',
              icon: Icons.person_outline_rounded,
              keyboardType: TextInputType.name),
          const SizedBox(height: 4),
          const Text('Hanya huruf dan spasi, tanpa angka atau simbol',
              style: TextStyle(fontSize: 10, color: _kBrownLight)),
          const SizedBox(height: 16),

          // Email
          const _FieldLabel(label: 'Email'),
          const SizedBox(height: 6),
          _InputField(controller: _emailCtrl, hint: 'nama@email.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),

          // Password
          const _FieldLabel(label: 'Kata Sandi'),
          const SizedBox(height: 6),
          _InputField(
            controller: _passwordCtrl, hint: 'Min. 8 karakter',
            icon: Icons.lock_outline_rounded, obscure: _obscurePass,
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscurePass = !_obscurePass),
              child: Icon(_obscurePass
                  ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18, color: _kBrownLight),
            ),
          ),
          const SizedBox(height: 10),

          _PasswordStrengthWidget(
            hasMinLength: _hasMinLength, hasUppercase: _hasUppercase,
            hasLowercase: _hasLowercase, hasDigit: _hasDigit,
            hasSpecial: _hasSpecial,
          ),
          const SizedBox(height: 16),

          // Konfirmasi Password
          const _FieldLabel(label: 'Konfirmasi Kata Sandi'),
          const SizedBox(height: 6),
          _InputField(
            controller: _confirmCtrl, hint: 'Ulangi kata sandi',
            icon: Icons.lock_outline_rounded, obscure: _obscureConfirm,
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
              child: Icon(_obscureConfirm
                  ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18, color: _kBrownLight),
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 16),
            _ErrorBox(message: _error!),
          ],

          const SizedBox(height: 28),
          _PrimaryButton(label: 'Daftar Sekarang',
              isLoading: _isLoading, onTap: _register),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PASSWORD STRENGTH WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _PasswordStrengthWidget extends StatelessWidget {
  final bool hasMinLength, hasUppercase, hasLowercase, hasDigit, hasSpecial;
  const _PasswordStrengthWidget({
    required this.hasMinLength, required this.hasUppercase,
    required this.hasLowercase, required this.hasDigit, required this.hasSpecial,
  });

  int get _score => [hasMinLength, hasUppercase, hasLowercase, hasDigit, hasSpecial]
      .where((b) => b).length;

  Color get _barColor {
    if (_score <= 1) return const Color(0xFFEF5350);
    if (_score <= 2) return const Color(0xFFFF9800);
    if (_score == 3) return const Color(0xFFFDD835);
    if (_score == 4) return const Color(0xFF8BC34A);
    return const Color(0xFF66BB6A);
  }

  String get _label {
    if (_score <= 1) return 'Sangat Lemah';
    if (_score <= 2) return 'Lemah';
    if (_score == 3) return 'Cukup';
    if (_score == 4) return 'Kuat';
    return 'Sangat Kuat';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFFF5F0EA),
          borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _score / 5, minHeight: 6,
                backgroundColor: const Color(0xFFE0D6CC),
                valueColor: AlwaysStoppedAnimation<Color>(_barColor),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(_label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: _barColor)),
        ]),
        const SizedBox(height: 10),
        _Criterion(met: hasMinLength, label: 'Minimal 8 karakter'),
        _Criterion(met: hasUppercase, label: 'Huruf kapital (A-Z)'),
        _Criterion(met: hasLowercase, label: 'Huruf kecil (a-z)'),
        _Criterion(met: hasDigit,     label: 'Angka (0-9)'),
        _Criterion(met: hasSpecial,   label: 'Karakter khusus (!@#\$%^&*)'),
      ]),
    );
  }
}

class _Criterion extends StatelessWidget {
  final bool met;
  final String label;
  const _Criterion({required this.met, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 14,
          color: met ? const Color(0xFF66BB6A) : const Color(0xFFCCC0B4),
        ),
        const SizedBox(width: 7),
        Text(label,
            style: TextStyle(fontSize: 11,
                color: met ? const Color(0xFF388E3C) : _kBrownLight)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: Color(0xFF3A2E25)));
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: _kErrorBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEF9A9A))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(Icons.info_outline_rounded, size: 15, color: _kError),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message,
              style: const TextStyle(fontSize: 12, color: _kError, height: 1.4)),
        ),
      ]),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap,
      this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kBrown, foregroundColor: Colors.white,
          disabledBackgroundColor: _kBrown.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
  const _InputField({required this.controller, required this.hint,
      required this.icon, this.obscure = false,
      this.suffixIcon, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, obscureText: obscure, keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Color(0xFF2D2218)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBBB0A6)),
        prefixIcon: Icon(icon, size: 18, color: _kBrownLight),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true, fillColor: const Color(0xFFF5F0EA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0D6CC))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0D6CC))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kBrown, width: 1.5)),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _kBg;
    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.75, size.height * 1.2, size.width, size.height * 0.3)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(_) => false;
}
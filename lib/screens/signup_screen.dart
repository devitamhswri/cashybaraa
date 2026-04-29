import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      // resizeToAvoidBottomInset false supaya keyboard tidak geser layout
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // ── RUANG ATAS (putih, di bawah status bar) ──────────────────────
          SizedBox(height: size.height * 0.06),

          // ── CARD SIGN UP ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _SignUpCard(
              usernameController: _usernameController,
              emailController: _emailController,
              passwordController: _passwordController,
              obscurePassword: _obscurePassword,
              onTogglePassword: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),

          // ── FOOTER ───────────────────────────────────────────────────────
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              text: 'Sudah punya akun? ',
              style: const TextStyle(
                color: Color(0xFF41241A),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              children: [
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'SignIN',
                      style: TextStyle(
                        color: Color(0xFF29B6F6),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── WAVE BAWAH mengisi sisa ruang ────────────────────────────────
          const Spacer(),
          _BottomWave(screenSize: size),
        ],
      ),
    );
  }
}

// ── WAVE BAWAH ────────────────────────────────────────────────────────────────

class _BottomWave extends StatelessWidget {
  final Size screenSize;
  const _BottomWave({required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _BottomWaveClipper(),
      child: Container(
        height: screenSize.height * 0.26,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF895037), Color(0xFF41241A)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 44, left: 20, right: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/image/cashybara-logo.svg', height: 64),
              const SizedBox(width: 14),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CashyBara',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1)),
                  SizedBox(height: 4),
                  Text('Kelola Keuangan Se-santai Masbro',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontStyle: FontStyle.italic)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 40);
    path.quadraticBezierTo(size.width * 0.75, 0, size.width * 0.5, 30);
    path.quadraticBezierTo(size.width * 0.25, 65, 0, 45);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ── SIGN UP CARD ──────────────────────────────────────────────────────────────

class _SignUpCard extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;

  const _SignUpCard({
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF895037), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF41241A).withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min, // penting: card ikut ukuran konten
        children: [
          const Text(
            'Sign up',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D1F18)),
          ),
          const SizedBox(height: 18),

          _buildTextField(
              controller: usernameController,
              hint: 'Username',
              icon: Icons.person_outline),
          const SizedBox(height: 12),

          _buildTextField(
              controller: emailController,
              hint: 'Email',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),

          _buildTextField(
            controller: passwordController,
            hint: 'Kata Sandi',
            icon: Icons.lock_outline,
            obscure: obscurePassword,
            suffixIcon: GestureDetector(
              onTap: onTogglePassword,
              child: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: const Color(0xFF9E8F82),
              ),
            ),
          ),
          const SizedBox(height: 18),

          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A3728),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Text('Daftar',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
          const SizedBox(height: 14),

          const Text('Atau daftar dengan...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF9E8F82))),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(
                child: Image.network(
                  'https://www.google.com/favicon.ico',
                  width: 22, height: 22,
                  errorBuilder: (_, __, ___) => const Text('G',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4285F4))),
                ),
              ),
              const SizedBox(width: 16),
              _buildSocialButton(
                  child: const Icon(Icons.apple, size: 24, color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13, color: Color(0xFF2D2218)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBDB0A6)),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF9E8F82)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF5F0EA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFFE8E0D8), width: 1)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFF4A3728), width: 1.5)),
      ),
    );
  }

  Widget _buildSocialButton({required Widget child}) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE0D6CC), width: 1.5),
        color: Colors.white,
      ),
      child: Center(child: child),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cashybara/screens/main_screen.dart'; // Import MainScreen secara langsung
import 'custom_text_field.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Sign in',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF41241A),
            ),
          ),
          const SizedBox(height: 24),
          const CustomTextField(
            hintText: 'Username',
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          const CustomTextField(
            hintText: 'Kata Sandi',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Lupa Kata Sandi?',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Tombol Login
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // Berpindah ke MainScreen (Bukan MainNavigation)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF41241A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          Text(
            'Atau login dengan...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon('assets/google.png', Icons.g_mobiledata),
              const SizedBox(width: 16),
              _buildSocialIcon('assets/apple.png', Icons.apple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(String assetPath, IconData fallbackIcon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Image.asset(
          assetPath,
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            return Icon(fallbackIcon, size: 24, color: Colors.black);
          },
        ),
      ),
    );
  }
}
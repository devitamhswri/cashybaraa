import 'package:flutter/material.dart';
import '../widgets/wavy_header.dart';
import '../widgets/login_card.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Stack(
                  children: [
                    // Wave atas
                    const Positioned(
                      top: 0, left: 0, right: 0,
                      child: WavyHeader(),
                    ),

                    Column(
                      children: [
                        SizedBox(height: constraints.maxHeight * 0.48),

                        // LoginCard dibungkus Container ber-border
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFF895037),
                                width: 1.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF41241A).withOpacity(0.12),
                                  blurRadius: 24,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            // LoginCard harus sudah punya padding sendiri di dalamnya.
                            // Jika LoginCard punya decoration/boxShadow sendiri,
                            // hapus decoration di LoginCard agar tidak double border.
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(23),
                              child: const LoginCard(),
                            ),
                          ),
                        ),

                        const Spacer(),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0, top: 24.0),
                          child: RichText(
                            text: TextSpan(
                              text: 'Tidak punya akun? ',
                              style: const TextStyle(
                                color: Color(0xFF41241A),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SignUpScreen(),
                                      ),
                                    ),
                                    child: const Text(
                                      'SignUP',
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
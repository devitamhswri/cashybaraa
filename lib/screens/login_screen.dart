import 'package:flutter/material.dart';
import '../widgets/wavy_header.dart';
import '../widgets/login_card.dart';

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
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Stack(
                  children: [
                    // Background Wavy Header
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: WavyHeader(),
                    ),
                    // Main Content
                    Column(
                      children: [
                        SizedBox(height: constraints.maxHeight * 0.48),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: LoginCard(),
                        ),
                        const Spacer(),
                        // Footer
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0, top: 24.0),
                          child: RichText(
                            text: const TextSpan(
                              text: 'Tidak punya akun? ',
                              style: TextStyle(
                                color: Color(0xFF41241A),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: 'SignUP',
                                  style: TextStyle(
                                    color: Color(0xFF29B6F6),
                                    fontWeight: FontWeight.bold,
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
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WavyHeader extends StatelessWidget {
  const WavyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: WavyHeaderClipper(),
      child: Container(
        // Kita kunci tinggi containernya agar konsisten
        height: MediaQuery.of(context).size.height * 0.45,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF41241A),
              Color(0xFF895037),
            ],
          ),
        ),
        child: SafeArea(
          // SafeArea memastikan logo tidak kena notch/poni HP
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Mulai dari atas
            children: [
              const SizedBox(height: 30), // Jarak ideal dari atas
              
              // Bagian Logo
              SvgPicture.asset(
                'assets/image/cashybara-logo.svg',
                height: 120, // Ukuran logo yang proporsional
              ),
              
              const SizedBox(height: 15),
              
              // Nama Aplikasi
              const Text(
                'CashyBara',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32, // Sedikit diperbesar agar tegas
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              
              const SizedBox(height: 5),
              
              // Slogan
              const Text(
                'Kelola Keuangan Se-santai Masbro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70, // Pakai white70 supaya lebih soft
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WavyHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // Garis dasar kiri
    path.lineTo(0, size.height - 60);

    // Gelombang pertama
    var firstControlPoint = Offset(size.width * 0.25, size.height);
    var firstEndPoint = Offset(size.width * 0.5, size.height - 35);
    path.quadraticBezierTo(
      firstControlPoint.dx, 
      firstControlPoint.dy,
      firstEndPoint.dx, 
      firstEndPoint.dy,
    );

    // Gelombang kedua
    var secondControlPoint = Offset(size.width * 0.75, size.height - 75);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx, 
      secondControlPoint.dy,
      secondEndPoint.dx, 
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class IncomeCard extends StatelessWidget {
  const IncomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita pakai Consumer supaya kartu ini dengerin perubahan data di Provider
    return Consumer<TransactionProvider>(
      builder: (context, transProvider, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Main dark brown container
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF6B4434),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Section: Total Saldo Keseluruhan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Rp ${transProvider.totalBalance.toInt()}', // AMBIL DARI PROVIDER
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white70, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Inner light container (Detail BCA & Tunai)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFC4B5AE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Column(
                      children: [
                        // Row 1: BCA / Rekening
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF003B71),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'BCA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Rekening',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4A1B14),
                                  ),
                                ),
                                Text(
                                  'Rp ${transProvider.bcaBalance.toInt()}', // AMBIL DARI PROVIDER
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF4A1B14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Row 2: Cash / Uang Tunai
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black87),
                              ),
                              child: const Center(
                                child: Icon(Icons.attach_money, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Uang Tunai',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4A1B14),
                                  ),
                                ),
                                Text(
                                  'Rp ${transProvider.cashBalance.toInt()}', // AMBIL DARI PROVIDER
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF4A1B14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Overlapping Capybara Image
            Positioned(
              top: -40,
              left: -20,
              child: Image.asset(
                'assets/capybara_laying.png',
                width: 120,
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.brown,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.pets, color: Colors.white, size: 40),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
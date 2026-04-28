import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/expense_grid_item.dart';
import '../widgets/income_card.dart';
import '../providers/transaction_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Fungsi untuk menghitung total per kategori secara otomatis
  double _getTotalByCategory(TransactionProvider provider, String categoryTitle) {
    return provider.items
        .where((item) => item.title == categoryTitle)
        .fold(0, (sum, item) => sum + item.amount);
  }

  // Fungsi Memunculkan Dialog Input Nominal
  void _addExpense(BuildContext context, String title, IconData icon) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Input $title"),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Masukkan nominal",
            prefixText: "Rp ",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF41241A),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                double inputAmount = double.tryParse(amountController.text) ?? 0;
                
                if (inputAmount > 0) {
                  Provider.of<TransactionProvider>(context, listen: false)
                      .addTransaction(title, inputAmount, icon);

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Berhasil mencatat $title! 🐾"),
                      backgroundColor: const Color(0xFF41241A),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), 
                  const Row(
                    children: [
                      Icon(Icons.chevron_left, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Bulan Ini',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.chevron_right, size: 24),
                    ],
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: const AssetImage('assets/capybara_profile.png'),
                    onBackgroundImageError: (exception, stackTrace) {},
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- RINGKASAN PENGELUARAN ---
              Consumer<TransactionProvider>(
                builder: (context, transProvider, child) {
                  return RichText(
                    text: TextSpan(
                      text: 'Pengeluaran ',
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'Rp${transProvider.totalBalance.toInt()}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // --- GRID KATEGORI ---
              Consumer<TransactionProvider>(
                builder: (context, transProvider, child) {
                  return GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                    children: [
                      _buildCategoryItem(context, transProvider, 'Makanan & Minuman', Icons.fastfood, 
                        const Color(0xFFFFF9DB), const Color(0xFFFFD54F), 'assets/capybara_food.png'),
                      _buildCategoryItem(context, transProvider, 'Transportasi', Icons.directions_car, 
                        const Color(0xFFE3F2FD), const Color(0xFF64B5F6), 'assets/capybara_transport.png'),
                      _buildCategoryItem(context, transProvider, 'Tagihan Rumah', Icons.home, 
                        const Color(0xFFFFE0B2), const Color(0xFFFFB74D), 'assets/capybara_house.png'),
                      _buildCategoryItem(context, transProvider, 'Perawatan', Icons.spa, 
                        const Color(0xFFF3E5F5), const Color(0xFFBA68C8), 'assets/capybara_care.png'),
                      _buildCategoryItem(context, transProvider, 'Belanja', Icons.shopping_bag, 
                        const Color(0xFFFFEBEE), const Color(0xFFE57373), 'assets/capybara_shop.png'),
                      _buildCategoryItem(context, transProvider, 'Kesehatan', Icons.medical_services, 
                        const Color(0xFFE0F2F1), const Color(0xFF4DB6AC), 'assets/capybara_health.png'),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              const Text(
                'Total Pendapatan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const IncomeCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      // BOTTOM NAVIGATION BAR SUDAH DIHAPUS DARI SINI
      // Navigasi bawah sekarang dikelola oleh MainNavigation di main.dart
    );
  }

  Widget _buildCategoryItem(BuildContext context, TransactionProvider provider, String title, IconData icon, Color bg, Color iconBg, String img) {
    return GestureDetector(
      onTap: () => _addExpense(context, title, icon),
      child: ExpenseGridItem(
        title: title,
        backgroundColor: bg,
        iconBackgroundColor: iconBg,
        imagePath: img,
        amount: 'Rp${_getTotalByCategory(provider, title).toInt()}',
      ),
    );
  }
}
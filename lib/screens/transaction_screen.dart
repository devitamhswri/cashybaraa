import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transProvider, child) {
          if (transProvider.items.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada transaksi, Masbro. Santai dulu! 🦦',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: transProvider.items.length,
            itemBuilder: (context, index) {
              final item = transProvider.items[index];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade100),
                ),
                child: ListTile(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Detail untuk ${item.title}")),
                    );
                  },
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9DB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item.icon, color: const Color(0xFF41241A)),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    item.time,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  trailing: Text(
                    "-Rp${item.amount.toInt()}",
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      // --- INI TOMBOL TAMBAHNYA ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF41241A),
        onPressed: () {
          // Setiap kali ditekan, akan menambah transaksi dummy untuk tes
          context.read<TransactionProvider>().addTransaction(
                "Makan Masbro",
                25000,
                Icons.fastfood_rounded,
              );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
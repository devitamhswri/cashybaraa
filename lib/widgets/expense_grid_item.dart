import 'package:flutter/material.dart';

class ExpenseGridItem extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final String imagePath;
  final String amount;

  const ExpenseGridItem({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.imagePath,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                imagePath,
                width: 28,
                height: 28,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.category,
                    size: 24,
                    color: Colors.black54,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

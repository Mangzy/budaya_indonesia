import 'package:flutter/material.dart';

class ScoreBar extends StatelessWidget {
  final int currentScore;
  final int maxScore;

  const ScoreBar({
    super.key,
    required this.currentScore,
    required this.maxScore,
  });

  @override
  Widget build(BuildContext context) {
    final progress = maxScore > 0 ? currentScore / maxScore : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Score text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Skor',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '$currentScore/$maxScore',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFC107), // Yellow
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress bar with animation
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            tween: Tween<double>(begin: 0, end: progress),
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 12,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFFC107), // Yellow
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

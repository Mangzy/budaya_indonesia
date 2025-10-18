import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_model.dart';
import '../providers/quiz_provider.dart';
import 'category_selection_page.dart';

class ResultPage extends StatelessWidget {
  final QuizResult result;

  const ResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emoji
                Text(result.emoji, style: const TextStyle(fontSize: 100)),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Quiz Selesai!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                // Grade
                Text(
                  result.grade,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4DB6AC),
                  ),
                ),
                const SizedBox(height: 40),

                // Score card
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Total Score
                      const Text(
                        'Skor Anda',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFFFC107),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '${result.totalScore}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFC107),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Divider
                      const Divider(thickness: 1.5),
                      const SizedBox(height: 20),

                      // Statistics
                      _buildStatRow(
                        icon: Icons.check_circle,
                        iconColor: Colors.green,
                        label: 'Benar',
                        value: '${result.correctAnswers}',
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        icon: Icons.cancel,
                        iconColor: Colors.red,
                        label: 'Salah',
                        value: '${result.wrongAnswers}',
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        icon: Icons.quiz,
                        iconColor: const Color(0xFF4DB6AC),
                        label: 'Total Soal',
                        value: '${result.totalQuestions}',
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        icon: Icons.timer,
                        iconColor: Colors.orange,
                        label: 'Waktu',
                        value: result.formattedTime,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Action buttons
                Row(
                  children: [
                    // Back to home button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.read<QuizProvider>().clearAll();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CategorySelectionPage(),
                            ),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.home),
                        label: const Text('Beranda'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(
                            color: Color(0xFF4DB6AC),
                            width: 2,
                          ),
                          foregroundColor: const Color(0xFF4DB6AC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Retry button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final provider = context.read<QuizProvider>();
                          provider.resetQuiz();
                          provider.retryLoadQuestions();

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CategorySelectionPage(),
                            ),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4DB6AC),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

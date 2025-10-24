import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:budaya_indonesia/common/static/app_color.dart';
import '../models/quiz_model.dart';
import '../providers/quiz_provider.dart';

class ResultPage extends StatelessWidget {
  final QuizResult result;

  const ResultPage({super.key, required this.result});

  String get motivationalMessage {
    final percentage = (result.correctAnswers / result.totalQuestions) * 100;

    if (percentage < 50) {
      return 'Jangan menyerah! Pelajari lagi budaya Indonesia dan coba lagi! 💪';
    } else if (percentage < 70) {
      return 'Bagus! Kamu sudah cukup paham, tingkatkan lagi! 👍';
    } else if (percentage < 85) {
      return 'Hebat! Pengetahuanmu tentang budaya Indonesia sangat baik! 🌟';
    } else {
      return 'Luar biasa! Kamu ahli budaya Indonesia! 🏆';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tertiary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Quiz Selesai!',
                  style: GoogleFonts.montserrat(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  motivationalMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(24),
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
                      Text(
                        'Skor Anda',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.accent, width: 2),
                        ),
                        child: Text(
                          '${result.totalScore}',
                          style: GoogleFonts.montserrat(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Divider(thickness: 1.5),
                      const SizedBox(height: 12),

                      _buildStatRow(
                        icon: Icons.check_circle,
                        iconColor: Colors.green,
                        label: 'Benar',
                        value: '${result.correctAnswers}',
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        icon: Icons.cancel,
                        iconColor: Colors.red,
                        label: 'Salah',
                        value: '${result.wrongAnswers}',
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        icon: Icons.quiz,
                        iconColor: AppColors.primary,
                        label: 'Total Soal',
                        value: '${result.totalQuestions}',
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        icon: Icons.timer,
                        iconColor: Colors.orange,
                        label: 'Waktu',
                        value: result.formattedTime,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<QuizProvider>().clearAll();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home),
                    label: Text(
                      'Kembali ke Beranda',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
          style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

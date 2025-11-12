import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:budaya_indonesia/common/static/app_color.dart';
import '../models/quiz_model.dart';
import '../providers/quiz_provider.dart';

class ResultPage extends StatefulWidget {
  final QuizResult result;

  const ResultPage({super.key, required this.result});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _showReview = false;

  String get motivationalMessage {
    final percentage =
        (widget.result.correctAnswers / widget.result.totalQuestions) * 100;

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
    if (_showReview) {
      return _buildReviewPage(context);
    }

    return Scaffold(
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
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  motivationalMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 2,
                    ),
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
                        style: GoogleFonts.montserrat(fontSize: 18),
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
                          '${widget.result.totalScore}',
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
                        value: '${widget.result.correctAnswers}',
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        icon: Icons.cancel,
                        iconColor: Colors.red,
                        label: 'Salah',
                        value: '${widget.result.wrongAnswers}',
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        icon: Icons.quiz,
                        iconColor: AppColors.primary,
                        label: 'Total Soal',
                        value: '${widget.result.totalQuestions}',
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        icon: Icons.timer,
                        iconColor: Colors.orange,
                        label: 'Waktu',
                        value: widget.result.formattedTime,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Review Jawaban
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showReview = true;
                      });
                    },
                    icon: const Icon(Icons.article_outlined),
                    label: Text(
                      'Lihat Pembahasan Jawaban',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

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
    return Builder(
      builder: (context) => Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.montserrat(fontSize: 16)),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewPage(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final questions = quiz.questions;
    final userAnswers = quiz.userAnswers;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _showReview = false;
            });
          },
        ),
        title: Text(
          'Pembahasan Jawaban',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final userAnswerIndex = userAnswers[index];
          final correctIndex = question.correctAnswerIndex;
          final isCorrect =
              userAnswerIndex != null && userAnswerIndex == correctIndex;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isCorrect ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header dengan nomor dan status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Soal ${index + 1}',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isCorrect ? Colors.green : Colors.red,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? Colors.green : Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isCorrect ? 'Benar' : 'Salah',
                              style: GoogleFonts.montserrat(
                                color: isCorrect ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Gambar soal (jika ada)
                  if (question.imageUrl != null &&
                      question.imageUrl!.isNotEmpty)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          question.imageUrl!,
                          height: 180,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  if (question.imageUrl != null &&
                      question.imageUrl!.isNotEmpty)
                    const SizedBox(height: 12),

                  // Pertanyaan
                  Text(
                    question.question,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pilihan jawaban
                  ...List.generate(question.options.length, (optIndex) {
                    final letter = String.fromCharCode(65 + optIndex);
                    final isUserAnswer = userAnswerIndex == optIndex;
                    final isCorrectAnswer = correctIndex == optIndex;

                    Color? backgroundColor;
                    Color? borderColor;
                    Color? textColor;
                    IconData? icon;

                    if (isCorrectAnswer) {
                      backgroundColor = Colors.green.withOpacity(0.1);
                      borderColor = Colors.green;
                      textColor = Colors.green.shade800;
                      icon = Icons.check_circle;
                    } else if (isUserAnswer && !isCorrect) {
                      backgroundColor = Colors.red.withOpacity(0.1);
                      borderColor = Colors.red;
                      textColor = Colors.red.shade800;
                      icon = Icons.cancel;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: backgroundColor ?? Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: borderColor ?? Colors.grey.shade300,
                          width: borderColor != null ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: borderColor ?? Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                letter,
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question.options[optIndex],
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: textColor,
                                fontWeight: (isCorrectAnswer || isUserAnswer)
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (icon != null)
                            Icon(icon, color: borderColor, size: 20),
                        ],
                      ),
                    );
                  }),

                  // Info tambahan
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Kunci Jawaban',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          correctIndex != null
                              ? '${String.fromCharCode(65 + correctIndex)}. ${question.options[correctIndex]}'
                              : '-',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
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
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

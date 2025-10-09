import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budaya_indonesia/common/widgets/loading_indicator.dart';
import 'package:budaya_indonesia/common/widgets/error_message.dart';
import '../providers/quiz_provider.dart';
import '../models/quiz_model.dart';
import '../widgets/skor.dart';
import '../widgets/option_button.dart';
import 'result_page.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        title: Consumer<QuizProvider>(
          builder: (context, quiz, _) {
            return Text(
              quiz.selectedCategory?.displayName ?? 'Quiz',
              style: const TextStyle(fontWeight: FontWeight.bold),
            );
          },
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitConfirmation(context),
        ),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quiz, _) {
          // Loading state
          if (quiz.state.isLoading) {
            return const LoadingIndicator();
          }

          // Error state
          if (quiz.state.isError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ErrorMessage(
                    message: quiz.state.message ?? 'Terjadi kesalahan',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => quiz.retryLoadQuestions(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4DB6AC),
                    ),
                  ),
                ],
              ),
            );
          }

          // No questions
          if (quiz.questions.isEmpty) {
            return const Center(child: Text('Tidak ada soal tersedia'));
          }

          final question = quiz.currentQuestion;
          if (question == null) {
            return const Center(child: Text('Soal tidak ditemukan'));
          }

          return _buildQuizContent(context, quiz, question);
        },
      ),
    );
  }

  Widget _buildQuizContent(
    BuildContext context,
    QuizProvider quiz,
    QuizQuestion question,
  ) {
    final selectedAnswer = quiz.getSelectedAnswer(quiz.currentQuestionIndex);

    return Column(
      children: [
        // Score bar at top
        ScoreBar(currentScore: quiz.currentScore, maxScore: 100),

        // Question counter
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '${quiz.currentQuestionIndex + 1}/${quiz.totalQuestions}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        // Main content (scrollable)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image (conditional - only if exists)
                if (question.imageUrl != null && question.imageUrl!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        question.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              color: const Color(0xFF4DB6AC),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Gambar tidak dapat dimuat',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Question text card
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Options A, B, C, D
                ...List.generate(question.options.length, (index) {
                  final letter = String.fromCharCode(65 + index); // A, B, C, D
                  return OptionButton(
                    optionLetter: letter,
                    optionText: question.options[index],
                    isSelected: selectedAnswer == index,
                    onTap: () => quiz.answerQuestion(index),
                  );
                }),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Navigation buttons at bottom
        _buildNavigationButtons(context, quiz),
      ],
    );
  }

  Widget _buildNavigationButtons(BuildContext context, QuizProvider quiz) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button (only show if not first question)
          if (quiz.hasPreviousQuestion)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: quiz.previousQuestion,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Sebelumnya'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF4DB6AC), width: 2),
                  foregroundColor: const Color(0xFF4DB6AC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),

          if (quiz.hasPreviousQuestion) const SizedBox(width: 12),

          // Next/Submit button
          Expanded(
            flex: quiz.hasPreviousQuestion ? 1 : 2,
            child: ElevatedButton.icon(
              onPressed: () {
                if (quiz.hasNextQuestion) {
                  // Go to next question
                  quiz.nextQuestion();
                } else {
                  // Last question - show submit confirmation
                  _showSubmitConfirmation(context, quiz);
                }
              },
              icon: Icon(
                quiz.hasNextQuestion ? Icons.arrow_forward : Icons.check,
              ),
              label: Text(quiz.hasNextQuestion ? 'Selanjutnya' : 'Selesai'),
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
    );
  }

  void _showSubmitConfirmation(BuildContext context, QuizProvider quiz) {
    final unanswered = quiz.getUnansweredQuestions();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Selesaikan Quiz?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          unanswered.isEmpty
              ? 'Anda telah menjawab semua soal.\n\nApakah Anda yakin ingin menyelesaikan quiz?'
              : 'Ada ${unanswered.length} soal yang belum dijawab.\n\nApakah Anda yakin ingin menyelesaikan quiz?',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              final result = quiz.submitQuiz();

              // Navigate to result page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultPage(result: result),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4DB6AC),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar Quiz?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Progress quiz Anda akan hilang.\n\nApakah Anda yakin ingin keluar?',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<QuizProvider>().clearAll();
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Back to previous page
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

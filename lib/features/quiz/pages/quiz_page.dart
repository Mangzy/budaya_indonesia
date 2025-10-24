import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:budaya_indonesia/common/static/app_color.dart';
import 'package:budaya_indonesia/common/widgets/loading_indicator.dart';
import 'package:budaya_indonesia/common/widgets/error_message.dart';
import '../providers/quiz_provider.dart';
import '../models/quiz_model.dart';
import '../widgets/skor.dart';
import '../widgets/option_button.dart';
import 'result_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  bool _showingFeedback = false;
  bool _isLastAnswerCorrect = false;
  bool _hasNavigatedToResult = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final quiz = context.watch<QuizProvider>();

    if (quiz.isQuizCompleted &&
        quiz.lastResult != null &&
        !_hasNavigatedToResult) {
      _hasNavigatedToResult = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultPage(result: quiz.lastResult!),
            ),
          );
        }
      });
    } else if (!quiz.isQuizCompleted) {
      _hasNavigatedToResult = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _showExitConfirmation(context),
        ),
        title: Text(
          'Quiz Budaya',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Consumer<QuizProvider>(
            builder: (context, quiz, _) {
              final isWarning = quiz.isTimerWarning;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      color: isWarning ? Colors.red : null,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      quiz.formattedTime,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isWarning ? Colors.red : null,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quiz, _) {
          if (quiz.state.isLoading) {
            return const LoadingIndicator();
          }

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
                    label: Text('Coba Lagi', style: GoogleFonts.montserrat()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (quiz.questions.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada soal tersedia',
                style: GoogleFonts.montserrat(),
              ),
            );
          }

          final question = quiz.currentQuestion;
          if (question == null) {
            return Center(
              child: Text(
                'Soal tidak ditemukan',
                style: GoogleFonts.montserrat(),
              ),
            );
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
        ScoreBar(currentScore: quiz.confirmedScore, maxScore: 100),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '${quiz.currentQuestionIndex + 1}/${quiz.totalQuestions}',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (question.imageUrl != null && question.imageUrl!.isNotEmpty)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        question.imageUrl!,
                        height: 220,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 220,
                            width: 180,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 220,
                            width: 180,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceVariant.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                    color: Theme.of(
                                      context,
                                    ).iconTheme.color?.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Gambar tidak dapat dimuat',
                                    style: GoogleFonts.montserrat(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                if (question.imageUrl != null && question.imageUrl!.isNotEmpty)
                  const SizedBox(height: 12),

                Text(
                  question.question,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                ...List.generate(question.options.length, (index) {
                  final letter = String.fromCharCode(65 + index);

                  bool showCorrect = false;
                  bool showWrong = false;

                  if (_showingFeedback) {
                    final correctIndex = question.correctAnswer;
                    if (index == correctIndex) {
                      showCorrect = true;
                    } else if (selectedAnswer == index &&
                        !_isLastAnswerCorrect) {
                      showWrong = true;
                    }
                  }

                  return OptionButton(
                    optionLetter: letter,
                    optionText: question.options[index],
                    isSelected: selectedAnswer == index,
                    showCorrect: showCorrect,
                    showWrong: showWrong,
                    onTap: _showingFeedback
                        ? null
                        : () => quiz.answerQuestion(index),
                  );
                }),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        _buildNavigationButtons(context, quiz),
      ],
    );
  }

  Widget _buildNavigationButtons(BuildContext context, QuizProvider quiz) {
    final hasAnswered =
        quiz.getSelectedAnswer(quiz.currentQuestionIndex) != null;

    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: hasAnswered
              ? () async {
                  final isCorrect = quiz.submitCurrentAnswer();

                  setState(() {
                    _showingFeedback = true;
                    _isLastAnswerCorrect = isCorrect;
                  });

                  await Future.delayed(const Duration(milliseconds: 1500));

                  setState(() {
                    _showingFeedback = false;
                  });

                  if (quiz.hasNextQuestion) {
                    quiz.nextQuestion();
                  } else {
                    if (!mounted) return;
                    _showSubmitConfirmation(context, quiz);
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade600,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                quiz.hasNextQuestion ? 'Selanjutnya' : 'Selesai',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                quiz.hasNextQuestion ? Icons.arrow_forward : Icons.check,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubmitConfirmation(BuildContext context, QuizProvider quiz) {
    final unanswered = quiz.getUnansweredQuestions();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Selesaikan Quiz?',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Text(
          unanswered.isEmpty
              ? 'Anda telah menjawab semua soal.\n\nApakah Anda yakin ingin menyelesaikan quiz?'
              : 'Ada ${unanswered.length} soal yang belum dijawab.\n\nApakah Anda yakin ingin menyelesaikan quiz?',
          style: GoogleFonts.montserrat(height: 1.4, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.montserrat(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final result = quiz.submitQuiz();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultPage(result: result),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text('Submit', style: GoogleFonts.montserrat(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Keluar Quiz?',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Text(
          'Progress quiz Anda akan hilang.\n\nApakah Anda yakin ingin keluar?',
          style: GoogleFonts.montserrat(height: 1.4, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.montserrat(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<QuizProvider>().clearAll();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text('Keluar', style: GoogleFonts.montserrat(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

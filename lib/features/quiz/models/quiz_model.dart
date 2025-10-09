/// Quiz Models untuk Budaya Indonesia
///
/// Mendukung 2 kategori quiz:
/// - Pakaian Daerah (dengan gambar)
/// - Lagu Daerah (tanpa gambar)

/// Enum untuk kategori quiz
enum QuizCategory {
  pakaian('Pakaian Daerah'),
  lagu('Lagu Daerah');

  final String displayName;
  const QuizCategory(this.displayName);
}

/// Model untuk pertanyaan quiz
class QuizQuestion {
  final int id;
  final String category;
  final String question;
  final List<String> options; // 4 pilihan jawaban
  final String correctAnswer; // Jawaban benar (full text)
  final String? imageUrl; // Optional, hanya untuk pakaian

  const QuizQuestion({
    required this.id,
    required this.category,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.imageUrl,
  });

  /// Factory constructor dari Supabase response
  ///
  /// Format Supabase:
  /// {
  ///   "id": 1,
  ///   "kategori": "lagu",
  ///   "question": "Lagu Ampar-Ampar Pisang berasal dari…",
  ///   "options": "Kalimantan Selatan|Kalimantan Barat|...",
  ///   "answer": "Kalimantan Selatan",
  ///   "image_url": null
  /// }
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    // Parse options dari format "Option1|Option2|Option3|Option4"
    final optionsString = json['options'] as String? ?? '';
    final optionsList = optionsString.split('|').map((e) => e.trim()).toList();

    return QuizQuestion(
      id: json['id'] as int,
      category: json['kategori'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options: optionsList,
      correctAnswer: (json['answer'] as String? ?? '').trim(),
      imageUrl: json['image_url'] as String?,
    );
  }

  /// Convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kategori': category,
      'question': question,
      'options': options.join('|'),
      'answer': correctAnswer,
      'image_url': imageUrl,
    };
  }

  /// Check apakah jawaban user benar
  ///
  /// [userAnswer] bisa berupa:
  /// - Index (0-3)
  /// - Full text jawaban
  bool isCorrect(dynamic userAnswer) {
    if (userAnswer == null) return false;

    // Jika userAnswer adalah index
    if (userAnswer is int) {
      if (userAnswer < 0 || userAnswer >= options.length) return false;
      return options[userAnswer].trim().toLowerCase() ==
          correctAnswer.trim().toLowerCase();
    }

    // Jika userAnswer adalah string
    if (userAnswer is String) {
      return userAnswer.trim().toLowerCase() ==
          correctAnswer.trim().toLowerCase();
    }

    return false;
  }

  /// Get index dari correct answer
  int? get correctAnswerIndex {
    for (int i = 0; i < options.length; i++) {
      if (options[i].trim().toLowerCase() ==
          correctAnswer.trim().toLowerCase()) {
        return i;
      }
    }
    return null;
  }

  @override
  String toString() {
    return 'QuizQuestion(id: $id, category: $category, question: $question, hasImage: ${imageUrl != null})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuizQuestion &&
        other.id == id &&
        other.category == category &&
        other.question == question;
  }

  @override
  int get hashCode => id.hashCode ^ category.hashCode ^ question.hashCode;
}

/// Model untuk hasil quiz
class QuizResult {
  final QuizCategory category;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int totalScore; // Benar * 10
  final double scorePercentage;
  final Duration timeTaken;
  final DateTime completedAt;

  const QuizResult({
    required this.category,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalScore,
    required this.scorePercentage,
    required this.timeTaken,
    required this.completedAt,
  });

  /// Factory constructor untuk calculate dari jawaban user
  factory QuizResult.calculate({
    required QuizCategory category,
    required List<QuizQuestion> questions,
    required Map<int, int> userAnswers, // Map<questionIndex, answerIndex>
    required DateTime startTime,
    required DateTime endTime,
  }) {
    int correctCount = 0;

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final userAnswerIndex = userAnswers[i];
      final isCorrect =
          userAnswerIndex != null && question.isCorrect(userAnswerIndex);

      if (isCorrect) correctCount++;
    }

    final wrongCount = questions.length - correctCount;
    final totalScore = correctCount * 10; // Benar = +10
    final percentage = questions.length > 0
        ? (correctCount / questions.length) * 100
        : 0.0;
    final duration = endTime.difference(startTime);

    return QuizResult(
      category: category,
      totalQuestions: questions.length,
      correctAnswers: correctCount,
      wrongAnswers: wrongCount,
      totalScore: totalScore,
      scorePercentage: percentage,
      timeTaken: duration,
      completedAt: endTime,
    );
  }

  /// Get grade berdasarkan percentage
  String get grade {
    if (scorePercentage >= 90) return 'Excellent';
    if (scorePercentage >= 80) return 'Very Good';
    if (scorePercentage >= 70) return 'Good';
    if (scorePercentage >= 60) return 'Fair';
    if (scorePercentage >= 50) return 'Pass';
    return 'Need Improvement';
  }

  /// Get emoji berdasarkan score
  String get emoji {
    if (scorePercentage >= 90) return '🏆';
    if (scorePercentage >= 80) return '🌟';
    if (scorePercentage >= 70) return '👍';
    if (scorePercentage >= 60) return '😊';
    if (scorePercentage >= 50) return '😐';
    return '😢';
  }

  /// Format time taken
  String get formattedTime {
    final minutes = timeTaken.inMinutes;
    final seconds = timeTaken.inSeconds.remainder(60);
    return '${minutes}m ${seconds}s';
  }

  @override
  String toString() {
    return 'QuizResult(category: ${category.displayName}, score: $totalScore, correct: $correctAnswers/$totalQuestions, percentage: ${scorePercentage.toStringAsFixed(1)}%)';
  }
}

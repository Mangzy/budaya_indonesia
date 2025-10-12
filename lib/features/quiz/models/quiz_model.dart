enum QuizCategory {
  pakaian('Pakaian Daerah'),
  lagu('Lagu Daerah');

  final String displayName;
  const QuizCategory(this.displayName);
}

class QuizQuestion {
  final int id;
  final String category;
  final String question;
  final List<String> options; // 4 pilihan jawaban
  final String correctAnswer; // jawaban benar (full text)
  final String? imageUrl; // optional, hanya untuk pakaian

  const QuizQuestion({
    required this.id,
    required this.category,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.imageUrl,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    final optionsString = map['opsi'] as String? ?? '';
    final optionsList = optionsString.split('|').map((e) => e.trim()).toList();

    return QuizQuestion(
      id: map['id'] as int,
      category: map['kategori'] as String? ?? '',
      question: map['pertanyaan'] as String? ?? '',
      options: optionsList,
      correctAnswer: (map['jawaban'] as String? ?? '').trim(),
      imageUrl: map['image_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kategori': category,
      'pertanyaan': question,
      'opsi': options.join('|'),
      'jawaban': correctAnswer,
      'image_url': imageUrl,
    };
  }

  bool isCorrect(dynamic userAnswer) {
    if (userAnswer == null) return false;

    if (userAnswer is int) {
      if (userAnswer < 0 || userAnswer >= options.length) return false;
      return options[userAnswer].trim().toLowerCase() ==
          correctAnswer.trim().toLowerCase();
    }

    if (userAnswer is String) {
      return userAnswer.trim().toLowerCase() ==
          correctAnswer.trim().toLowerCase();
    }

    return false;
  }

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

class QuizResult {
  final QuizCategory category;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int totalScore; // benar * 10
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

  factory QuizResult.calculate({
    required QuizCategory category,
    required List<QuizQuestion> questions,
    required Map<int, int> userAnswers,
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
    final totalScore = correctCount * 10;
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

  String get grade {
    if (scorePercentage >= 90) return 'Excellent';
    if (scorePercentage >= 80) return 'Very Good';
    if (scorePercentage >= 70) return 'Good';
    if (scorePercentage >= 60) return 'Fair';
    if (scorePercentage >= 50) return 'Pass';
    return 'Need Improvement';
  }

  String get emoji {
    if (scorePercentage >= 90) return '🏆';
    if (scorePercentage >= 80) return '🌟';
    if (scorePercentage >= 70) return '👍';
    if (scorePercentage >= 60) return '😊';
    if (scorePercentage >= 50) return '😐';
    return '😢';
  }

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

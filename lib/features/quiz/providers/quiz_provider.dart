import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budaya_indonesia/common/static/result_state.dart';
import '../models/quiz_model.dart';
import 'dart:developer' as dev;
import 'dart:math' as math;
import 'dart:async';

class QuizProvider extends ChangeNotifier {
  final SupabaseClient _client;
  Timer? _timer;

  QuizProvider({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  ResultState<List<QuizQuestion>> _state = ResultState.none();
  List<QuizQuestion> _questions = [];
  Map<int, int> _userAnswers = {};
  Map<int, bool> _submittedAnswers = {};
  int _currentQuestionIndex = 0;
  DateTime? _quizStartTime;
  bool _isQuizCompleted = false;
  QuizResult? _lastResult;
  QuizCategory? _selectedCategory;
  Duration _remainingTime = const Duration(minutes: 5);
  int _confirmedScore = 0;

  ResultState<List<QuizQuestion>> get state => _state;
  List<QuizQuestion> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isQuizCompleted => _isQuizCompleted;
  QuizResult? get lastResult => _lastResult;
  QuizCategory? get selectedCategory => _selectedCategory;
  Duration get remainingTime => _remainingTime;
  int get confirmedScore => _confirmedScore;
  bool get isTimerWarning => _remainingTime.inSeconds < 60;

  QuizQuestion? get currentQuestion {
    if (_currentQuestionIndex >= _questions.length) return null;
    return _questions[_currentQuestionIndex];
  }

  int get totalQuestions => _questions.length;
  int get answeredCount => _userAnswers.length;
  bool get hasNextQuestion => _currentQuestionIndex < _questions.length - 1;
  bool get hasPreviousQuestion => _currentQuestionIndex > 0;

  bool isAnswerSubmitted(int index) {
    return _submittedAnswers[index] == true;
  }

  Future<void> loadQuestions(QuizCategory category) async {
    dev.log(
      'loadQuestions() mulai - kategori: ${category.displayName}',
      name: 'QuizProvider',
    );

    _selectedCategory = category;
    _state = ResultState.loading();
    _isQuizCompleted = false;
    _lastResult = null;
    notifyListeners();

    try {
      dev.log('Mengambil data dari tabel soal_kuis', name: 'QuizProvider');

      final response = await _client
          .from('soal_kuis')
          .select()
          .eq('kategori', category.name)
          .order('id', ascending: true);

      dev.log(
        'Respon Supabase: ${response.length} soal untuk ${category.name}',
        name: 'QuizProvider',
      );

      final allQuestions = (response as List<dynamic>)
          .map((json) => QuizQuestion.fromMap(json as Map<String, dynamic>))
          .toList();

      if (allQuestions.isEmpty) {
        throw Exception(
          'Tidak ada soal tersedia untuk kategori ${category.displayName}',
        );
      }

      final shuffled = List<QuizQuestion>.from(allQuestions);
      shuffled.shuffle(math.Random());

      final selectedQuestions = shuffled
          .take(10)
          .map((question) => question.shuffleOptions())
          .toList();

      dev.log(
        'Terpilih ${selectedQuestions.length} soal acak dengan opsi yang diacak',
        name: 'QuizProvider',
      );

      _questions = selectedQuestions;
      _userAnswers = {};
      _submittedAnswers = {};
      _currentQuestionIndex = 0;
      _quizStartTime = DateTime.now();
      _remainingTime = const Duration(minutes: 5);
      _confirmedScore = 0;
      _state = ResultState.success(selectedQuestions);

      _startTimer();

      dev.log('Quiz berhasil dimuat', name: 'QuizProvider');
    } catch (e, stackTrace) {
      dev.log(
        'Kesalahan loadQuestions: $e',
        name: 'QuizProvider',
        error: e,
        stackTrace: stackTrace,
      );
      _state = ResultState.error(e.toString());
      _questions = [];
    }

    notifyListeners();
  }

  Future<void> retryLoadQuestions() async {
    if (_selectedCategory != null) {
      await loadQuestions(_selectedCategory!);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        notifyListeners();

        if (_remainingTime.inSeconds == 0) {
          dev.log(
            'Waktu habis, mengirim quiz secara otomatis',
            name: 'QuizProvider',
          );
          _timer?.cancel();
          submitQuiz();
        }
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    dev.log('Timer dihentikan', name: 'QuizProvider');
  }

  String get formattedTime {
    final minutes = _remainingTime.inMinutes;
    final seconds = _remainingTime.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool submitCurrentAnswer() {
    if (_submittedAnswers[_currentQuestionIndex] == true) {
      return false;
    }

    final userAnswer = _userAnswers[_currentQuestionIndex];
    if (userAnswer == null) {
      return false;
    }

    final question = _questions[_currentQuestionIndex];
    final isCorrect = question.isCorrect(userAnswer);

    _submittedAnswers[_currentQuestionIndex] = true;

    if (isCorrect) {
      _confirmedScore += 10;
      dev.log(
        'Jawaban benar! Skor +10, total: $_confirmedScore',
        name: 'QuizProvider',
      );
    } else {
      dev.log('Jawaban salah, skor tidak berubah', name: 'QuizProvider');
    }

    notifyListeners();
    return isCorrect;
  }

  void answerQuestion(int answerIndex) {
    if (_isQuizCompleted) {
      dev.log('Tidak bisa menjawab: quiz sudah selesai', name: 'QuizProvider');
      return;
    }

    if (answerIndex < 0 || answerIndex >= 4) {
      dev.log('Index jawaban tidak valid: $answerIndex', name: 'QuizProvider');
      return;
    }

    _userAnswers[_currentQuestionIndex] = answerIndex;

    dev.log(
      'Soal $_currentQuestionIndex dijawab: $answerIndex',
      name: 'QuizProvider',
    );

    notifyListeners();
  }

  int? getSelectedAnswer(int questionIndex) {
    return _userAnswers[questionIndex];
  }

  void clearCurrentAnswer() {
    _userAnswers.remove(_currentQuestionIndex);
    dev.log(
      'Jawaban dihapus untuk soal $_currentQuestionIndex',
      name: 'QuizProvider',
    );
    notifyListeners();
  }

  void nextQuestion() {
    if (!hasNextQuestion) return;
    _currentQuestionIndex++;
    dev.log('Berpindah ke soal $_currentQuestionIndex', name: 'QuizProvider');
    notifyListeners();
  }

  void previousQuestion() {
    if (!hasPreviousQuestion) return;
    _currentQuestionIndex--;
    dev.log('Kembali ke soal $_currentQuestionIndex', name: 'QuizProvider');
    notifyListeners();
  }

  void goToQuestion(int index) {
    if (index < 0 || index >= _questions.length) return;
    _currentQuestionIndex = index;
    dev.log('Melompat ke soal $_currentQuestionIndex', name: 'QuizProvider');
    notifyListeners();
  }

  QuizResult submitQuiz() {
    if (_isQuizCompleted && _lastResult != null) {
      return _lastResult!;
    }

    _stopTimer();

    final endTime = DateTime.now();
    final startTime = _quizStartTime ?? endTime;

    if (_selectedCategory == null) {
      throw Exception('Quiz category tidak boleh null saat submit');
    }

    final result = QuizResult.calculate(
      category: _selectedCategory!,
      questions: _questions,
      userAnswers: _userAnswers,
      startTime: startTime,
      endTime: endTime,
    );

    _lastResult = result;
    _isQuizCompleted = true;

    dev.log(
      'Quiz dikirim: ${result.correctAnswers}/${result.totalQuestions} benar, skor: ${result.totalScore}',
      name: 'QuizProvider',
    );

    notifyListeners();
    return result;
  }

  bool isQuestionAnswered(int index) {
    return _userAnswers.containsKey(index);
  }

  bool? isAnswerCorrect(int questionIndex) {
    if (!_isQuizCompleted) return null;

    final userAnswer = _userAnswers[questionIndex];
    if (userAnswer == null) return false;

    final question = _questions[questionIndex];
    return question.isCorrect(userAnswer);
  }

  List<int> getUnansweredQuestions() {
    final unanswered = <int>[];
    for (int i = 0; i < _questions.length; i++) {
      if (!_userAnswers.containsKey(i)) {
        unanswered.add(i);
      }
    }
    return unanswered;
  }

  void resetQuiz() {
    _state = ResultState.none();
    _questions = [];
    _userAnswers = {};
    _currentQuestionIndex = 0;
    _quizStartTime = null;
    _isQuizCompleted = false;
    _lastResult = null;

    dev.log('State quiz direset', name: 'QuizProvider');
    notifyListeners();
  }

  void clearAll() {
    _state = ResultState.none();
    _questions = [];
    _userAnswers = {};
    _currentQuestionIndex = 0;
    _quizStartTime = null;
    _isQuizCompleted = false;
    _lastResult = null;
    _selectedCategory = null;

    dev.log('Semua state quiz dibersihkan', name: 'QuizProvider');
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    dev.log('QuizProvider dibuang', name: 'QuizProvider');
    super.dispose();
  }
}

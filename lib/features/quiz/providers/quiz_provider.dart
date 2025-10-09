import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budaya_indonesia/common/static/result_state.dart';
import '../models/quiz_model.dart';
import 'dart:developer' as dev;
import 'dart:math' as math;

/// Provider untuk Quiz Feature
///
/// Mengikuti pattern dari ProfileProvider dan MusicDetailProvider
/// - State management dengan ResultState<T>
/// - Supabase integration
/// - Error handling dengan try-catch
/// - Logging dengan dev.log()
class QuizProvider extends ChangeNotifier {
  final SupabaseClient _client;

  QuizProvider({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  // ============================================================================
  // STATE VARIABLES (pattern dari ProfileProvider)
  // ============================================================================

  ResultState<List<QuizQuestion>> _state = ResultState.none();
  List<QuizQuestion> _questions = [];
  Map<int, int> _userAnswers = {}; // Map<questionIndex, answerIndex>
  int _currentQuestionIndex = 0;
  DateTime? _quizStartTime;
  bool _isQuizCompleted = false;
  QuizResult? _lastResult;
  QuizCategory? _selectedCategory;

  // ============================================================================
  // GETTERS (pattern dari ProfileProvider)
  // ============================================================================

  ResultState<List<QuizQuestion>> get state => _state;
  List<QuizQuestion> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isQuizCompleted => _isQuizCompleted;
  QuizResult? get lastResult => _lastResult;
  QuizCategory? get selectedCategory => _selectedCategory;

  QuizQuestion? get currentQuestion {
    if (_currentQuestionIndex >= _questions.length) return null;
    return _questions[_currentQuestionIndex];
  }

  int get totalQuestions => _questions.length;
  int get answeredCount => _userAnswers.length;
  bool get hasNextQuestion => _currentQuestionIndex < _questions.length - 1;
  bool get hasPreviousQuestion => _currentQuestionIndex > 0;

  /// Get current score (temporary, during quiz)
  int get currentScore {
    int correct = 0;
    for (int i = 0; i < _questions.length; i++) {
      final answer = _userAnswers[i];
      if (answer != null && _questions[i].isCorrect(answer)) {
        correct++;
      }
    }
    return correct * 10;
  }

  // ============================================================================
  // LOAD QUESTIONS (pattern dari MusicDetailProvider)
  // ============================================================================

  /// Load random 10 questions dari Supabase
  ///
  /// Flow:
  /// 1. Set loading state
  /// 2. Fetch dari Supabase dengan filter kategori
  /// 3. Shuffle & ambil 10 random
  /// 4. Set success/error state
  Future<void> loadQuestions(QuizCategory category) async {
    dev.log(
      'loadQuestions() start - category: ${category.displayName}',
      name: 'QuizProvider',
    );

    _selectedCategory = category;
    _state = ResultState.loading();
    _isQuizCompleted = false;
    _lastResult = null;
    notifyListeners();

    try {
      // Fetch dari Supabase dengan filter kategori
      dev.log('Fetching from soal_kuis table', name: 'QuizProvider');

      final response = await _client
          .from('soal_kuis')
          .select()
          .eq('kategori', category.name) // Filter by category
          .order('id', ascending: true);

      dev.log(
        'Supabase response: ${response.length} questions for ${category.name}',
        name: 'QuizProvider',
      );

      // Parse ke QuizQuestion objects
      final allQuestions = (response as List<dynamic>)
          .map((json) => QuizQuestion.fromJson(json as Map<String, dynamic>))
          .toList();

      if (allQuestions.isEmpty) {
        throw Exception(
          'Tidak ada soal tersedia untuk kategori ${category.displayName}',
        );
      }

      // Shuffle dan ambil 10 random questions
      final shuffled = List<QuizQuestion>.from(allQuestions);
      shuffled.shuffle(math.Random());

      final selectedQuestions = shuffled.take(10).toList();

      dev.log(
        'Selected ${selectedQuestions.length} random questions',
        name: 'QuizProvider',
      );

      // Set state
      _questions = selectedQuestions;
      _userAnswers = {};
      _currentQuestionIndex = 0;
      _quizStartTime = DateTime.now();
      _state = ResultState.success(selectedQuestions);

      dev.log('Quiz loaded successfully', name: 'QuizProvider');
    } catch (e, stackTrace) {
      dev.log(
        'loadQuestions error: $e',
        name: 'QuizProvider',
        error: e,
        stackTrace: stackTrace,
      );
      _state = ResultState.error(e.toString());
      _questions = [];
    }

    notifyListeners();
  }

  /// Retry load questions (untuk error state)
  Future<void> retryLoadQuestions() async {
    if (_selectedCategory != null) {
      await loadQuestions(_selectedCategory!);
    }
  }

  // ============================================================================
  // ANSWER MANAGEMENT (pattern dari ProfileProvider)
  // ============================================================================

  /// Answer current question
  void answerQuestion(int answerIndex) {
    if (_isQuizCompleted) {
      dev.log('Cannot answer: quiz already completed', name: 'QuizProvider');
      return;
    }

    if (answerIndex < 0 || answerIndex >= 4) {
      dev.log('Invalid answer index: $answerIndex', name: 'QuizProvider');
      return;
    }

    _userAnswers[_currentQuestionIndex] = answerIndex;

    dev.log(
      'Question $_currentQuestionIndex answered: $answerIndex',
      name: 'QuizProvider',
    );

    notifyListeners();
  }

  /// Get selected answer untuk specific question index
  int? getSelectedAnswer(int questionIndex) {
    return _userAnswers[questionIndex];
  }

  /// Clear answer for current question
  void clearCurrentAnswer() {
    _userAnswers.remove(_currentQuestionIndex);
    dev.log(
      'Answer cleared for question $_currentQuestionIndex',
      name: 'QuizProvider',
    );
    notifyListeners();
  }

  // ============================================================================
  // NAVIGATION (pattern dari MusicDetailProvider)
  // ============================================================================

  void nextQuestion() {
    if (!hasNextQuestion) return;
    _currentQuestionIndex++;
    dev.log('Moved to question $_currentQuestionIndex', name: 'QuizProvider');
    notifyListeners();
  }

  void previousQuestion() {
    if (!hasPreviousQuestion) return;
    _currentQuestionIndex--;
    dev.log('Moved to question $_currentQuestionIndex', name: 'QuizProvider');
    notifyListeners();
  }

  void goToQuestion(int index) {
    if (index < 0 || index >= _questions.length) return;
    _currentQuestionIndex = index;
    dev.log('Jumped to question $_currentQuestionIndex', name: 'QuizProvider');
    notifyListeners();
  }

  // ============================================================================
  // QUIZ COMPLETION
  // ============================================================================

  /// Submit quiz dan calculate hasil
  QuizResult submitQuiz() {
    if (_isQuizCompleted && _lastResult != null) {
      return _lastResult!;
    }

    final endTime = DateTime.now();
    final startTime = _quizStartTime ?? endTime;

    // Calculate result
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
      'Quiz submitted: ${result.correctAnswers}/${result.totalQuestions} correct, score: ${result.totalScore}',
      name: 'QuizProvider',
    );

    notifyListeners();
    return result;
  }

  /// Check if question at index is answered
  bool isQuestionAnswered(int index) {
    return _userAnswers.containsKey(index);
  }

  /// Check if answer is correct (only after quiz completed)
  bool? isAnswerCorrect(int questionIndex) {
    if (!_isQuizCompleted) return null;

    final userAnswer = _userAnswers[questionIndex];
    if (userAnswer == null) return false;

    final question = _questions[questionIndex];
    return question.isCorrect(userAnswer);
  }

  /// Get unanswered question indices
  List<int> getUnansweredQuestions() {
    final unanswered = <int>[];
    for (int i = 0; i < _questions.length; i++) {
      if (!_userAnswers.containsKey(i)) {
        unanswered.add(i);
      }
    }
    return unanswered;
  }

  // ============================================================================
  // RESET (pattern dari ProfileProvider)
  // ============================================================================

  /// Reset quiz state (untuk retry dengan category yang sama)
  void resetQuiz() {
    _state = ResultState.none();
    _questions = [];
    _userAnswers = {};
    _currentQuestionIndex = 0;
    _quizStartTime = null;
    _isQuizCompleted = false;
    _lastResult = null;
    // _selectedCategory tetap ada untuk retry

    dev.log('Quiz state reset', name: 'QuizProvider');
    notifyListeners();
  }

  /// Clear everything termasuk selected category
  void clearAll() {
    _state = ResultState.none();
    _questions = [];
    _userAnswers = {};
    _currentQuestionIndex = 0;
    _quizStartTime = null;
    _isQuizCompleted = false;
    _lastResult = null;
    _selectedCategory = null;

    dev.log('All quiz state cleared', name: 'QuizProvider');
    notifyListeners();
  }

  @override
  void dispose() {
    dev.log('QuizProvider disposed', name: 'QuizProvider');
    super.dispose();
  }
}

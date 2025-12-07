import 'package:aprende_mas/models/subject_models.dart';
import 'package:aprende_mas/viewmodels/providers.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizUiState {
  final List<Question> questions;
  final int currentQuestionIndex;
  final String? selectedAnswer;
  final int score;
  final bool isQuizFinished;
  final bool isLoading;
  final bool isAnswerSubmitted;
  final String? feedbackMessage;
  final String? correctOptionKey;
  final Set<int> answeredQuestions;

  const QuizUiState({
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.selectedAnswer,
    this.score = 0,
    this.isQuizFinished = false,
    this.isLoading = true,
    this.isAnswerSubmitted = false,
    this.feedbackMessage,
    this.correctOptionKey,
    this.answeredQuestions = const {},
  });

  QuizUiState copyWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    String? selectedAnswer,
    int? score,
    bool? isQuizFinished,
    bool? isLoading,
    bool? isAnswerSubmitted,
    String? feedbackMessage,
    String? correctOptionKey,
    Set<int>? answeredQuestions,
  }) {
    return QuizUiState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      score: score ?? this.score,
      isQuizFinished: isQuizFinished ?? this.isQuizFinished,
      isLoading: isLoading ?? this.isLoading,
      isAnswerSubmitted: isAnswerSubmitted ?? this.isAnswerSubmitted,
      feedbackMessage: feedbackMessage ?? this.feedbackMessage,
      correctOptionKey: correctOptionKey ?? this.correctOptionKey,
      answeredQuestions: answeredQuestions ?? this.answeredQuestions,
    );
  }
}

class QuizViewModel extends StateNotifier<QuizUiState> {
  final Ref ref;
  final int moduleId;
  final int attemptId;

  QuizViewModel(this.ref, this.moduleId, this.attemptId)
    : super(const QuizUiState()) {
    _init(moduleId, attemptId);
  }

  TestAttempt? _currentAttempt;
  TestAttempt? get currentAttempt => _currentAttempt;

  Future<void> _init(int moduleId, int attemptId) async {
    if (attemptId == 0) {
      await _loadNewTest(moduleId);
    } else {
      await _loadAndResumeTest(moduleId, attemptId);
    }
  }

  Future<void> _loadNewTest(int moduleId) async {
    state = state.copyWith(isLoading: true);
    final repository = ref.read(studyRepositoryProvider);

    final questions = await repository.getOrCreateQuestionsForModule(moduleId);

    if (questions.isNotEmpty) {
      final newAttemptId = await repository.createTestAttempt(
        moduleId,
        questions.length,
      );
      _currentAttempt = TestAttempt(
        id: newAttemptId,
        moduleId: moduleId,
        status: "PENDING",
        totalQuestions: questions.length,
        currentQuestionIndex: 0,
        score: 0.0,
        correctAnswers: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }

    state = state.copyWith(questions: questions, isLoading: false);
  }

  Future<void> _loadAndResumeTest(int moduleId, int attemptId) async {
    state = state.copyWith(isLoading: true);
    final repository = ref.read(studyRepositoryProvider);

    _currentAttempt = await repository.getTestAttemptById(attemptId);
    final questions = await repository.getOrCreateQuestionsForModule(moduleId);
    final savedAnswers = await repository.getUserAnswersForAttempt(attemptId);

    if (_currentAttempt == null) {
      await _loadNewTest(moduleId);
      return;
    }

    final score = savedAnswers.where((a) => a.isCorrect == 1).length;
    final currentIndex = _currentAttempt!.currentQuestionIndex;
    final answeredQIds = savedAnswers.map((a) => a.questionId).toSet();

    final answeredIndices = questions
        .asMap()
        .entries
        .where((entry) => answeredQIds.contains(entry.value.id))
        .map((entry) => entry.key)
        .toSet();

    state = state.copyWith(
      questions: questions,
      currentQuestionIndex: currentIndex,
      score: score,
      isLoading: false,
      selectedAnswer: null,
      isAnswerSubmitted: false,
      feedbackMessage: null,
      correctOptionKey: null,
      answeredQuestions: answeredIndices,
    );
  }

  void onAnswerSelected(String answer) {
    if (!state.isAnswerSubmitted) {
      state = state.copyWith(selectedAnswer: answer);
    }
  }

  Future<void> onSaveAndContinueClicked() async {
    if (state.selectedAnswer == null || state.isAnswerSubmitted) return;

    final currentQuestion = state.questions[state.currentQuestionIndex];
    final selectedAnswerKey = state.selectedAnswer!;

    final isCorrect = selectedAnswerKey == currentQuestion.correctAnswer;
    final statusText = isCorrect ? "Correcto" : "Incorrecto";
    final explanationFromIA = currentQuestion.explanationText;
    final feedback = "$statusText: $explanationFromIA";

    final newScore = isCorrect ? state.score + 1 : state.score;

    await _saveAnswer(currentQuestion, selectedAnswerKey, isCorrect, feedback);

    state = state.copyWith(
      score: newScore,
      isAnswerSubmitted: true,
      feedbackMessage: feedback,
      correctOptionKey: currentQuestion.correctAnswer,
      answeredQuestions: {
        ...state.answeredQuestions,
        state.currentQuestionIndex,
      },
    );
  }

  Future<void> onSkipClicked() async {
    if (state.isAnswerSubmitted) return;

    state = state.copyWith(
      isAnswerSubmitted: false,
      selectedAnswer: null,
      feedbackMessage: null,
      correctOptionKey: null,
      answeredQuestions: {
        ...state.answeredQuestions,
        state.currentQuestionIndex,
      },
    );

    await onNextPage();
  }

  Future<void> onNextPage() async {
    final nextIndex = state.currentQuestionIndex + 1;
    final isLastQuestion = nextIndex >= state.questions.length;

    if (isLastQuestion) {
      state = state.copyWith(isQuizFinished: true, isAnswerSubmitted: false);
      await _finalizeAttempt();
    } else {
      state = state.copyWith(
        currentQuestionIndex: nextIndex,
        selectedAnswer: null,
        isAnswerSubmitted: false,
        feedbackMessage: null,
        correctOptionKey: null,
      );
      await _updateAttemptProgress(nextIndex, state.score);
    }
  }

  Future<void> onNextClicked() async {
    if (state.isAnswerSubmitted) {
      await onNextPage();
    }
  }

  Future<void> _saveAnswer(
    Question question,
    String selectedOption,
    bool isCorrect,
    String? feedback,
  ) async {
    final attemptId = _currentAttempt?.id;
    if (attemptId == null) return;

    final repository = ref.read(studyRepositoryProvider);
    await repository.saveUserAnswer(
      UserAnswer(
        testAttemptId: attemptId,
        questionId: question.id!,
        selectedOption: selectedOption,
        isCorrect: isCorrect ? 1 : 0,
        explanationText: feedback,
      ),
    );
  }

  Future<void> _updateAttemptProgress(int newIndex, int newScore) async {
    if (_currentAttempt == null) return;

    final updatedAttempt = _currentAttempt!.copyWith(
      correctAnswers: newScore,
      currentQuestionIndex: newIndex,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    _currentAttempt = updatedAttempt;

    final repository = ref.read(studyRepositoryProvider);
    await repository.updateTestAttempt(updatedAttempt);
  }

  Future<void> _finalizeAttempt() async {
    if (_currentAttempt == null) return;

    final totalQ = state.questions.isNotEmpty
        ? state.questions.length.toDouble()
        : 1.0;
    final finalScore = (state.score.toDouble() / totalQ) * 10.0;

    final finalAttempt = _currentAttempt!.copyWith(
      status: "COMPLETED",
      score: finalScore,
      correctAnswers: state.score,
      currentQuestionIndex: state.questions.length,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    final repository = ref.read(studyRepositoryProvider);
    await repository.updateTestAttempt(finalAttempt);
  }
}

// Using a record for family parameters
typedef QuizParams = (int moduleId, int attemptId);

final quizViewModelProvider =
    StateNotifierProvider.family<QuizViewModel, QuizUiState, QuizParams>((
      ref,
      params,
    ) {
      return QuizViewModel(ref, params.$1, params.$2);
    });

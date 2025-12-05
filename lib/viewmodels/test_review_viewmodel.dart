import 'package:aprende_mas/services/database/app_database.dart';
import 'package:aprende_mas/viewmodels/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReviewedQuestion {
  final Question question;
  final UserAnswer userAnswer;

  const ReviewedQuestion({required this.question, required this.userAnswer});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewedQuestion &&
        other.question == question &&
        other.userAnswer == userAnswer;
  }

  @override
  int get hashCode => Object.hash(question, userAnswer);
}

class TestReviewUiState {
  final bool isLoading;
  final TestAttempt? attempt;
  final Module? module;
  final List<ReviewedQuestion> reviewedQuestions;

  const TestReviewUiState({
    this.isLoading = true,
    this.attempt,
    this.module,
    this.reviewedQuestions = const [],
  });

  TestReviewUiState copyWith({
    bool? isLoading,
    TestAttempt? attempt,
    Module? module,
    List<ReviewedQuestion>? reviewedQuestions,
  }) {
    return TestReviewUiState(
      isLoading: isLoading ?? this.isLoading,
      attempt: attempt ?? this.attempt,
      module: module ?? this.module,
      reviewedQuestions: reviewedQuestions ?? this.reviewedQuestions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestReviewUiState &&
        other.isLoading == isLoading &&
        other.attempt == attempt &&
        other.module == module &&
        other.reviewedQuestions == reviewedQuestions;
  }

  @override
  int get hashCode =>
      Object.hash(isLoading, attempt, module, reviewedQuestions);
}

class TestReviewViewModel extends StateNotifier<TestReviewUiState> {
  final Ref ref;
  final int attemptId;

  TestReviewViewModel(this.ref, this.attemptId)
    : super(const TestReviewUiState()) {
    _loadReview(attemptId);
  }

  Future<void> _loadReview(int attemptId) async {
    final repository = ref.read(studyRepositoryProvider);

    try {
      final attempt = await repository.getTestAttemptById(attemptId);
      if (attempt == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final module = await repository.getModuleById(attempt.moduleId);
      final userAnswers = await repository.getUserAnswersForAttempt(attemptId);
      final questions = await repository.getOriginalQuestionsForModule(
        attempt.moduleId,
      );

      // Map questions to user answers
      final questionsMap = {for (var q in questions) q.id: q};

      final reviewedQuestions = userAnswers
          .map((ua) {
            final question = questionsMap[ua.questionId];
            if (question == null) return null;
            return ReviewedQuestion(question: question, userAnswer: ua);
          })
          .whereType<ReviewedQuestion>()
          .toList();

      state = state.copyWith(
        isLoading: false,
        attempt: attempt,
        module: module,
        reviewedQuestions: reviewedQuestions,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error
    }
  }
}

final testReviewViewModelProvider =
    StateNotifierProvider.family<TestReviewViewModel, TestReviewUiState, int>((
      ref,
      attemptId,
    ) {
      return TestReviewViewModel(ref, attemptId);
    });

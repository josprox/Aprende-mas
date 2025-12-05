import 'package:aprende_mas/viewmodels/test_review_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TestReviewScreen extends ConsumerWidget {
  final int attemptId;

  const TestReviewScreen({super.key, required this.attemptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(testReviewViewModelProvider(attemptId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.module?.title ?? "Revisión de Examen",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.attempt == null) {
            return const Center(
              child: Text("Error: No se encontró el examen."),
            );
          } else {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _TestResultHeader(
                  title: state.module?.title ?? "Examen",
                  score: state.attempt!.score,
                  correct: state.attempt!.correctAnswers,
                  total: state.attempt!.totalQuestions,
                ),
                const SizedBox(height: 20),
                ...state.reviewedQuestions.map(
                  (q) => _ReviewQuestionCard(reviewedQuestion: q),
                ),
                const SizedBox(height: 16),
              ],
            );
          }
        },
      ),
    );
  }
}

class _TestResultHeader extends StatelessWidget {
  final String title;
  final double score;
  final int correct;
  final int total;

  const _TestResultHeader({
    required this.title,
    required this.score,
    required this.correct,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = score >= 8.0;
    final colorScheme = Theme.of(context).colorScheme;
    final headerColor = isApproved
        ? colorScheme.tertiaryContainer
        : colorScheme.errorContainer;
    final scoreColor = isApproved
        ? colorScheme.onTertiaryContainer
        : colorScheme.error;

    return Card(
      color: headerColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Revisión: $title",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$correct de $total correctas",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  score.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewQuestionCard extends StatelessWidget {
  final ReviewedQuestion reviewedQuestion;

  const _ReviewQuestionCard({required this.reviewedQuestion});

  @override
  Widget build(BuildContext context) {
    final question = reviewedQuestion.question;
    final userAnswer = reviewedQuestion.userAnswer;
    final isUserCorrect = userAnswer.isCorrect;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isUserCorrect
              ? colorScheme.tertiary.withOpacity(0.8)
              : colorScheme.error.withOpacity(0.8),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.questionText,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _AnswerReviewOption(
              text: question.optionA,
              optionKey: "A",
              userSelection: userAnswer.selectedOption,
              correctAnswer: question.correctAnswer,
            ),
            const SizedBox(height: 8),
            _AnswerReviewOption(
              text: question.optionB,
              optionKey: "B",
              userSelection: userAnswer.selectedOption,
              correctAnswer: question.correctAnswer,
            ),
            const SizedBox(height: 8),
            _AnswerReviewOption(
              text: question.optionC,
              optionKey: "C",
              userSelection: userAnswer.selectedOption,
              correctAnswer: question.correctAnswer,
            ),
            const SizedBox(height: 8),
            _AnswerReviewOption(
              text: question.optionD,
              optionKey: "D",
              userSelection: userAnswer.selectedOption,
              correctAnswer: question.correctAnswer,
            ),
            if (userAnswer.explanationText != null &&
                userAnswer.explanationText!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                color: colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Explicación Detallada (IA):",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(userAnswer.explanationText!),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnswerReviewOption extends StatelessWidget {
  final String text;
  final String optionKey;
  final String userSelection;
  final String correctAnswer;

  const _AnswerReviewOption({
    required this.text,
    required this.optionKey,
    required this.userSelection,
    required this.correctAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = optionKey == correctAnswer;
    final isSelected = optionKey == userSelection;
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color contentColor;
    IconData? icon;
    Color iconColor;

    if (isCorrect) {
      backgroundColor = colorScheme.tertiaryContainer.withOpacity(0.8);
      contentColor = colorScheme.onTertiaryContainer;
      icon = Icons.check;
      iconColor = colorScheme.onTertiaryContainer;
    } else if (isSelected && !isCorrect) {
      backgroundColor = colorScheme.errorContainer.withOpacity(0.8);
      contentColor = colorScheme.onErrorContainer;
      icon = Icons.close;
      iconColor = colorScheme.onErrorContainer;
    } else {
      backgroundColor = colorScheme.surfaceContainerHighest.withOpacity(0.5);
      contentColor = colorScheme.onSurfaceVariant;
      icon = null;
      iconColor = Colors.transparent;
    }

    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: contentColor,
                  fontWeight: (isCorrect || isSelected)
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, color: iconColor),
            ],
          ],
        ),
      ),
    );
  }
}

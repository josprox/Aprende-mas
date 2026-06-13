import 'package:aprende_mas/viewmodels/test_review_viewmodel.dart';
import 'package:aprende_mas/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TestReviewScreen extends ConsumerWidget {
  final int attemptId;

  const TestReviewScreen({super.key, required this.attemptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(testReviewViewModelProvider(attemptId));

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.attempt == null) {
            return const CustomScrollView(
              slivers: [
                SliverAppBar.large(title: Text("Revisión")),
                SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.search_off_rounded,
                    title: "Examen no encontrado",
                    message: "No se pudo encontrar el intento solicitado.",
                  ),
                ),
              ],
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(state.module?.title ?? "Revisión"),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _TestResultHeader(
                      title: state.module?.title ?? "Examen",
                      score: state.attempt!.score,
                      correct: state.attempt!.correctAnswers,
                      total: state.attempt!.totalQuestions,
                    ),
                    const SizedBox(height: 16),
                    ...state.reviewedQuestions.asMap().entries.map(
                      (entry) =>
                          _ReviewQuestionCard(
                                index: entry.key + 1,
                                reviewedQuestion: entry.value,
                              )
                              .animate(delay: (35 * entry.key).ms)
                              .fadeIn()
                              .slideY(begin: 0.04, end: 0),
                    ),
                  ]),
                ),
              ),
            ],
          );
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
    final scheme = Theme.of(context).colorScheme;
    final accent = isApproved ? scheme.tertiary : scheme.error;
    final progress = total == 0 ? 0.0 : correct / total;

    return Card(
      color: isApproved ? scheme.tertiaryContainer : scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      color: accent,
                      backgroundColor: scheme.surface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  score.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "$correct de $total correctas",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.04, end: 0);
  }
}

class _ReviewQuestionCard extends StatelessWidget {
  final int index;
  final ReviewedQuestion reviewedQuestion;

  const _ReviewQuestionCard({
    required this.index,
    required this.reviewedQuestion,
  });

  @override
  Widget build(BuildContext context) {
    final question = reviewedQuestion.question;
    final userAnswer = reviewedQuestion.userAnswer;
    final isUserCorrect = userAnswer.isCorrect == 1;
    final scheme = Theme.of(context).colorScheme;
    final accent = isUserCorrect ? scheme.tertiary : scheme.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: accent.withValues(alpha: 0.16),
                  foregroundColor: accent,
                  child: Text(
                    "$index",
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.questionText,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _AnswerReviewOption(
              text: question.optionA,
              optionKey: "A",
              userSelection: userAnswer.selectedOption,
              correctAnswer: question.correctAnswer,
            ),
            _AnswerReviewOption(
              text: question.optionB,
              optionKey: "B",
              userSelection: userAnswer.selectedOption,
              correctAnswer: question.correctAnswer,
            ),
            _AnswerReviewOption(
              text: question.optionC,
              optionKey: "C",
              userSelection: userAnswer.selectedOption,
              correctAnswer: question.correctAnswer,
            ),
            _AnswerReviewOption(
              text: question.optionD,
              optionKey: "D",
              userSelection: userAnswer.selectedOption,
              correctAnswer: question.correctAnswer,
            ),
            if (userAnswer.explanationText != null &&
                userAnswer.explanationText!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: scheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        userAnswer.explanationText!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSecondaryContainer,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
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
    final scheme = Theme.of(context).colorScheme;

    final background = isCorrect
        ? scheme.tertiaryContainer
        : isSelected
        ? scheme.errorContainer
        : scheme.surfaceContainerHighest.withValues(alpha: 0.55);
    final foreground = isCorrect
        ? scheme.onTertiaryContainer
        : isSelected
        ? scheme.onErrorContainer
        : scheme.onSurfaceVariant;
    final icon = isCorrect
        ? Icons.check_circle_rounded
        : isSelected
        ? Icons.cancel_rounded
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: foreground.withValues(alpha: 0.12),
              foregroundColor: foreground,
              child: Text(
                optionKey,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: foreground,
                  fontWeight: (isCorrect || isSelected)
                      ? FontWeight.w800
                      : null,
                ),
              ),
            ),
            if (icon != null) Icon(icon, color: foreground),
          ],
        ),
      ),
    );
  }
}

import 'package:aprende_mas/viewmodels/quiz_viewmodel.dart';
import 'package:aprende_mas/views/test_review_screen.dart';
import 'package:aprende_mas/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizScreen extends ConsumerWidget {
  final int moduleId;
  final int attemptId;

  const QuizScreen({
    super.key,
    required this.moduleId,
    required this.attemptId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizViewModelProvider((moduleId, attemptId)));
    final notifier = ref.read(
      quizViewModelProvider((moduleId, attemptId)).notifier,
    );
    final scheme = Theme.of(context).colorScheme;

    double progress = 0.0;
    if (state.questions.isNotEmpty && !state.isQuizFinished) {
      progress = (state.currentQuestionIndex + 1) / state.questions.length;
    } else if (state.isQuizFinished) {
      progress = 1.0;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Test de conocimientos")),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const _GeneratingQuestions();
          }
          if (state.questions.isEmpty) {
            return const AppEmptyState(
              icon: Icons.psychology_alt_rounded,
              title: "No se generaron preguntas",
              message: "Inténtalo de nuevo desde el módulo.",
            );
          }
          if (state.isQuizFinished) {
            return _QuizResult(
              score: state.score,
              totalQuestions: state.questions.length,
              attemptId: notifier.currentAttempt?.id,
              onFinish: () => Navigator.pop(context),
              onReview: (id) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TestReviewScreen(attemptId: id),
                  ),
                );
              },
            );
          }

          final currentQuestion = state.questions[state.currentQuestionIndex];
          final isAnsweredOrSkipped = state.answeredQuestions.contains(
            state.currentQuestionIndex,
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    color: scheme.primary,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "Pregunta ${state.currentQuestionIndex + 1} de ${state.questions.length}",
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: scheme.onPrimaryContainer,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentQuestion.questionText,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.12,
                            ),
                      ),
                      const SizedBox(height: 22),
                      ...[
                        ("A", currentQuestion.optionA),
                        ("B", currentQuestion.optionB),
                        ("C", currentQuestion.optionC),
                        ("D", currentQuestion.optionD),
                      ].map(
                        (option) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AnswerOption(
                            text: option.$2,
                            optionKey: option.$1,
                            isSelected: state.selectedAnswer == option.$1,
                            isAnswerSubmitted: state.isAnswerSubmitted,
                            correctAnswerKey: state.correctOptionKey,
                            onSelected: () =>
                                notifier.onAnswerSelected(option.$1),
                          ),
                        ),
                      ),
                      if (state.isAnswerSubmitted &&
                          state.feedbackMessage != null)
                        _FeedbackCard(
                          message: state.feedbackMessage!,
                          isCorrect:
                              state.selectedAnswer == state.correctOptionKey,
                        ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainer.withValues(alpha: 0.96),
                    border: Border(
                      top: BorderSide(color: scheme.outlineVariant),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (!state.isAnswerSubmitted && !isAnsweredOrSkipped)
                        OutlinedButton.icon(
                          onPressed: notifier.onSkipClicked,
                          icon: const Icon(Icons.skip_next_rounded),
                          label: const Text("Saltar"),
                        )
                      else
                        const Spacer(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed:
                              (state.isAnswerSubmitted ||
                                  state.selectedAnswer != null)
                              ? () {
                                  if (state.isAnswerSubmitted) {
                                    notifier.onNextClicked();
                                  } else {
                                    notifier.onSaveAndContinueClicked();
                                  }
                                }
                              : null,
                          icon: Icon(
                            state.isAnswerSubmitted
                                ? Icons.arrow_forward_rounded
                                : Icons.check_rounded,
                          ),
                          label: Text(
                            state.isAnswerSubmitted
                                ? (state.currentQuestionIndex <
                                          state.questions.length - 1
                                      ? "Siguiente"
                                      : "Finalizar")
                                : "Responder",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GeneratingQuestions extends StatelessWidget {
  const _GeneratingQuestions();

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 54,
                height: 54,
                child: CircularProgressIndicator(strokeWidth: 5),
              ),
              const SizedBox(height: 18),
              Text(
                "Generando preguntas con IA...",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ).animate().fadeIn().scale(
            begin: const Offset(0.96, 0.96),
            end: const Offset(1, 1),
          ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  final String text;
  final String optionKey;
  final bool isSelected;
  final bool isAnswerSubmitted;
  final String? correctAnswerKey;
  final VoidCallback onSelected;

  const _AnswerOption({
    required this.text,
    required this.optionKey,
    required this.isSelected,
    required this.isAnswerSubmitted,
    required this.correctAnswerKey,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isCorrect = isAnswerSubmitted && optionKey == correctAnswerKey;
    final isIncorrect =
        isAnswerSubmitted && isSelected && optionKey != correctAnswerKey;

    final background = isCorrect
        ? scheme.tertiaryContainer
        : isIncorrect
        ? scheme.errorContainer
        : isSelected
        ? scheme.primaryContainer
        : scheme.surfaceContainerLow;
    final foreground = isCorrect
        ? scheme.onTertiaryContainer
        : isIncorrect
        ? scheme.onErrorContainer
        : isSelected
        ? scheme.onPrimaryContainer
        : scheme.onSurface;
    final border = isSelected || isCorrect || isIncorrect
        ? foreground.withValues(alpha: 0.4)
        : scheme.outlineVariant;

    return Card(
          color: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: border),
          ),
          child: InkWell(
            onTap: isAnswerSubmitted ? null : onSelected,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: foreground.withValues(alpha: 0.12),
                    foregroundColor: foreground,
                    child: Text(
                      optionKey,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: foreground,
                        fontWeight: isSelected || isCorrect
                            ? FontWeight.w800
                            : FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ),
                  if (isCorrect)
                    Icon(Icons.check_circle_rounded, color: foreground)
                  else if (isIncorrect)
                    Icon(Icons.cancel_rounded, color: foreground),
                ],
              ),
            ),
          ),
        )
        .animate(target: isSelected ? 1 : 0)
        .scaleXY(begin: 1, end: 1.015, duration: 150.ms);
  }
}

class _FeedbackCard extends StatelessWidget {
  final String message;
  final bool isCorrect;

  const _FeedbackCard({required this.message, required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = isCorrect
        ? scheme.tertiaryContainer
        : scheme.errorContainer;
    final foreground = isCorrect
        ? scheme.onTertiaryContainer
        : scheme.onErrorContainer;

    return Card(
      margin: const EdgeInsets.only(top: 10),
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isCorrect
                  ? Icons.lightbulb_rounded
                  : Icons.tips_and_updates_rounded,
              color: foreground,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.05, end: 0);
  }
}

class _QuizResult extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int? attemptId;
  final VoidCallback onFinish;
  final Function(int) onReview;

  const _QuizResult({
    required this.score,
    required this.totalQuestions,
    required this.attemptId,
    required this.onFinish,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final scoreRatio = totalQuestions > 0 ? score / totalQuestions : 0.0;
    final isApproved = scoreRatio >= 0.8;
    final scheme = Theme.of(context).colorScheme;
    final accent = isApproved ? scheme.tertiary : scheme.error;

    return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              color: isApproved
                  ? scheme.tertiaryContainer
                  : scheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isApproved
                          ? Icons.emoji_events_rounded
                          : Icons.auto_stories_rounded,
                      size: 58,
                      color: accent,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "Test finalizado",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isApproved
                          ? "Excelente trabajo. Dominas muy bien este tema."
                          : "Buen avance. Revisa tus respuestas y vuelve a intentarlo.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "$score / $totalQuestions",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        if (attemptId != null && attemptId != 0)
                          OutlinedButton.icon(
                            onPressed: () => onReview(attemptId!),
                            icon: const Icon(Icons.rate_review_rounded),
                            label: const Text("Ver examen"),
                          ),
                        FilledButton.icon(
                          onPressed: onFinish,
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text("Volver"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 260.ms)
        .scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1));
  }
}

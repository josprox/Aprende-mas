import 'package:aprende_mas/viewmodels/quiz_viewmodel.dart';
import 'package:aprende_mas/views/test_review_screen.dart';
import 'package:flutter/material.dart';
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

    // Calculate progress
    double progress = 0.0;
    if (state.questions.isNotEmpty && !state.isQuizFinished) {
      progress = (state.currentQuestionIndex + 1) / state.questions.length;
    } else if (state.isQuizFinished) {
      progress = 1.0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Test de Conocimientos",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Generando preguntas con IA..."),
                ],
              ),
            );
          } else if (state.questions.isEmpty) {
            return const Center(
              child: Text(
                "No se pudieron generar las preguntas. Inténtalo de nuevo.",
              ),
            );
          } else if (state.isQuizFinished) {
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
          } else {
            final currentQuestion = state.questions[state.currentQuestionIndex];
            final isAnsweredOrSkipped = state.answeredQuestions.contains(
              state.currentQuestionIndex,
            );

            return Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  color: Theme.of(context).colorScheme.tertiary,
                  minHeight: 8,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pregunta ${state.currentQuestionIndex + 1}/${state.questions.length}",
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentQuestion.questionText,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 24),
                        _AnswerOption(
                          text: currentQuestion.optionA,
                          optionKey: "A",
                          isSelected: state.selectedAnswer == "A",
                          isAnswerSubmitted: state.isAnswerSubmitted,
                          correctAnswerKey: state.correctOptionKey,
                          onSelected: () => notifier.onAnswerSelected("A"),
                        ),
                        const SizedBox(height: 12),
                        _AnswerOption(
                          text: currentQuestion.optionB,
                          optionKey: "B",
                          isSelected: state.selectedAnswer == "B",
                          isAnswerSubmitted: state.isAnswerSubmitted,
                          correctAnswerKey: state.correctOptionKey,
                          onSelected: () => notifier.onAnswerSelected("B"),
                        ),
                        const SizedBox(height: 12),
                        _AnswerOption(
                          text: currentQuestion.optionC,
                          optionKey: "C",
                          isSelected: state.selectedAnswer == "C",
                          isAnswerSubmitted: state.isAnswerSubmitted,
                          correctAnswerKey: state.correctOptionKey,
                          onSelected: () => notifier.onAnswerSelected("C"),
                        ),
                        const SizedBox(height: 12),
                        _AnswerOption(
                          text: currentQuestion.optionD,
                          optionKey: "D",
                          isSelected: state.selectedAnswer == "D",
                          isAnswerSubmitted: state.isAnswerSubmitted,
                          correctAnswerKey: state.correctOptionKey,
                          onSelected: () => notifier.onAnswerSelected("D"),
                        ),
                        if (state.isAnswerSubmitted &&
                            state.feedbackMessage != null) ...[
                          const SizedBox(height: 24),
                          Card(
                            color:
                                state.selectedAnswer == state.correctOptionKey
                                ? Theme.of(
                                    context,
                                  ).colorScheme.tertiaryContainer
                                : Theme.of(context).colorScheme.errorContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                state.feedbackMessage!,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color:
                                          state.selectedAnswer ==
                                              state.correctOptionKey
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.onTertiaryContainer
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onErrorContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!state.isAnswerSubmitted && !isAnsweredOrSkipped)
                        OutlinedButton(
                          onPressed: notifier.onSkipClicked,
                          child: const Text("Saltar Pregunta"),
                        )
                      else
                        const Spacer(),

                      FilledButton(
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
                        style: FilledButton.styleFrom(
                          backgroundColor: state.isAnswerSubmitted
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.tertiary,
                        ),
                        child: Text(
                          state.isAnswerSubmitted
                              ? (state.currentQuestionIndex <
                                        state.questions.length - 1
                                    ? "Siguiente Pregunta"
                                    : "Finalizar Test")
                              : "Guardar y Continuar",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
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
    final isCorrect = isAnswerSubmitted && optionKey == correctAnswerKey;
    final isIncorrect =
        isAnswerSubmitted && isSelected && optionKey != correctAnswerKey;

    Color? containerColor;
    Color? contentColor;
    Color? borderColor;

    if (isCorrect) {
      containerColor = Theme.of(context).colorScheme.tertiaryContainer;
      contentColor = Theme.of(context).colorScheme.onTertiaryContainer;
    } else if (isIncorrect) {
      containerColor = Theme.of(context).colorScheme.errorContainer;
      contentColor = Theme.of(context).colorScheme.onErrorContainer;
    } else if (isSelected) {
      containerColor = Theme.of(context).colorScheme.primaryContainer;
      contentColor = Theme.of(context).colorScheme.onPrimaryContainer;
    } else {
      containerColor = Theme.of(context).colorScheme.surface;
      contentColor = Theme.of(context).colorScheme.onSurface;
      borderColor = Theme.of(context).colorScheme.outline;
    }

    return Card(
      color: containerColor,
      elevation: (isCorrect || isIncorrect) ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: borderColor != null
            ? BorderSide(color: borderColor)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: isAnswerSubmitted ? null : onSelected,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Radio<String>(
                value: optionKey,
                groupValue: isSelected ? optionKey : null,
                onChanged: isAnswerSubmitted ? null : (_) => onSelected(),
                activeColor: contentColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: contentColor,
                    fontWeight: (isCorrect || isSelected)
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    final color = isApproved
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "¡Test Finalizado!",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 24),
            Text("Puntuación:", style: Theme.of(context).textTheme.titleLarge),
            Text(
              "$score / $totalQuestions",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isApproved
                  ? "¡Excelente trabajo! Has demostrado dominio del tema."
                  : "Sigue estudiando. Revisa tus errores para mejorar.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (attemptId != null && attemptId != 0)
                  OutlinedButton(
                    onPressed: () => onReview(attemptId!),
                    child: const Text("Ver el examen"),
                  ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: onFinish,
                  child: const Text("Volver al Módulo"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

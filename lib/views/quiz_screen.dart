import 'package:aprende_mas/models/subject_models.dart';
import 'package:aprende_mas/viewmodels/quiz_viewmodel.dart';
import 'package:aprende_mas/views/test_review_screen.dart';
import 'package:aprende_mas/widgets/app_empty_state.dart';
import 'package:aprende_mas/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizScreen extends ConsumerWidget {
  final int moduleId;
  final int attemptId;
  final int? nodeId;
  final String? lessonTitle;
  final String? lessonContent;

  const QuizScreen({
    super.key,
    required this.moduleId,
    required this.attemptId,
    this.nodeId,
    this.lessonTitle,
    this.lessonContent,
  });

  KeyEventResult _handleKeyEvent(
    KeyEvent event,
    QuizUiState state,
    QuizViewModel notifier,
    bool isAnsweredOrSkipped,
  ) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.keyA || key == LogicalKeyboardKey.digit1) {
      if (!state.isAnswerSubmitted) {
        notifier.onAnswerSelected("A");
        return KeyEventResult.handled;
      }
    } else if (key == LogicalKeyboardKey.keyB ||
        key == LogicalKeyboardKey.digit2) {
      if (!state.isAnswerSubmitted) {
        notifier.onAnswerSelected("B");
        return KeyEventResult.handled;
      }
    } else if (key == LogicalKeyboardKey.keyC ||
        key == LogicalKeyboardKey.digit3) {
      if (!state.isAnswerSubmitted) {
        notifier.onAnswerSelected("C");
        return KeyEventResult.handled;
      }
    } else if (key == LogicalKeyboardKey.keyD ||
        key == LogicalKeyboardKey.digit4) {
      if (!state.isAnswerSubmitted) {
        notifier.onAnswerSelected("D");
        return KeyEventResult.handled;
      }
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (state.isAnswerSubmitted) {
        notifier.onNextClicked();
        return KeyEventResult.handled;
      } else if (state.selectedAnswer != null) {
        notifier.onSaveAndContinueClicked();
        return KeyEventResult.handled;
      }
    } else if (key == LogicalKeyboardKey.keyS) {
      if (!state.isAnswerSubmitted && !isAnsweredOrSkipped) {
        notifier.onSkipClicked();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = QuizParams(
      moduleId: moduleId,
      attemptId: attemptId,
      nodeId: nodeId,
      lessonTitle: lessonTitle,
      lessonContent: lessonContent,
    );
    final state = ref.watch(quizViewModelProvider(params));
    final notifier = ref.read(quizViewModelProvider(params).notifier);
    final isDesktop = ResponsiveLayout.isTabletOrDesktop(context);

    double progress = 0.0;
    if (state.questions.isNotEmpty && !state.isQuizFinished) {
      progress = (state.currentQuestionIndex + 1) / state.questions.length;
    } else if (state.isQuizFinished) {
      progress = 1.0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lessonTitle?.isNotEmpty == true
              ? "Test: $lessonTitle"
              : "Test de conocimientos",
        ),
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const _GeneratingQuestions();
          }
          if (state.questions.isEmpty) {
            return AppEmptyState(
              icon: Icons.psychology_alt_rounded,
              title: "No se generaron preguntas",
              message:
                  "Hubo un inconveniente al generar las preguntas con la IA. Puedes reintentar ahora.",
              action: FilledButton.icon(
                onPressed: notifier.retry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Reintentar"),
              ),
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

          return Focus(
            autofocus: true,
            onKeyEvent: (node, event) => _handleKeyEvent(
              event,
              state,
              notifier,
              isAnsweredOrSkipped,
            ),
            child: isDesktop
                ? _buildDesktopLayout(
                    context,
                    state,
                    notifier,
                    currentQuestion,
                    progress,
                    isAnsweredOrSkipped,
                  )
                : _buildMobileLayout(
                    context,
                    state,
                    notifier,
                    currentQuestion,
                    progress,
                    isAnsweredOrSkipped,
                  ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    QuizUiState state,
    QuizViewModel notifier,
    Question currentQuestion,
    double progress,
    bool isAnsweredOrSkipped,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DesktopQuizSidebar(state: state, progress: progress),
        const VerticalDivider(width: 1, thickness: 1),
        _DesktopQuizArena(
          state: state,
          notifier: notifier,
          currentQuestion: currentQuestion,
          isAnsweredOrSkipped: isAnsweredOrSkipped,
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    QuizUiState state,
    QuizViewModel notifier,
    Question currentQuestion,
    double progress,
    bool isAnsweredOrSkipped,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Column(
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
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentQuestion.questionText,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900, height: 1.12),
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
                  border: Border(top: BorderSide(color: scheme.outlineVariant)),
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
        ),
      ),
    );
  }
}

class _DesktopQuizSidebar extends StatelessWidget {
  final QuizUiState state;
  final double progress;

  const _DesktopQuizSidebar({required this.state, required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 320,
      color: scheme.surfaceContainerLow,
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  color: scheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Panel del Test",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      "${state.questions.length} preguntas en total",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress section
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              color: scheme.primary,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${(progress * 100).toInt()}% completado",
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
              Text(
                "Aciertos: ${state.score}",
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          // Question Tracker Grid
          Text(
            "Mapa de preguntas",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(state.questions.length, (index) {
                  final isCurrent = index == state.currentQuestionIndex;
                  final isAnswered = state.answeredQuestions.contains(index);

                  final Color bgColor = isCurrent
                      ? scheme.primary
                      : (isAnswered
                          ? scheme.secondaryContainer
                          : scheme.surfaceContainerHighest);
                  final Color textColor = isCurrent
                      ? scheme.onPrimary
                      : (isAnswered
                          ? scheme.onSecondaryContainer
                          : scheme.onSurfaceVariant);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: isCurrent
                          ? Border.all(color: scheme.primary, width: 2)
                          : null,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${index + 1}",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: isCurrent
                                ? FontWeight.w900
                                : FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (isAnswered && !isCurrent) ...[
                          const SizedBox(width: 2),
                          Icon(
                            Icons.check_rounded,
                            size: 13,
                            color: textColor,
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          // Keyboard Shortcuts card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.keyboard_rounded,
                      size: 17,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Atajos de teclado",
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "• 1-4 o A-D: Seleccionar opción\n• Enter: Responder / Siguiente\n• S: Saltar pregunta",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopQuizArena extends StatelessWidget {
  final QuizUiState state;
  final QuizViewModel notifier;
  final Question currentQuestion;
  final bool isAnsweredOrSkipped;

  const _DesktopQuizArena({
    required this.state,
    required this.notifier,
    required this.currentQuestion,
    required this.isAnsweredOrSkipped,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
            child: Card(
              elevation: 2,
              color: scheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge & hint
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.help_outline_rounded,
                                size: 16,
                                color: scheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Pregunta ${state.currentQuestionIndex + 1} de ${state.questions.length}",
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: scheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (state.selectedAnswer != null &&
                            !state.isAnswerSubmitted)
                          Text(
                            "Presiona Enter para responder",
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Question Text
                    Text(
                      currentQuestion.questionText,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900, height: 1.28),
                    ),
                    const SizedBox(height: 26),
                    // Options
                    ...[
                      ("A", currentQuestion.optionA),
                      ("B", currentQuestion.optionB),
                      ("C", currentQuestion.optionC),
                      ("D", currentQuestion.optionD),
                    ].map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _AnswerOption(
                          text: option.$2,
                          optionKey: option.$1,
                          isSelected: state.selectedAnswer == option.$1,
                          isAnswerSubmitted: state.isAnswerSubmitted,
                          correctAnswerKey: state.correctOptionKey,
                          onSelected: () =>
                              notifier.onAnswerSelected(option.$1),
                          showShortcutBadge: true,
                        ),
                      ),
                    ),
                    // Feedback Card
                    if (state.isAnswerSubmitted &&
                        state.feedbackMessage != null) ...[
                      const SizedBox(height: 6),
                      _FeedbackCard(
                        message: state.feedbackMessage!,
                        isCorrect:
                            state.selectedAnswer == state.correctOptionKey,
                      ),
                    ],
                    const SizedBox(height: 26),
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    // Integrated Desktop Actions row
                    Row(
                      children: [
                        if (!state.isAnswerSubmitted && !isAnsweredOrSkipped)
                          OutlinedButton.icon(
                            onPressed: notifier.onSkipClicked,
                            icon: const Icon(Icons.skip_next_rounded),
                            label: const Text("Saltar (S)"),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 16,
                              ),
                            ),
                          )
                        else
                          const Spacer(),
                        const SizedBox(width: 14),
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
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                            ),
                            icon: Icon(
                              state.isAnswerSubmitted
                                  ? Icons.arrow_forward_rounded
                                  : Icons.check_rounded,
                            ),
                            label: Text(
                              state.isAnswerSubmitted
                                  ? (state.currentQuestionIndex <
                                            state.questions.length - 1
                                        ? "Siguiente (Enter)"
                                        : "Finalizar Test (Enter)")
                                  : "Responder (Enter)",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GeneratingQuestions extends StatelessWidget {
  const _GeneratingQuestions();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
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
  final bool showShortcutBadge;

  const _AnswerOption({
    required this.text,
    required this.optionKey,
    required this.isSelected,
    required this.isAnswerSubmitted,
    required this.correctAnswerKey,
    required this.onSelected,
    this.showShortcutBadge = false,
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
        : scheme.surfaceContainerHigh;
    final foreground = isCorrect
        ? scheme.onTertiaryContainer
        : isIncorrect
        ? scheme.onErrorContainer
        : isSelected
        ? scheme.onPrimaryContainer
        : scheme.onSurface;
    final border = isSelected || isCorrect || isIncorrect
        ? foreground.withValues(alpha: 0.4)
        : scheme.outlineVariant.withValues(alpha: 0.6);

    return MouseRegion(
      cursor: isAnswerSubmitted
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: Card(
        color: background,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isAnswerSubmitted ? null : onSelected,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
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
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: foreground,
                      fontWeight: isSelected || isCorrect
                          ? FontWeight.w800
                          : FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
                if (isCorrect)
                  Icon(Icons.check_circle_rounded, color: foreground)
                else if (isIncorrect)
                  Icon(Icons.cancel_rounded, color: foreground)
                else if (showShortcutBadge && !isAnswerSubmitted) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: foreground.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: foreground.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      optionKey,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: foreground.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate(target: isSelected ? 1 : 0).scaleXY(
      begin: 1,
      end: 1.012,
      duration: 150.ms,
    );
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
      margin: const EdgeInsets.only(top: 8),
      color: background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isCorrect
                  ? Icons.lightbulb_rounded
                  : Icons.tips_and_updates_rounded,
              color: foreground,
            ),
            const SizedBox(width: 14),
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Card(
            elevation: 2,
            color: isApproved
                ? scheme.tertiaryContainer
                : scheme.errorContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isApproved
                        ? Icons.emoji_events_rounded
                        : Icons.auto_stories_rounded,
                    size: 64,
                    color: accent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Test finalizado",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isApproved
                        ? "Excelente trabajo. Dominas muy bien este tema."
                        : "Buen avance. Revisa tus respuestas y vuelve a intentarlo.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$score / $totalQuestions",
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(color: accent, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      if (attemptId != null && attemptId != 0)
                        OutlinedButton.icon(
                          onPressed: () => onReview(attemptId!),
                          icon: const Icon(Icons.rate_review_rounded),
                          label: const Text("Ver examen"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                        ),
                      FilledButton.icon(
                        onPressed: onFinish,
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text("Volver"),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 260.ms).scale(
      begin: const Offset(0.96, 0.96),
      end: const Offset(1, 1),
    );
  }
}

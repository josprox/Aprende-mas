import 'package:aprende_mas/viewmodels/test_review_viewmodel.dart';
import 'package:aprende_mas/widgets/app_empty_state.dart';
import 'package:aprende_mas/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ReviewFilter { all, incorrect, correct }

class TestReviewScreen extends ConsumerStatefulWidget {
  final int attemptId;

  const TestReviewScreen({super.key, required this.attemptId});

  @override
  ConsumerState<TestReviewScreen> createState() => _TestReviewScreenState();
}

class _TestReviewScreenState extends ConsumerState<TestReviewScreen> {
  ReviewFilter _selectedFilter = ReviewFilter.all;
  final Map<int, GlobalKey> _questionKeys = {};

  GlobalKey _getKeyForIndex(int index) {
    return _questionKeys.putIfAbsent(index, () => GlobalKey());
  }

  void _scrollToQuestion(int index) {
    final key = _questionKeys[index];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        alignment: 0.1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(testReviewViewModelProvider(widget.attemptId));
    final isDesktop = ResponsiveLayout.isTabletOrDesktop(context);

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Revisión de examen")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.attempt == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Revisión de examen")),
        body: const AppEmptyState(
          icon: Icons.search_off_rounded,
          title: "Examen no encontrado",
          message: "No se pudo encontrar el intento solicitado.",
        ),
      );
    }

    final total = state.attempt!.totalQuestions;
    final correct = state.attempt!.correctAnswers;
    final score = state.attempt!.score;
    final incorrect = total - correct;
    final moduleTitle = state.module?.title ?? "Examen";

    // Filter questions
    final filteredQuestions = state.reviewedQuestions.asMap().entries.where((entry) {
      final isUserCorrect = entry.value.userAnswer.isCorrect == 1;
      if (_selectedFilter == ReviewFilter.incorrect) return !isUserCorrect;
      if (_selectedFilter == ReviewFilter.correct) return isUserCorrect;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Revisión: $moduleTitle",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: isDesktop
          ? _buildDesktopLayout(
              context,
              state,
              moduleTitle,
              score,
              correct,
              incorrect,
              total,
              filteredQuestions,
            )
          : _buildMobileLayout(
              context,
              state,
              moduleTitle,
              score,
              correct,
              incorrect,
              total,
              filteredQuestions,
            ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    TestReviewUiState state,
    String moduleTitle,
    double score,
    int correct,
    int incorrect,
    int total,
    List<MapEntry<int, ReviewedQuestion>> filteredQuestions,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─── Left Sidebar ───
        _DesktopReviewSidebar(
          moduleTitle: moduleTitle,
          score: score,
          correct: correct,
          incorrect: incorrect,
          total: total,
          selectedFilter: _selectedFilter,
          onFilterChanged: (filter) {
            setState(() {
              _selectedFilter = filter;
            });
          },
          reviewedQuestions: state.reviewedQuestions,
          onQuestionTapped: (originalIndex) {
            _scrollToQuestion(originalIndex);
          },
        ),
        const VerticalDivider(width: 1, thickness: 1),

        // ─── Main Review Arena ───
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: filteredQuestions.isEmpty
                  ? const Center(
                      child: AppEmptyState(
                        icon: Icons.check_circle_outline_rounded,
                        title: "Sin preguntas en este filtro",
                        message: "Selecciona 'Todas' para ver el examen completo.",
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(28, 24, 28, 60),
                      itemCount: filteredQuestions.length,
                      itemBuilder: (context, index) {
                        final entry = filteredQuestions[index];
                        final originalIndex = entry.key;
                        final reviewed = entry.value;

                        return Container(
                          key: _getKeyForIndex(originalIndex),
                          margin: const EdgeInsets.only(bottom: 20),
                          child: _ReviewQuestionCard(
                            index: originalIndex + 1,
                            reviewedQuestion: reviewed,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    TestReviewUiState state,
    String moduleTitle,
    double score,
    int correct,
    int incorrect,
    int total,
    List<MapEntry<int, ReviewedQuestion>> filteredQuestions,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      children: [
        _TestResultHeader(
          title: moduleTitle,
          score: score,
          correct: correct,
          total: total,
        ),
        const SizedBox(height: 16),

        // Filter chips
        _FilterChipsRow(
          selectedFilter: _selectedFilter,
          total: total,
          correct: correct,
          incorrect: incorrect,
          onFilterChanged: (filter) {
            setState(() {
              _selectedFilter = filter;
            });
          },
        ),
        const SizedBox(height: 16),

        // Questions list
        if (filteredQuestions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: AppEmptyState(
              icon: Icons.check_circle_outline_rounded,
              title: "Sin preguntas en este filtro",
              message: "Selecciona 'Todas' para ver el examen completo.",
            ),
          )
        else
          ...filteredQuestions.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: _ReviewQuestionCard(
                index: entry.key + 1,
                reviewedQuestion: entry.value,
              ),
            );
          }),
      ],
    );
  }
}

class _DesktopReviewSidebar extends StatelessWidget {
  final String moduleTitle;
  final double score;
  final int correct;
  final int incorrect;
  final int total;
  final ReviewFilter selectedFilter;
  final ValueChanged<ReviewFilter> onFilterChanged;
  final List<ReviewedQuestion> reviewedQuestions;
  final ValueChanged<int> onQuestionTapped;

  const _DesktopReviewSidebar({
    required this.moduleTitle,
    required this.score,
    required this.correct,
    required this.incorrect,
    required this.total,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.reviewedQuestions,
    required this.onQuestionTapped,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isApproved = score >= 8.0;
    final accent = isApproved ? scheme.tertiary : scheme.error;
    final progress = total == 0 ? 0.0 : correct / total;

    return Container(
      width: 320,
      color: scheme.surfaceContainerLow,
      padding: const EdgeInsets.fromLTRB(22, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isApproved
                  ? scheme.tertiaryContainer.withValues(alpha: 0.5)
                  : scheme.errorContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: accent.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isApproved ? "APROBADO" : "REPROBADO",
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Text(
                      score.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    color: accent,
                    backgroundColor: scheme.surface.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$correct de $total correctas",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                    ),
                    Text(
                      "${(progress * 100).toInt()}%",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: accent,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Filters section
          Text(
            "Filtrar preguntas",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<ReviewFilter>(
            segments: [
              ButtonSegment(
                value: ReviewFilter.all,
                label: Text("Todas ($total)", style: const TextStyle(fontSize: 11)),
              ),
              ButtonSegment(
                value: ReviewFilter.incorrect,
                label: Text("Errores ($incorrect)", style: const TextStyle(fontSize: 11)),
              ),
              ButtonSegment(
                value: ReviewFilter.correct,
                label: Text("Aciertos ($correct)", style: const TextStyle(fontSize: 11)),
              ),
            ],
            selected: {selectedFilter},
            onSelectionChanged: (set) => onFilterChanged(set.first),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Question Matrix Jump
          Text(
            "Ir a pregunta",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(reviewedQuestions.length, (index) {
                  final reviewed = reviewedQuestions[index];
                  final isCorrect = reviewed.userAnswer.isCorrect == 1;

                  final Color bgColor = isCorrect
                      ? scheme.tertiaryContainer.withValues(alpha: 0.7)
                      : scheme.errorContainer.withValues(alpha: 0.7);
                  final Color fgColor = isCorrect
                      ? scheme.onTertiaryContainer
                      : scheme.onErrorContainer;

                  return Tooltip(
                    message: "Pregunta ${index + 1}: ${isCorrect ? 'Correcta' : 'Incorrecta'}",
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onQuestionTapped(index),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: fgColor.withValues(alpha: 0.3)),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${index + 1}",
                              style: TextStyle(
                                color: fgColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              isCorrect ? Icons.check_rounded : Icons.close_rounded,
                              size: 13,
                              color: fgColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  final ReviewFilter selectedFilter;
  final int total;
  final int correct;
  final int incorrect;
  final ValueChanged<ReviewFilter> onFilterChanged;

  const _FilterChipsRow({
    required this.selectedFilter,
    required this.total,
    required this.correct,
    required this.incorrect,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            selected: selectedFilter == ReviewFilter.all,
            label: Text("Todas ($total)"),
            onSelected: (_) => onFilterChanged(ReviewFilter.all),
          ),
          const SizedBox(width: 8),
          FilterChip(
            selected: selectedFilter == ReviewFilter.incorrect,
            label: Text("Errores ($incorrect)"),
            avatar: const Icon(Icons.cancel_rounded, size: 16),
            onSelected: (_) => onFilterChanged(ReviewFilter.incorrect),
          ),
          const SizedBox(width: 8),
          FilterChip(
            selected: selectedFilter == ReviewFilter.correct,
            label: Text("Aciertos ($correct)"),
            avatar: const Icon(Icons.check_circle_rounded, size: 16),
            onSelected: (_) => onFilterChanged(ReviewFilter.correct),
          ),
        ],
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
      elevation: 1,
      color: isApproved ? scheme.tertiaryContainer : scheme.errorContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    score.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                color: accent,
                backgroundColor: scheme.surface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$correct de $total preguntas correctas",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  isApproved ? "¡Excelente!" : "Repasa los fallos",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
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
      elevation: 1,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: accent.withValues(alpha: 0.16),
                  foregroundColor: accent,
                  child: Text(
                    "$index",
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isUserCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              size: 14,
                              color: accent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isUserCorrect ? "Respuesta Correcta" : "Respuesta Incorrecta",
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        question.questionText,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.25,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Options
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

            // Explanation Card
            if (userAnswer.explanationText != null &&
                userAnswer.explanationText!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.lightbulb_rounded,
                        color: scheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Explicación",
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: scheme.primary,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userAnswer.explanationText!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurface,
                                  height: 1.4,
                                ),
                          ),
                        ],
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
    final isCorrectOption = optionKey == correctAnswer;
    final isUserSelected = optionKey == userSelection;
    final scheme = Theme.of(context).colorScheme;

    Color background;
    Color foreground;
    Color? borderColor;
    String? badgeLabel;
    IconData? badgeIcon;

    if (isCorrectOption && isUserSelected) {
      // User selected correctly!
      background = scheme.tertiaryContainer;
      foreground = scheme.onTertiaryContainer;
      borderColor = foreground.withValues(alpha: 0.4);
      badgeLabel = "Tu respuesta (Correcta)";
      badgeIcon = Icons.check_circle_rounded;
    } else if (isUserSelected && !isCorrectOption) {
      // User selected wrong option
      background = scheme.errorContainer;
      foreground = scheme.onErrorContainer;
      borderColor = foreground.withValues(alpha: 0.4);
      badgeLabel = "Tu respuesta";
      badgeIcon = Icons.cancel_rounded;
    } else if (isCorrectOption) {
      // Correct option user missed
      background = scheme.tertiaryContainer.withValues(alpha: 0.35);
      foreground = scheme.onTertiaryContainer;
      borderColor = scheme.tertiary.withValues(alpha: 0.5);
      badgeLabel = "Respuesta correcta";
      badgeIcon = Icons.check_circle_outline_rounded;
    } else {
      // Neutral option
      background = scheme.surfaceContainerHigh.withValues(alpha: 0.4);
      foreground = scheme.onSurfaceVariant;
      borderColor = null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
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
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: foreground,
                      fontWeight: (isCorrectOption || isUserSelected)
                          ? FontWeight.w800
                          : FontWeight.w500,
                      height: 1.3,
                    ),
              ),
            ),
            if (badgeLabel != null) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: foreground.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (badgeIcon != null) ...[
                      Icon(badgeIcon, size: 14, color: foreground),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      badgeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: foreground,
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

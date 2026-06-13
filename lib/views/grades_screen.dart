import 'package:aprende_mas/models/subject_models.dart';
import 'package:aprende_mas/viewmodels/calificacion_viewmodel.dart';
import 'package:aprende_mas/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GradesScreen extends ConsumerWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(calificacionViewModelProvider);

    return Scaffold(
      body: stateAsync.when(
        data: (state) => CustomScrollView(
          slivers: [
            const SliverAppBar.large(title: Text("Calificaciones")),
            if (state.completedTests.isEmpty)
              const SliverFillRemaining(
                child: AppEmptyState(
                  icon: Icons.insights_rounded,
                  title: "Tu progreso aparecerá aquí",
                  message:
                      "Completa tu primer examen para ver calificaciones, aciertos y desempeño.",
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList.builder(
                  itemCount: state.completedTests.length,
                  itemBuilder: (context, index) {
                    return _TestResultCard(test: state.completedTests[index])
                        .animate(delay: (35 * index).ms)
                        .fadeIn()
                        .slideY(begin: 0.04, end: 0);
                  },
                ),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }
}

class _TestResultCard extends StatelessWidget {
  final TestAttemptWithModule test;

  const _TestResultCard({required this.test});

  @override
  Widget build(BuildContext context) {
    final attempt = test.attempt;
    final isApproved = attempt.score >= 8.0;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = isApproved ? scheme.tertiary : scheme.error;
    final progress = attempt.totalQuestions == 0
        ? 0.0
        : attempt.correctAnswers / attempt.totalQuestions;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: isApproved ? scheme.tertiaryContainer : scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    isApproved
                        ? Icons.emoji_events_rounded
                        : Icons.school_rounded,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    test.moduleTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
                  ),
                ),
                Text(
                  attempt.score.toStringAsFixed(1),
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w900,
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
                backgroundColor: scheme.surface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "${attempt.correctAnswers} de ${attempt.totalQuestions} respuestas correctas",
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:aprende_mas/models/subject_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TestItemCard extends StatelessWidget {
  final TestAttemptWithModule test;
  final bool isPending;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;

  const TestItemCard({
    super.key,
    required this.test,
    required this.isPending,
    required this.onTap,
    this.onLongPress,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final score = test.attempt.score;
    final isApproved = score >= 8.0;
    final accent = isPending
        ? scheme.primary
        : isApproved
            ? scheme.tertiary
            : scheme.error;
    final containerColor = isPending
        ? scheme.primaryContainer
        : isApproved
            ? scheme.tertiaryContainer
            : scheme.errorContainer;
    final icon = isPending
        ? Icons.play_circle_rounded
        : isApproved
            ? Icons.verified_rounded
            : Icons.replay_rounded;

    final progressRatio = (test.attempt.totalQuestions > 0 && isPending)
        ? (test.attempt.currentQuestionIndex / test.attempt.totalQuestions)
            .clamp(0.0, 1.0)
        : 0.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 1,
        color: containerColor.withValues(alpha: 0.55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: accent.withValues(alpha: 0.25),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: accent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        test.moduleTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (isPending) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Pregunta ${test.attempt.currentQuestionIndex} de ${test.attempt.totalQuestions}",
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: progressRatio,
                                  minHeight: 5,
                                  color: accent,
                                  backgroundColor:
                                      scheme.surfaceContainerHighest,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Nota: ${score.toStringAsFixed(1)} / 10",
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isApproved ? "Aprobado" : "Repasar",
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: scheme.error,
                    ),
                    tooltip: "Eliminar intento",
                    onPressed: onDelete,
                  ),
                Icon(Icons.chevron_right_rounded, color: accent),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.03, end: 0);
  }
}

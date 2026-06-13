import 'package:aprende_mas/models/subject_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TestItemCard extends StatelessWidget {
  final TestAttemptWithModule test;
  final bool isPending;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const TestItemCard({
    super.key,
    required this.test,
    required this.isPending,
    required this.onTap,
    this.onLongPress,
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
    final statusText = isPending
        ? "Pregunta ${test.attempt.currentQuestionIndex} de ${test.attempt.totalQuestions}"
        : "Calificación ${score.toStringAsFixed(1)}";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: containerColor.withValues(alpha: 0.72),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.moduleTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      statusText,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.chevron_right_rounded, color: accent),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 220.ms).slideX(begin: 0.04, end: 0);
  }
}

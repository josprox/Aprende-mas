import 'package:aprende_mas/models/subject_models.dart';
import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    Color containerColor;
    Color iconColor;
    String statusText;

    if (isPending) {
      containerColor = colorScheme.primaryContainer;
      iconColor = colorScheme.primary;
      statusText =
          "En Progreso (${test.attempt.currentQuestionIndex}/${test.attempt.totalQuestions})";
    } else {
      final score = test.attempt.score;
      final isApproved = score >= 8.0;
      containerColor = isApproved
          ? colorScheme.tertiaryContainer
          : colorScheme.errorContainer.withOpacity(0.6);
      iconColor = isApproved ? colorScheme.tertiary : colorScheme.error;
      statusText = "Calificación: ${score.toStringAsFixed(1)}";
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      color: containerColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.moduleTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isPending ? Icons.replay : Icons.arrow_forward,
                color: iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:aprende_mas/services/database/app_database.dart';
import 'package:aprende_mas/viewmodels/calificacion_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GradesScreen extends ConsumerWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(calificacionViewModelProvider);

    return Scaffold(
      body: stateAsync.when(
        data: (state) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 16),
            Text(
              "Historial de Calificaciones",
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (state.completedTests.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "¡Anímate! Completa tu primer examen para ver tus resultados aquí.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ...state.completedTests.map(
                (test) => _TestResultCard(test: test),
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
    final colorScheme = Theme.of(context).colorScheme;

    final containerColor = isApproved
        ? colorScheme.tertiaryContainer
        : colorScheme.errorContainer.withOpacity(0.8);
    final scoreColor = isApproved
        ? colorScheme.onTertiaryContainer
        : colorScheme.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      color: containerColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              test.moduleTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Respuestas Correctas: ${attempt.correctAnswers} / ${attempt.totalQuestions}",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Calificación Final",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              attempt.score.toStringAsFixed(1),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: scoreColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

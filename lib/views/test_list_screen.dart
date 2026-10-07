import 'package:aprende_mas/models/subject_models.dart';
import 'package:aprende_mas/viewmodels/test_viewmodel.dart';
import 'package:aprende_mas/views/quiz_screen.dart';
import 'package:aprende_mas/views/test_review_screen.dart';
import 'package:aprende_mas/widgets/app_empty_state.dart';
import 'package:aprende_mas/widgets/app_section_header.dart';
import 'package:aprende_mas/widgets/responsive_layout.dart';
import 'package:aprende_mas/widgets/test_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TestListScreen extends ConsumerWidget {
  const TestListScreen({super.key});

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    TestAttemptWithModule test,
  ) {
    final scheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
          title: const Text("Eliminar intento"),
          content: Text(
            "¿Quieres eliminar este examen de \"${test.moduleTitle}\"?\n\nEsta acción no se puede deshacer.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref
                    .read(testViewModelProvider.notifier)
                    .deleteTestAttempt(test.attempt.id!);
              },
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(testViewModelProvider);
    final isDesktop = ResponsiveLayout.isTabletOrDesktop(context);

    return Scaffold(
      body: stateAsync.when(
        data: (state) {
          final isEmpty =
              state.pendingTests.isEmpty && state.completedTests.isEmpty;

          double avgScore = 0.0;
          int approvedCount = 0;
          if (state.completedTests.isNotEmpty) {
            final sum = state.completedTests.fold<double>(
              0.0,
              (acc, t) => acc + t.attempt.score,
            );
            avgScore = sum / state.completedTests.length;
            approvedCount = state.completedTests
                .where((t) => t.attempt.score >= 8.0)
                .length;
          }

          return CustomScrollView(
            slivers: [
              const SliverAppBar(
                title: Text("Evaluaciones y Tests"),
                floating: true,
                pinned: true,
              ),
              if (isEmpty)
                const SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.quiz_rounded,
                    title: "Aún no hay tests",
                    message:
                        "Inicia un test desde cualquier lección o módulo y aquí aparecerá tu historial.",
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 28 : 16,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ─── Desktop Summary Stats Hub ───
                            if (isDesktop && !isEmpty) ...[
                              _SummaryStatsHub(
                                pendingCount: state.pendingTests.length,
                                completedCount: state.completedTests.length,
                                avgScore: avgScore,
                                approvedCount: approvedCount,
                              ),
                              const SizedBox(height: 28),
                            ],

                            // ─── En progreso Section ───
                            AppSectionHeader(
                              icon: Icons.pending_actions_rounded,
                              title: "En progreso",
                              trailing: "${state.pendingTests.length}",
                            ),
                            const SizedBox(height: 14),
                            if (state.pendingTests.isEmpty)
                              const Card.filled(
                                margin: EdgeInsets.only(bottom: 24),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle_outline_rounded,
                                          color: Colors.green),
                                      SizedBox(width: 12),
                                      Text(
                                        "Todo al día. No tienes exámenes pendientes por terminar.",
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              _buildTestsGrid(
                                context,
                                ref,
                                tests: state.pendingTests,
                                isPending: true,
                              ),

                            const SizedBox(height: 28),

                            // ─── Completados Section ───
                            AppSectionHeader(
                              icon: Icons.task_alt_rounded,
                              title: "Completados",
                              trailing: "${state.completedTests.length}",
                            ),
                            const SizedBox(height: 14),
                            if (state.completedTests.isEmpty)
                              const Card.filled(
                                margin: EdgeInsets.only(bottom: 32),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(Icons.auto_stories_rounded),
                                      SizedBox(width: 12),
                                      Text(
                                        "Completa tu primer test para revisar tus calificaciones.",
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              _buildTestsGrid(
                                context,
                                ref,
                                tests: state.completedTests,
                                isPending: false,
                              ),

                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildTestsGrid(
    BuildContext context,
    WidgetRef ref, {
    required List<TestAttemptWithModule> tests,
    required bool isPending,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cols = width >= 1150
            ? 3
            : (width >= 680 ? 2 : 1);

        if (cols == 1) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tests.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final test = tests[index];
              return TestItemCard(
                test: test,
                isPending: isPending,
                onTap: () => _handleTestTap(context, test, isPending),
                onDelete: () => _showDeleteConfirmation(context, ref, test),
                onLongPress: () => _showDeleteConfirmation(context, ref, test),
              );
            },
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 114,
          ),
          itemCount: tests.length,
          itemBuilder: (context, index) {
            final test = tests[index];
            return TestItemCard(
              test: test,
              isPending: isPending,
              onTap: () => _handleTestTap(context, test, isPending),
              onDelete: () => _showDeleteConfirmation(context, ref, test),
              onLongPress: () => _showDeleteConfirmation(context, ref, test),
            );
          },
        );
      },
    );
  }

  void _handleTestTap(
    BuildContext context,
    TestAttemptWithModule test,
    bool isPending,
  ) {
    if (isPending) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            moduleId: test.attempt.moduleId,
            attemptId: test.attempt.id!,
            nodeId: test.attempt.nodeId,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TestReviewScreen(
            attemptId: test.attempt.id!,
          ),
        ),
      );
    }
  }
}

class _SummaryStatsHub extends StatelessWidget {
  final int pendingCount;
  final int completedCount;
  final double avgScore;
  final int approvedCount;

  const _SummaryStatsHub({
    required this.pendingCount,
    required this.completedCount,
    required this.avgScore,
    required this.approvedCount,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _StatMetricCard(
            icon: Icons.pending_actions_rounded,
            iconColor: scheme.primary,
            title: "En progreso",
            value: "$pendingCount",
            subtitle: pendingCount == 1 ? "1 test pendiente" : "$pendingCount tests pendientes",
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatMetricCard(
            icon: Icons.verified_rounded,
            iconColor: scheme.tertiary,
            title: "Completados",
            value: "$completedCount",
            subtitle: "$approvedCount aprobados",
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatMetricCard(
            icon: Icons.analytics_rounded,
            iconColor: scheme.secondary,
            title: "Promedio",
            value: completedCount > 0 ? avgScore.toStringAsFixed(1) : "-",
            subtitle: "Calificación sobre 10",
          ),
        ),
      ],
    );
  }
}

class _StatMetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _StatMetricCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

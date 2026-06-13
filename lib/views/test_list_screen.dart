import 'package:aprende_mas/models/subject_models.dart';
import 'package:aprende_mas/viewmodels/test_viewmodel.dart';
import 'package:aprende_mas/views/quiz_screen.dart';
import 'package:aprende_mas/views/test_review_screen.dart';
import 'package:aprende_mas/widgets/app_empty_state.dart';
import 'package:aprende_mas/widgets/app_section_header.dart';
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
                ref
                    .read(testViewModelProvider.notifier)
                    .deleteTestAttempt(test.attempt.id!);
                Navigator.of(context).pop();
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

    return Scaffold(
      body: stateAsync.when(
        data: (state) {
          final isEmpty =
              state.pendingTests.isEmpty && state.completedTests.isEmpty;

          return CustomScrollView(
            slivers: [
              const SliverAppBar.large(title: Text("Tests")),
              if (isEmpty)
                const SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.quiz_rounded,
                    title: "Aún no hay tests",
                    message:
                        "Inicia un test desde cualquier módulo y aquí aparecerá tu progreso.",
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  sliver: SliverToBoxAdapter(
                    child: AppSectionHeader(
                      icon: Icons.pending_actions_rounded,
                      title: "En progreso",
                      trailing: "${state.pendingTests.length}",
                    ),
                  ),
                ),
                if (state.pendingTests.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Text(
                        "Todo al día. No tienes exámenes pendientes.",
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.builder(
                      itemCount: state.pendingTests.length,
                      itemBuilder: (context, index) {
                        final test = state.pendingTests[index];
                        return TestItemCard(
                          test: test,
                          isPending: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizScreen(
                                  moduleId: test.attempt.moduleId,
                                  attemptId: test.attempt.id!,
                                ),
                              ),
                            );
                          },
                          onLongPress: () =>
                              _showDeleteConfirmation(context, ref, test),
                        );
                      },
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  sliver: SliverToBoxAdapter(
                    child: AppSectionHeader(
                      icon: Icons.task_alt_rounded,
                      title: "Completados",
                      trailing: "${state.completedTests.length}",
                    ),
                  ),
                ),
                if (state.completedTests.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Text(
                        "Completa un test para revisar tus respuestas.",
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    sliver: SliverList.builder(
                      itemCount: state.completedTests.length,
                      itemBuilder: (context, index) {
                        final test = state.completedTests[index];
                        return TestItemCard(
                          test: test,
                          isPending: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TestReviewScreen(
                                  attemptId: test.attempt.id!,
                                ),
                              ),
                            );
                          },
                          onLongPress: () =>
                              _showDeleteConfirmation(context, ref, test),
                        );
                      },
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
}

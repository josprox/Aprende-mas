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
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSectionHeader(
                              icon: Icons.pending_actions_rounded,
                              title: "En progreso",
                              trailing: "${state.pendingTests.length}",
                            ),
                            const SizedBox(height: 12),
                            if (state.pendingTests.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 24, left: 4),
                                child: Text(
                                  "Todo al día. No tienes exámenes pendientes.",
                                ),
                              )
                            else
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final width = constraints.maxWidth;
                                  final cols = width >= 1100
                                      ? 3
                                      : (width >= 640 ? 2 : 1);

                                  if (cols == 1) {
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: state.pendingTests.length,
                                      itemBuilder: (context, index) {
                                        final test = state.pendingTests[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: TestItemCard(
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
                                          ),
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
                                      mainAxisExtent: 96,
                                    ),
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
                                  );
                                },
                              ),
                            const SizedBox(height: 24),
                            AppSectionHeader(
                              icon: Icons.task_alt_rounded,
                              title: "Completados",
                              trailing: "${state.completedTests.length}",
                            ),
                            const SizedBox(height: 12),
                            if (state.completedTests.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 32, left: 4),
                                child: Text(
                                  "Completa un test para revisar tus respuestas.",
                                ),
                              )
                            else
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final width = constraints.maxWidth;
                                  final cols = width >= 1100
                                      ? 3
                                      : (width >= 640 ? 2 : 1);

                                  if (cols == 1) {
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: state.completedTests.length,
                                      itemBuilder: (context, index) {
                                        final test = state.completedTests[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: TestItemCard(
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
                                          ),
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
                                      mainAxisExtent: 96,
                                    ),
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
                                  );
                                },
                              ),
                            const SizedBox(height: 48),
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
}

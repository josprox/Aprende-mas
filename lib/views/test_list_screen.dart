import 'package:aprende_mas/services/database/app_database.dart';
import 'package:aprende_mas/viewmodels/test_viewmodel.dart';
import 'package:aprende_mas/views/quiz_screen.dart';
import 'package:aprende_mas/views/test_review_screen.dart';
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              const Text("Eliminar Intento"),
            ],
          ),
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
                    .deleteTestAttempt(test.attempt.id);
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
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
        data: (state) => CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  Text(
                    "Tu Historial de Exámenes",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // ... (Headers code remains the same, assuming it's above/below efficiently)
                  // For simplicity in this edit, I will replace the headers + lists blocks
                  // actually, to be precise, I should target specific blocks or use multi-replace if headers are scattered.
                  // But here I'm replacing the body mainly to insert the dialog method (which should be outside build ideally or inside a mixin/class method)
                  // Wait, I can't put method inside build easily if I want it to be clean.
                  // I'll make TestListScreen a plain ConsumerWidget and put the helper method inside the class.

                  // Pending Tests Header
                  Row(
                    children: [
                      Icon(
                        Icons.assignment,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "En Progreso",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ]),
              ),
            ),

            // Pending Tests List
            if (state.pendingTests.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Text("🎉 ¡Perfecto! No tienes exámenes pendientes."),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
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
                              attemptId: test.attempt.id,
                            ),
                          ),
                        );
                      },
                      onLongPress: () =>
                          _showDeleteConfirmation(context, ref, test),
                    );
                  }, childCount: state.pendingTests.length),
                ),
              ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  // Completed Tests Header
                  Row(
                    children: [
                      Icon(
                        Icons.done_all,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Completados para Revisión",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ]),
              ),
            ),

            // Completed Tests List
            if (state.completedTests.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Text("Empieza un test para ver tu primer resultado."),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final test = state.completedTests[index];
                    return TestItemCard(
                      test: test,
                      isPending: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TestReviewScreen(attemptId: test.attempt.id),
                          ),
                        );
                      },
                      onLongPress: () =>
                          _showDeleteConfirmation(context, ref, test),
                    );
                  }, childCount: state.completedTests.length),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }
}

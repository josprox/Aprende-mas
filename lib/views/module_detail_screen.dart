import 'package:aprende_mas/models/subject_models.dart';
import 'package:aprende_mas/viewmodels/providers.dart';
import 'package:aprende_mas/views/chat_screen.dart';
import 'package:aprende_mas/views/quiz_screen.dart';
import 'package:aprende_mas/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModuleDetailScreen extends ConsumerWidget {
  final int moduleId;

  const ModuleDetailScreen({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(studyRepositoryProvider);
    final submodulesStream = repository.getSubmodulesForModule(moduleId);
    final moduleFuture = repository.getModuleById(moduleId);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: Wrap(
        spacing: 10,
        children: [
          FloatingActionButton.extended(
            heroTag: "chat_fab",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(moduleId: moduleId),
                ),
              );
            },
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text("IA"),
            backgroundColor: scheme.secondaryContainer,
            foregroundColor: scheme.onSecondaryContainer,
          ),
          FloatingActionButton.extended(
            heroTag: "quiz_fab",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      QuizScreen(moduleId: moduleId, attemptId: 0),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text("Test"),
          ),
        ],
      ),
      body: StreamBuilder<List<Submodule>>(
        stream: submodulesStream,
        builder: (context, snapshot) {
          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: FutureBuilder<Module?>(
                  future: moduleFuture,
                  builder: (context, snapshot) {
                    return Text(snapshot.data?.title ?? "Detalle del módulo");
                  },
                ),
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: "No se pudo abrir",
                    message: "Error: ${snapshot.error}",
                  ),
                )
              else if ((snapshot.data ?? []).isEmpty)
                const SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.article_outlined,
                    title: "Sin contenido",
                    message: "Este módulo no tiene subtemas disponibles.",
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 112),
                  sliver: SliverList.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final submodule = snapshot.data![index];
                      return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            color: scheme.surfaceContainerLow,
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: scheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.notes_rounded,
                                          color: scheme.onPrimaryContainer,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          submodule.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                color: scheme.onSurface,
                                                fontWeight: FontWeight.w900,
                                                height: 1.08,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  MarkdownBody(
                                    data: submodule.contentMd,
                                    selectable: true,
                                    styleSheet:
                                        MarkdownStyleSheet.fromTheme(
                                          Theme.of(context),
                                        ).copyWith(
                                          p: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(height: 1.45),
                                          h1: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                              ),
                                          h2: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                              ),
                                          blockquoteDecoration: BoxDecoration(
                                            color: scheme.secondaryContainer,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                          codeblockDecoration: BoxDecoration(
                                            color:
                                                scheme.surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .animate(delay: (45 * index).ms)
                          .fadeIn()
                          .slideY(
                            begin: 0.04,
                            end: 0,
                            curve: Curves.easeOutCubic,
                          );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

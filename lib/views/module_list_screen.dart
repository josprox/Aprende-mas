import 'package:aprende_mas/models/subject_models.dart';
import 'package:aprende_mas/viewmodels/providers.dart';
import 'package:aprende_mas/views/module_detail_screen.dart';
import 'package:aprende_mas/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModuleListScreen extends ConsumerWidget {
  final int subjectId;

  const ModuleListScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(studyRepositoryProvider);
    final modulesStream = repository.getModulesForSubject(subjectId);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: StreamBuilder<List<Module>>(
        stream: modulesStream,
        builder: (context, snapshot) {
          final modules = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              const SliverAppBar.large(title: Text("Módulos")),
              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: "No se pudieron cargar",
                    message: "Error: ${snapshot.error}",
                  ),
                )
              else if (modules.isEmpty)
                const SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.menu_book_rounded,
                    title: "Sin módulos todavía",
                    message:
                        "Esta materia no tiene módulos disponibles en este momento.",
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList.builder(
                    itemCount: modules.length,
                    itemBuilder: (context, index) {
                      final module = modules[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child:
                            Card(
                                  color: scheme.surfaceContainerLow,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ModuleDetailScreen(
                                                moduleId: module.id!,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 52,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: scheme.secondaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Icon(
                                              Icons.article_rounded,
                                              color:
                                                  scheme.onSecondaryContainer,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  module.title,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme
                                                      .titleLarge
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        height: 1.08,
                                                      ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  module.shortDescription,
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: scheme
                                                            .onSurfaceVariant,
                                                        height: 1.35,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            color: scheme.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .animate(delay: (35 * index).ms)
                                .fadeIn()
                                .slideY(
                                  begin: 0.04,
                                  end: 0,
                                  curve: Curves.easeOutCubic,
                                ),
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

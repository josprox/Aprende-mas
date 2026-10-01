import 'package:aprende_mas/models/subject_models.dart';
import 'package:aprende_mas/viewmodels/subject_viewmodel.dart';
import 'package:aprende_mas/views/content_tree_screen.dart';
import 'package:aprende_mas/views/repository_store_screen.dart';
import 'package:aprende_mas/widgets/app_empty_state.dart';
import 'package:aprende_mas/widgets/subject_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubjectListScreen extends ConsumerWidget {
  const SubjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subjectNotifierProvider);
    final notifier = ref.read(subjectNotifierProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    ref.listen(subjectNotifierProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: scheme.error,
          ),
        );
        notifier.clearMessages();
      }
      if (next.successMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.successMessage!)));
        notifier.clearMessages();
      }
    });

    void showDeleteConfirmationDialog(Subject subject) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: Icon(Icons.warning_amber_rounded, color: scheme.error),
            title: const Text("Eliminar materia"),
            content: Text(
              "¿Seguro que deseas eliminar permanentemente \"${subject.name}\"?\n\nSe perderá el historial de exámenes asociado.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancelar"),
              ),
              FilledButton(
                onPressed: () {
                  notifier.onConfirmDelete();
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

    void showOptionsSheet(Subject subject) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    subject.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.upload_file_rounded),
                    title: const Text("Actualizar contenido JSON"),
                    subtitle: const Text("Reemplaza o mejora esta materia"),
                    onTap: () {
                      Navigator.pop(context);
                      notifier.prepareForFileAction(FileAction.update);
                      notifier.pickAndProcessFile();
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.delete_outline_rounded,
                      color: scheme.error,
                    ),
                    title: Text(
                      "Eliminar materia",
                      style: TextStyle(color: scheme.error),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showDeleteConfirmationDialog(subject);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text("Biblioteca"),
            actions: [
              IconButton.filledTonal(
                icon: const Icon(Icons.storefront_rounded),
                tooltip: 'Tienda de materias',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RepositoryStoreScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
            ],
          ),
          if (state.subjects.isEmpty)
            SliverFillRemaining(
              child: AppEmptyState(
                icon: Icons.auto_stories_rounded,
                title: "Tu biblioteca está lista",
                message:
                    "Importa una materia o explora la tienda para comenzar con módulos, tests y calificaciones.",
                action: FilledButton.icon(
                  onPressed: () {
                    notifier.prepareForFileAction(FileAction.import);
                    notifier.pickAndProcessFile();
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text("Importar materia"),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 104),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final crossAxisCount = width >= 1100
                            ? 3
                            : (width >= 640 ? 2 : 1);

                        if (crossAxisCount == 1) {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.subjects.length,
                            itemBuilder: (context, index) {
                              final subject = state.subjects[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: SubjectCard(
                                  subject: subject,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ContentTreeScreen(
                                          subjectId: subject.id!,
                                          title: subject.name,
                                        ),
                                      ),
                                    );
                                  },
                                  onOptionsTap: () {
                                    notifier.onSubjectLongPress(subject);
                                    showOptionsSheet(subject);
                                  },
                                ),
                              );
                            },
                          );
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent: 130,
                          ),
                          itemCount: state.subjects.length,
                          itemBuilder: (context, index) {
                            final subject = state.subjects[index];
                            return SubjectCard(
                              subject: subject,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ContentTreeScreen(
                                      subjectId: subject.id!,
                                      title: subject.name,
                                    ),
                                  ),
                                );
                              },
                              onOptionsTap: () {
                                notifier.onSubjectLongPress(subject);
                                showOptionsSheet(subject);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          notifier.prepareForFileAction(FileAction.import);
          notifier.pickAndProcessFile();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text("Importar"),
      ),
    );
  }
}

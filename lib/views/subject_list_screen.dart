import 'package:aprende_mas/models/subject_models.dart';

import 'package:aprende_mas/viewmodels/subject_viewmodel.dart';
import 'package:aprende_mas/views/module_list_screen.dart';
import 'package:aprende_mas/widgets/subject_card.dart';
import 'package:aprende_mas/views/repository_store_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubjectListScreen extends ConsumerWidget {
  const SubjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subjectNotifierProvider);
    final notifier = ref.read(subjectNotifierProvider.notifier);

    // Show snackbar for messages
    ref.listen(subjectNotifierProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
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
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                const Text("Eliminar Materia"),
              ],
            ),
            content: Text(
              "¿Estás seguro de que deseas eliminar permanentemente \"${subject.name}\"?\n\nEsta acción no se puede deshacer y perderás todo el historial de exámenes asociado.",
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

    void showOptionsSheet(Subject subject) {
      showModalBottomSheet(
        context: context,
        showDragHandle: true, // M3 specific
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    subject.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.file_upload_outlined),
                  title: const Text("Actualizar contenido (JSON)"),
                  onTap: () {
                    Navigator.pop(context); // Close sheet
                    notifier.prepareForFileAction(FileAction.update);
                    notifier.pickAndProcessFile();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    "Eliminar materia",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close sheet
                    showDeleteConfirmationDialog(subject);
                  },
                ),
                const SizedBox(height: 16),
              ],
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
              IconButton(
                icon: const Icon(Icons.storefront_outlined),
                tooltip: 'Tienda de Materias',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RepositoryStoreScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          state.subjects.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No hay materias",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text("Importa una para empezar a aprender."),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final subject = state.subjects[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: SubjectCard(
                          subject: subject,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ModuleListScreen(subjectId: subject.id!),
                              ),
                            );
                          },
                          onOptionsTap: () {
                            notifier.onSubjectLongPress(subject);
                            showOptionsSheet(subject);
                          },
                        ),
                      );
                    }, childCount: state.subjects.length),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          notifier.prepareForFileAction(FileAction.import);
          notifier.pickAndProcessFile();
        },
        icon: const Icon(Icons.add),
        label: const Text("Importar"),
      ),
    );
  }
}

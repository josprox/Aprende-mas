import 'package:aprende_mas/viewmodels/providers.dart';
import 'package:aprende_mas/views/chat_screen.dart';
import 'package:aprende_mas/views/quiz_screen.dart';
import 'package:flutter/material.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: moduleFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                snapshot.data?.title ?? "Detalle del Módulo",
                style: const TextStyle(fontWeight: FontWeight.bold),
              );
            }
            return const Text("Cargando...");
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
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
            icon: const Icon(Icons.question_answer),
            label: const Text("Preguntar IA"),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
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
            icon: const Icon(Icons.play_arrow),
            label: const Text("Iniciar Test"),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: submodulesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final submodules = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: submodules.length,
            itemBuilder: (context, index) {
              final submodule = submodules[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submodule.title,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    MarkdownBody(
                      data: submodule.contentMd,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet.fromTheme(
                        Theme.of(context),
                      ),
                    ),
                    const Divider(height: 32),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

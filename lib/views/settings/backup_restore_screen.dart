import 'package:aprende_mas/viewmodels/backup_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackupRestoreScreen extends ConsumerWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(backupViewModelProvider);
    final notifier = ref.read(backupViewModelProvider.notifier);

    // Listen for messages
    ref.listen(backupViewModelProvider, (prev, next) {
      if (next.message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message!)));
        notifier.clearMessage();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Copia de Seguridad y Restauración"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.isLoading) ...[
            const SizedBox(height: 32),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),
            Text(
              state.message ?? "Procesando...",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ] else if (state.isError) ...[
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "❌ Error",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message ?? "Ocurrió un error inesperado.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 32),
            _ActionCard(
              title: "Crear Copia de Seguridad",
              description:
                  "Guarda todos tus datos de la aplicación (materias, exámenes, progreso) en un archivo local.",
              buttonText: "Guardar Backup",
              icon: Icons.save,
              enabled: !state.isLoading,
              onTap: () => notifier.createBackup(),
            ),
            const Divider(height: 64),
            _ActionCard(
              title: "Restaurar Datos",
              description:
                  "Carga datos desde un archivo de copia de seguridad previo. ¡ATENCIÓN! Esto SOBRESCRIBIRÁ todos tus datos actuales.",
              buttonText: "Restaurar Backup",
              icon: Icons.restore,
              enabled: !state.isLoading,
              isDestructive: true,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    icon: Icon(
                      Icons.info,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: const Text("⚠️ Advertencia de Restauración"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Estás a punto de **SOBRESCRIBIR** todos tus datos actuales con los del archivo de backup.",
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Esta acción NO se puede deshacer.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text("¿Deseas continuar?"),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancelar"),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                          notifier.restoreBackup();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: const Text("Confirmar Restauración"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final IconData icon;
  final bool enabled;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.icon,
    required this.enabled,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final containerColor = isDestructive
        ? colorScheme.surfaceContainerHighest
        : colorScheme.surfaceContainerHigh;
    final iconColor = isDestructive ? colorScheme.error : colorScheme.primary;

    return Card(
      color: containerColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 32, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description, textAlign: TextAlign.justify),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: enabled ? onTap : null,
                style: isDestructive
                    ? FilledButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                      )
                    : null,
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

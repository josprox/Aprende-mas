import 'package:aprende_mas/viewmodels/backup_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackupRestoreScreen extends ConsumerWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(backupViewModelProvider);
    final notifier = ref.read(backupViewModelProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    ref.listen(backupViewModelProvider, (prev, next) {
      if (next.message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message!)));
        notifier.clearMessage();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Copia de seguridad")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.isLoading) ...[
            const SizedBox(height: 48),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),
            Text(
              state.message ?? "Procesando...",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ] else if (state.isError) ...[
            Card(
              color: scheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_rounded, color: scheme.onErrorContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message ?? "Ocurrió un error inesperado.",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: scheme.onErrorContainer,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            _ActionCard(
              title: "Crear respaldo",
              description:
                  "Guarda materias, exámenes y progreso en un archivo local.",
              buttonText: "Guardar backup",
              icon: Icons.save_alt_rounded,
              enabled: !state.isLoading,
              onTap: () => notifier.createBackup(),
            ),
            const SizedBox(height: 16),
            _ActionCard(
              title: "Restaurar datos",
              description:
                  "Carga un backup previo. Esta acción sobrescribe los datos actuales.",
              buttonText: "Restaurar backup",
              icon: Icons.restore_rounded,
              enabled: !state.isLoading,
              isDestructive: true,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    icon: Icon(
                      Icons.warning_amber_rounded,
                      color: scheme.error,
                    ),
                    title: const Text("Confirmar restauración"),
                    content: const Text(
                      "Estás a punto de sobrescribir todos tus datos actuales con el archivo de backup. Esta acción no se puede deshacer.",
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
                          backgroundColor: scheme.error,
                          foregroundColor: scheme.onError,
                        ),
                        child: const Text("Restaurar"),
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
    final scheme = Theme.of(context).colorScheme;
    final accent = isDestructive ? scheme.error : scheme.primary;

    return Card(
      color: isDestructive
          ? scheme.errorContainer.withValues(alpha: 0.42)
          : scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: enabled ? onTap : null,
                style: isDestructive
                    ? FilledButton.styleFrom(
                        backgroundColor: scheme.error,
                        foregroundColor: scheme.onError,
                      )
                    : null,
                icon: Icon(
                  isDestructive
                      ? Icons.restore_rounded
                      : Icons.download_rounded,
                ),
                label: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 240.ms).slideY(begin: 0.04, end: 0);
  }
}

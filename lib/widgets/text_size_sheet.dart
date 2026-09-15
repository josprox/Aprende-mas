import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aprende_mas/viewmodels/reading_preferences_viewmodel.dart';

class TextSizeSheet extends ConsumerWidget {
  const TextSizeSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const TextSizeSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(readingPreferencesProvider);
    final notifier = ref.read(readingPreferencesProvider.notifier);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final currentScale = prefs.textScale;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.format_size_rounded, color: scheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Tamaño del texto',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => notifier.resetTextScale(),
                  icon: const Icon(Icons.restart_alt_rounded, size: 18),
                  label: const Text('Restablecer'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Caja de vista previa interactiva
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vista previa de lectura',
                    style: TextStyle(
                      fontSize: 12 * currentScale,
                      fontWeight: FontWeight.w600,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'En la ingeniería de software, la calidad y el diseño estructurado garantizan sistemas mantenibles, eficientes y tolerantes a fallos.',
                    style: TextStyle(
                      fontSize: 14 * currentScale,
                      height: 1.45,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Controles de ajuste rápido A- / A+
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filledTonal(
                  onPressed: currentScale > 0.85
                      ? () => notifier.setTextScale(currentScale - 0.15)
                      : null,
                  icon: const Icon(Icons.text_decrease_rounded),
                  tooltip: 'Disminuir tamaño',
                ),
                Expanded(
                  child: Slider(
                    value: currentScale,
                    min: 0.85,
                    max: 1.45,
                    divisions: 4,
                    label: '${(currentScale * 100).round()}%',
                    onChanged: (value) => notifier.setTextScale(value),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: currentScale < 1.45
                      ? () => notifier.setTextScale(currentScale + 0.15)
                      : null,
                  icon: const Icon(Icons.text_increase_rounded),
                  tooltip: 'Aumentar tamaño',
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Etiquetas de presets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPresetChip(context, 'Pequeño', 0.85, currentScale, notifier),
                _buildPresetChip(context, 'Normal', 1.00, currentScale, notifier),
                _buildPresetChip(context, 'Grande', 1.15, currentScale, notifier),
                _buildPresetChip(context, 'Muy grande', 1.30, currentScale, notifier),
                _buildPresetChip(context, 'Máximo', 1.45, currentScale, notifier),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(
    BuildContext context,
    String label,
    double scale,
    double currentScale,
    ReadingPreferencesNotifier notifier,
  ) {
    final isSelected = (currentScale - scale).abs() < 0.05;
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => notifier.setTextScale(scale),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? scheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? scheme.primary : scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

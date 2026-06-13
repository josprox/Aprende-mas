import 'package:aprende_mas/models/subject_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;
  final VoidCallback onOptionsTap;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onTap,
    required this.onOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      color: scheme.surfaceContainerLow,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: Icons.person_outline_rounded,
                          label: subject.author,
                        ),
                        _InfoChip(
                          icon: Icons.new_releases_outlined,
                          label: "v${subject.version}",
                          tinted: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Opciones',
                onPressed: onOptionsTap,
                icon: const Icon(Icons.more_horiz_rounded),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.05, end: 0);
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool tinted;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.tinted = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tinted ? scheme.tertiaryContainer : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: tinted
                ? scheme.onTertiaryContainer
                : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: tinted
                    ? scheme.onTertiaryContainer
                    : scheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

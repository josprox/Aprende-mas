import 'package:flutter/material.dart';

class AppSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;

  const AppSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aprende_mas/viewmodels/auth_viewmodel.dart';
import 'package:aprende_mas/viewmodels/repository_store_viewmodel.dart';

class UserProfileDialog extends ConsumerWidget {
  const UserProfileDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (user == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            user.fullName,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '@${user.username}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Estado de la cuenta'),
            subtitle: const Text('Autenticado con Joss Red API'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Activa',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await ref.read(authViewModelProvider.notifier).logout();
                unawaited(
                  ref
                      .read(repositoryStoreViewModelProvider.notifier)
                      .fetchRepositories(),
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sesión cerrada'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              label: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.redAccent),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

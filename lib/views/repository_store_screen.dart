import 'dart:async';

import 'package:aprende_mas/models/repository_models.dart';
import 'package:aprende_mas/viewmodels/repository_store_viewmodel.dart';
import 'package:aprende_mas/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RepositoryStoreScreen extends ConsumerStatefulWidget {
  const RepositoryStoreScreen({super.key});

  @override
  ConsumerState<RepositoryStoreScreen> createState() =>
      _RepositoryStoreScreenState();
}

class _RepositoryStoreScreenState extends ConsumerState<RepositoryStoreScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(repositoryStoreViewModelProvider.notifier)
          .fetchRepositories(),
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(repositoryStoreViewModelProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(repositoryStoreViewModelProvider);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar.large(
            title: const Text('Tienda de materias'),
            actions: [
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(
                    child: SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                ),
            ],
          ),
          if (state.isError && state.items.isEmpty)
            SliverFillRemaining(
              child: AppEmptyState(
                icon: Icons.wifi_off_rounded,
                title: "No se pudo cargar la tienda",
                message: "Revisa tu conexión o intenta de nuevo.",
                action: FilledButton.icon(
                  onPressed: () => ref
                      .read(repositoryStoreViewModelProvider.notifier)
                      .fetchRepositories(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("Reintentar"),
                ),
              ),
            )
          else if (state.items.isEmpty && state.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.builder(
                itemCount: state.items.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.items.length) {
                    return state.isLoading && state.items.isNotEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox.shrink();
                  }
                  return _RepositoryCard(item: state.items[index])
                      .animate(delay: (35 * index).ms)
                      .fadeIn()
                      .slideY(begin: 0.04, end: 0);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _RepositoryCard extends ConsumerWidget {
  final RepositoryItem item;

  const _RepositoryCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final status =
        ref.watch(repositoryStoreViewModelProvider).itemStatuses[item.id] ??
        RepositoryStatus.notInstalled;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(
                    child: Text(
                      item.title.substring(0, 1).toUpperCase(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.author,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              item.description,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.commit_rounded,
                        size: 16,
                        color: scheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "v${item.version}",
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: scheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: status == RepositoryStatus.installed
                      ? null
                      : () async {
                          await _install(context, ref, status);
                        },
                  icon: Icon(_getButtonIcon(status)),
                  label: Text(_getButtonText(status)),
                  style: FilledButton.styleFrom(
                    backgroundColor: _getButtonColor(status, theme),
                    foregroundColor: _getButtonTextColor(status, theme),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _install(
    BuildContext context,
    WidgetRef ref,
    RepositoryStatus status,
  ) async {
    final scheme = Theme.of(context).colorScheme;
    try {
      unawaited(
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const Center(child: CircularProgressIndicator()),
        ),
      );
      await ref
          .read(repositoryStoreViewModelProvider.notifier)
          .installOrUpdateRepository(item.id);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == RepositoryStatus.updateAvailable
                  ? "Materia actualizada: ${item.title}"
                  : "Materia instalada: ${item.title}",
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: scheme.error),
        );
      }
    }
  }

  String _getButtonText(RepositoryStatus status) {
    return switch (status) {
      RepositoryStatus.installed => "Instalado",
      RepositoryStatus.updateAvailable => "Actualizar",
      RepositoryStatus.notInstalled => "Instalar",
    };
  }

  IconData _getButtonIcon(RepositoryStatus status) {
    return switch (status) {
      RepositoryStatus.installed => Icons.check_rounded,
      RepositoryStatus.updateAvailable => Icons.update_rounded,
      RepositoryStatus.notInstalled => Icons.download_rounded,
    };
  }

  Color _getButtonColor(RepositoryStatus status, ThemeData theme) {
    return switch (status) {
      RepositoryStatus.installed => theme.colorScheme.surfaceContainerHighest,
      RepositoryStatus.updateAvailable => theme.colorScheme.tertiary,
      RepositoryStatus.notInstalled => theme.colorScheme.primary,
    };
  }

  Color _getButtonTextColor(RepositoryStatus status, ThemeData theme) {
    return switch (status) {
      RepositoryStatus.installed => theme.colorScheme.onSurfaceVariant,
      RepositoryStatus.updateAvailable => theme.colorScheme.onTertiary,
      RepositoryStatus.notInstalled => theme.colorScheme.onPrimary,
    };
  }
}

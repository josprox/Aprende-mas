import 'package:aprende_mas/models/repository_models.dart';
import 'package:aprende_mas/viewmodels/repository_store_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart'; // Using global theme
import 'package:line_icons/line_icons.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar.medium(
            title: const Text('Tienda de Materias'),
            actions: [
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
          if (state.isError && state.items.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LineIcons.exclamationCircle,
                      size: 60,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Error al cargar repositorio",
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: () => ref
                          .read(repositoryStoreViewModelProvider.notifier)
                          .fetchRepositories(),
                      child: const Text("Reintentar"),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == state.items.length) {
                    if (state.isLoading && state.items.isNotEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }
                  final item = state.items[index];
                  return _RepositoryCard(item: item);
                }, childCount: state.items.length + 1),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      item.title.substring(0, 1).toUpperCase(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.author,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LineIcons.codeBranch,
                        size: 14,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "v${item.version}",
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () async {
                    final status =
                        ref
                            .read(repositoryStoreViewModelProvider)
                            .itemStatuses[item.id] ??
                        RepositoryStatus.notInstalled;

                    if (status == RepositoryStatus.installed)
                      return; // Already installed

                    try {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      await ref
                          .read(repositoryStoreViewModelProvider.notifier)
                          .installOrUpdateRepository(item.id);

                      if (context.mounted) {
                        Navigator.pop(context); // Close loading
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              status == RepositoryStatus.updateAvailable
                                  ? "Materia actualizada: ${item.title}"
                                  : "Materia instalada: ${item.title}",
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context); // Close loading
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: $e"),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _getButtonColor(ref, item.id, theme),
                    foregroundColor: _getButtonTextColor(ref, item.id, theme),
                  ),
                  child: Text(_getButtonText(ref, item.id)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getButtonText(WidgetRef ref, int itemId) {
    final status =
        ref.watch(repositoryStoreViewModelProvider).itemStatuses[itemId] ??
        RepositoryStatus.notInstalled;
    switch (status) {
      case RepositoryStatus.installed:
        return "Instalado";
      case RepositoryStatus.updateAvailable:
        return "Actualizar";
      case RepositoryStatus.notInstalled:
      default:
        return "Instalar";
    }
  }

  Color _getButtonColor(WidgetRef ref, int itemId, ThemeData theme) {
    final status =
        ref.watch(repositoryStoreViewModelProvider).itemStatuses[itemId] ??
        RepositoryStatus.notInstalled;
    switch (status) {
      case RepositoryStatus.installed:
        return theme.colorScheme.surfaceContainerHighest;
      case RepositoryStatus.updateAvailable:
        return theme.colorScheme.tertiary;
      case RepositoryStatus.notInstalled:
      default:
        return theme.colorScheme.primary;
    }
  }

  Color _getButtonTextColor(WidgetRef ref, int itemId, ThemeData theme) {
    final status =
        ref.watch(repositoryStoreViewModelProvider).itemStatuses[itemId] ??
        RepositoryStatus.notInstalled;
    switch (status) {
      case RepositoryStatus.installed:
        return theme.colorScheme.onSurfaceVariant;
      case RepositoryStatus.updateAvailable:
        return theme.colorScheme.onTertiary;
      case RepositoryStatus.notInstalled:
      default:
        return theme.colorScheme.onPrimary;
    }
  }
}

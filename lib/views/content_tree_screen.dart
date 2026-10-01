import 'package:aprende_mas/models/subject_models.dart';
import 'package:aprende_mas/viewmodels/providers.dart';
import 'package:aprende_mas/views/chat_screen.dart';
import 'package:aprende_mas/views/quiz_screen.dart';
import 'package:aprende_mas/views/code_runner_screen.dart';
import 'package:aprende_mas/widgets/app_markdown_viewer.dart';
import 'package:aprende_mas/widgets/text_size_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContentTreeScreen extends ConsumerStatefulWidget {
  final int subjectId;
  final ContentNode? node;
  final String title;

  const ContentTreeScreen({
    super.key,
    required this.subjectId,
    this.node,
    required this.title,
  });

  @override
  ConsumerState<ContentTreeScreen> createState() => _ContentTreeScreenState();
}

class _ContentTreeScreenState extends ConsumerState<ContentTreeScreen> {
  late Stream<List<ContentNode>> _childrenStream;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _sidebarScrollController = ScrollController();
  bool _isFabVisible = true;

  // Selected node for Master-Detail desktop view
  ContentNode? _selectedDetailNode;

  // State to toggle integrated side chat on Desktop/Tablet
  bool _isSideChatOpen = true;

  @override
  void initState() {
    super.initState();
    _childrenStream = _createChildrenStream();
    _selectedDetailNode = widget.node;
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _sidebarScrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final isScrollingDown = _scrollController.position.userScrollDirection ==
        ScrollDirection.reverse;
    if (isScrollingDown && _isFabVisible) {
      setState(() => _isFabVisible = false);
    } else if (!isScrollingDown && !_isFabVisible) {
      setState(() => _isFabVisible = true);
    }
  }

  @override
  void didUpdateWidget(covariant ContentTreeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subjectId != widget.subjectId ||
        oldWidget.node?.id != widget.node?.id) {
      _childrenStream = _createChildrenStream();
      _selectedDetailNode = widget.node;
    }
  }

  Stream<List<ContentNode>> _createChildrenStream() {
    final repository = ref.read(studyRepositoryProvider);
    return widget.node == null
        ? repository.getRootNodesForSubject(widget.subjectId)
        : repository.getChildrenForNode(widget.node!.id);
  }

  void _openChat(int moduleId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(moduleId: moduleId),
      ),
    );
  }

  void _openQuiz(int moduleId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(moduleId: moduleId, attemptId: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;

    return StreamBuilder<List<ContentNode>>(
      stream: _childrenStream,
      builder: (context, snapshot) {
        final children = snapshot.data ?? const <ContentNode>[];

        // 1. If we are on desktop/tablet and have topic blocks, show Master-Detail split
        if (isDesktop && children.isNotEmpty) {
          return _buildDesktopMasterDetail(context, scheme, children);
        }

        // 2. If we are viewing a leaf content node (reading lesson) on desktop/tablet,
        // show 65% content (materia) and 35% live AI Chat side-by-side!
        if (isDesktop && widget.node != null) {
          return _buildDesktopLessonWithSideChat(context, scheme);
        }

        // 3. Mobile adaptive single view
        return _buildAdaptiveSingleView(context, scheme, snapshot, children);
      },
    );
  }

  /// Master-Detail layout for desktop / wide screens
  Widget _buildDesktopMasterDetail(
    BuildContext context,
    ColorScheme scheme,
    List<ContentNode> children,
  ) {
    final activeNode = _selectedDetailNode ?? children.first;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.format_size_rounded),
            tooltip: 'Tamaño del texto',
            onPressed: () => TextSizeSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.terminal_rounded),
            tooltip: 'Consola de código',
            onPressed: () => CodeRunnerScreen.open(
              context,
              title: 'Consola interactiva',
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── MASTER: Lateral Module/Topic Navigation Tree ───
          SizedBox(
            width: 340,
            child: Material(
              color: scheme.surfaceContainerLow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        Icon(Icons.menu_book_rounded, color: scheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Temario',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: scheme.primary,
                              ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${children.length} temas',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      controller: _sidebarScrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: children.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final child = children[index];
                        final isSelected = child.id == activeNode.id;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              setState(() {
                                _selectedDetailNode = child;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? scheme.primaryContainer
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    size: 18,
                                    color: isSelected
                                        ? scheme.onPrimaryContainer
                                        : scheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      child.title,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.w900
                                                : FontWeight.w600,
                                            color: isSelected
                                                ? scheme.onPrimaryContainer
                                                : scheme.onSurface,
                                          ),
                                    ),
                                  ),
                                  if (child.moduleId != null)
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: isSelected
                                          ? scheme.onPrimaryContainer
                                          : scheme.onSurfaceVariant.withValues(alpha: 0.6),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),

          // ─── DETAIL: Content Reading Panel ───
          Expanded(
            child: _SubnodeOrContentDetail(
              subjectId: widget.subjectId,
              node: activeNode,
              onOpenChat: _openChat,
              onOpenQuiz: _openQuiz,
            ),
          ),
        ],
      ),
    );
  }

  /// Split view for reading lessons: ~65% lesson reading + ~35% live AI Chat side-by-side
  Widget _buildDesktopLessonWithSideChat(BuildContext context, ColorScheme scheme) {
    final node = widget.node!;
    final moduleId = node.moduleId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (moduleId != null)
            IconButton.filledTonal(
              tooltip: _isSideChatOpen ? 'Ocultar chat IA' : 'Mostrar chat IA',
              icon: Icon(
                _isSideChatOpen
                    ? Icons.chat_rounded
                    : Icons.chat_bubble_outline_rounded,
              ),
              onPressed: () {
                setState(() {
                  _isSideChatOpen = !_isSideChatOpen;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.format_size_rounded),
            tooltip: 'Tamaño del texto',
            onPressed: () => TextSizeSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.terminal_rounded),
            tooltip: 'Consola de código',
            onPressed: () => CodeRunnerScreen.open(
              context,
              title: 'Consola interactiva',
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── 65% - 70%: Materia / Lección ───
          Expanded(
            flex: _isSideChatOpen && moduleId != null ? 65 : 100,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(36, 20, 36, 60),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 960),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Action banner: Quick Test
                            if (moduleId != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.school_rounded, color: scheme.primary),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Pon a prueba tus conocimientos sobre esta lección',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    FilledButton.icon(
                                      onPressed: () => _openQuiz(moduleId),
                                      icon: const Icon(Icons.quiz_rounded, size: 18),
                                      label: const Text('Generar test'),
                                    ),
                                  ],
                                ),
                              ),

                            // Main lesson markdown container
                            Card.filled(
                              color: scheme.surfaceContainerHighest,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: AppMarkdownViewer(
                                  data: node.contentMd.isEmpty
                                      ? 'Esta sección aún no tiene contenido.'
                                      : node.contentMd,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── 30% - 35%: Asistente IA Integrado ───
          if (_isSideChatOpen && moduleId != null) ...[
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              flex: 35,
              child: Container(
                color: scheme.surface,
                child: Column(
                  children: [
                    // Chat header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLow,
                        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, color: scheme.primary, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Asistente IA',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            tooltip: 'Ocultar chat',
                            onPressed: () {
                              setState(() {
                                _isSideChatOpen = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    // Live embedded chat
                    Expanded(
                      child: EmbeddedChatView(moduleId: moduleId),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Single column adaptive view (for mobile)
  Widget _buildAdaptiveSingleView(
    BuildContext context,
    ColorScheme scheme,
    AsyncSnapshot<List<ContentNode>> snapshot,
    List<ContentNode> children,
  ) {
    final showLearningActions =
        snapshot.connectionState != ConnectionState.waiting &&
        children.isEmpty &&
        widget.node?.moduleId != null;

    return Scaffold(
      floatingActionButton: showLearningActions
          ? AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: _isFabVisible ? 1.0 : 0.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FloatingActionButton.extended(
                      heroTag: 'chat_${widget.node!.id}',
                      onPressed: () => _openChat(widget.node!.moduleId!),
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('Preguntar a IA'),
                      backgroundColor: scheme.secondaryContainer,
                      foregroundColor: scheme.onSecondaryContainer,
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton.extended(
                      heroTag: 'quiz_${widget.node!.id}',
                      onPressed: () => _openQuiz(widget.node!.moduleId!),
                      icon: const Icon(Icons.quiz_rounded),
                      label: const Text('Generar test'),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar.large(
            title: Text(widget.title),
            actions: [
              if (widget.node != null) ...[
                IconButton(
                  icon: const Icon(Icons.format_size_rounded),
                  tooltip: 'Tamaño del texto',
                  onPressed: () => TextSizeSheet.show(context),
                ),
                IconButton(
                  icon: const Icon(Icons.terminal_rounded),
                  tooltip: 'Consola de código',
                  onPressed: () => CodeRunnerScreen.open(
                    context,
                    title: 'Consola interactiva',
                  ),
                ),
              ],
            ],
          ),
          if (snapshot.connectionState == ConnectionState.waiting)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (children.isNotEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final crossAxisCount = width >= 720 ? 2 : 1;

                        if (crossAxisCount == 1) {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: children.length,
                            itemBuilder: (context, index) {
                              final child = children[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildChildItemCard(context, scheme, child, index),
                              );
                            },
                          );
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent: 88,
                          ),
                          itemCount: children.length,
                          itemBuilder: (context, index) {
                            return _buildChildItemCard(
                              context,
                              scheme,
                              children[index],
                              index,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            )
          else if (widget.node != null)
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 180),
                    child: Card.filled(
                      color: scheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: AppMarkdownViewer(
                          data: widget.node!.contentMd.isEmpty
                              ? 'Esta sección aún no tiene contenido.'
                              : widget.node!.contentMd,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            const SliverFillRemaining(
              child: Center(
                child: Text('Esta materia aún no tiene temas.'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChildItemCard(
    BuildContext context,
    ColorScheme scheme,
    ContentNode child,
    int index,
  ) {
    return Card.filled(
      color: index.isEven
          ? scheme.primaryContainer
          : scheme.secondaryContainer,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Icon(
          Icons.account_tree_rounded,
          color: index.isEven
              ? scheme.onPrimaryContainer
              : scheme.onSecondaryContainer,
        ),
        title: Text(
          child.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          child.contentMd.isEmpty
              ? 'Abrir sección'
              : 'Lección y subtemas',
        ),
        trailing: const Icon(Icons.arrow_forward_rounded),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ContentTreeScreen(
              subjectId: widget.subjectId,
              node: child,
              title: child.title,
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget for the right detail panel in Master-Detail desktop mode
class _SubnodeOrContentDetail extends ConsumerWidget {
  final int subjectId;
  final ContentNode node;
  final void Function(int moduleId) onOpenChat;
  final void Function(int moduleId) onOpenQuiz;

  const _SubnodeOrContentDetail({
    required this.subjectId,
    required this.node,
    required this.onOpenChat,
    required this.onOpenQuiz,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(studyRepositoryProvider);
    final scheme = Theme.of(context).colorScheme;

    return StreamBuilder<List<ContentNode>>(
      stream: repository.getChildrenForNode(node.id),
      builder: (context, snapshot) {
        final subchildren = snapshot.data ?? const <ContentNode>[];

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(40, 24, 40, 60),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Topic Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.auto_stories_rounded,
                                color: scheme.onPrimaryContainer,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                node.title,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        if (node.moduleId != null) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              FilledButton.icon(
                                onPressed: () => onOpenQuiz(node.moduleId!),
                                icon: const Icon(Icons.quiz_rounded),
                                label: const Text('Generar Test'),
                              ),
                              const SizedBox(width: 12),
                              FilledButton.tonalIcon(
                                onPressed: () => onOpenChat(node.moduleId!),
                                icon: const Icon(Icons.auto_awesome_rounded),
                                label: const Text('Preguntar a IA'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // If this node has subtopics, render subtopics cards
                  if (subchildren.isNotEmpty) ...[
                    Text(
                      'Subtemas de este bloque',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: scheme.primary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        mainAxisExtent: 80,
                      ),
                      itemCount: subchildren.length,
                      itemBuilder: (context, index) {
                        final sub = subchildren[index];
                        return Card.filled(
                          color: scheme.surfaceContainerHighest,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ContentTreeScreen(
                                    subjectId: subjectId,
                                    node: sub,
                                    title: sub.title,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(Icons.topic_rounded, color: scheme.primary, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      sub.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_rounded, size: 18),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Lesson Content
                  if (node.contentMd.isNotEmpty)
                    Card.filled(
                      color: scheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(26),
                        child: AppMarkdownViewer(
                          data: node.contentMd,
                        ),
                      ),
                    )
                  else if (subchildren.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          'Selecciona un subtema o módulo para ver su contenido.',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

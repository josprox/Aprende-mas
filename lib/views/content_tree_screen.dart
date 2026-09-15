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
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _childrenStream = _createChildrenStream();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
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
    }
  }

  Stream<List<ContentNode>> _createChildrenStream() {
    final repository = ref.read(studyRepositoryProvider);
    return widget.node == null
        ? repository.getRootNodesForSubject(widget.subjectId)
        : repository.getChildrenForNode(widget.node!.id);
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(moduleId: widget.node!.moduleId!),
      ),
    );
  }

  void _openQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            QuizScreen(moduleId: widget.node!.moduleId!, attemptId: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return StreamBuilder<List<ContentNode>>(
      stream: _childrenStream,
      builder: (context, snapshot) {
        final children = snapshot.data ?? const <ContentNode>[];
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
                          onPressed: _openChat,
                          icon: const Icon(Icons.auto_awesome_rounded),
                          label: const Text('Preguntar a IA'),
                          backgroundColor: scheme.secondaryContainer,
                          foregroundColor: scheme.onSecondaryContainer,
                        ),
                        const SizedBox(height: 12),
                        FloatingActionButton.extended(
                          heroTag: 'quiz_${widget.node!.id}',
                          onPressed: _openQuiz,
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
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList.builder(
                    itemCount: children.length,
                    itemBuilder: (context, index) {
                      final child = children[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card.filled(
                          color: index.isEven
                              ? scheme.primaryContainer
                              : scheme.secondaryContainer,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            leading: Icon(
                              Icons.account_tree_rounded,
                              color: index.isEven
                                  ? scheme.onPrimaryContainer
                                  : scheme.onSecondaryContainer,
                            ),
                            title: Text(
                              child.title,
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
                        ),
                      );
                    },
                  ),
                )
              else if (widget.node != null)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 180),
                  sliver: SliverToBoxAdapter(
                    child: Card.filled(
                      color: scheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: AppMarkdownViewer(
                          data: widget.node!.contentMd.isEmpty
                              ? 'Esta sección aún no tiene contenido.'
                              : widget.node!.contentMd,
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
      },
    );
  }
}

import 'package:aprende_mas/viewmodels/module_detail_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int moduleId;

  const ChatScreen({super.key, required this.moduleId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(moduleDetailViewModelProvider(widget.moduleId));
    final notifier = ref.read(
      moduleDetailViewModelProvider(widget.moduleId).notifier,
    );
    final chatState = state.chatUiState;
    final scheme = Theme.of(context).colorScheme;

    ref.listen(
      moduleDetailViewModelProvider(
        widget.moduleId,
      ).select((s) => s.chatUiState.chatHistory.length),
      (prev, next) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Asistente IA"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: IconButton.filledTonal(
              tooltip: "Asistente del módulo",
              onPressed: null,
              icon: Icon(Icons.auto_awesome_rounded),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(color: scheme.surface),
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  itemCount:
                      chatState.chatHistory.length +
                      (chatState.isModelThinking &&
                              (chatState.chatHistory.isEmpty ||
                                  !chatState.chatHistory.last.isPending)
                          ? 1
                          : 0),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    if (index < chatState.chatHistory.length) {
                      final message = chatState.chatHistory[index];
                      return _MessageBubble(message: message);
                    }
                    return const _ThinkingIndicator();
                  },
                ),
              ),
            ),
            _ChatInput(
              currentInput: chatState.currentInput,
              onInputChanged: notifier.onInputChanged,
              onSend: notifier.onSendMessage,
              isEnabled: !chatState.isModelThinking,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == "user";
    final scheme = Theme.of(context).colorScheme;
    final containerColor = isUser
        ? scheme.primary
        : scheme.surfaceContainerHigh;
    final contentColor = isUser ? scheme.onPrimary : scheme.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.86,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(24),
              topRight: const Radius.circular(24),
              bottomLeft: Radius.circular(isUser ? 24 : 6),
              bottomRight: Radius.circular(isUser ? 6 : 24),
            ),
            border: isUser
                ? null
                : Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.7),
                  ),
          ),
          child: message.isPending && message.content.isEmpty
              ? _AnimatedLoadingDots(color: contentColor)
              : isUser
              ? Text(
                  message.content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: contentColor,
                    height: 1.4,
                  ),
                )
              : MarkdownBody(
                  data: message.content,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                      .copyWith(
                        p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: contentColor,
                          height: 1.4,
                        ),
                        code: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          backgroundColor: scheme.surfaceContainerHighest,
                          color: scheme.onSurface,
                          fontFamily: 'monospace',
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                ),
        ),
      ),
    ).animate().fadeIn(duration: 180.ms).slideY(begin: 0.04, end: 0);
  }
}

class _ChatInput extends StatefulWidget {
  final String currentInput;
  final Function(String) onInputChanged;
  final VoidCallback onSend;
  final bool isEnabled;

  const _ChatInput({
    required this.currentInput,
    required this.onInputChanged,
    required this.onSend,
    required this.isEnabled,
  });

  @override
  State<_ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<_ChatInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentInput);
  }

  @override
  void didUpdateWidget(covariant _ChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentInput != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.currentInput,
        selection: TextSelection.collapsed(offset: widget.currentInput.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer.withValues(alpha: 0.96),
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onInputChanged,
              decoration: const InputDecoration(
                hintText: "Pregunta sobre este módulo...",
                prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
              ),
              minLines: 1,
              maxLines: 5,
              enabled: widget.isEnabled,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) {
                if (widget.isEnabled && widget.currentInput.trim().isNotEmpty) {
                  widget.onSend();
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton.small(
            heroTag: "send_chat",
            onPressed:
                (widget.isEnabled && widget.currentInput.trim().isNotEmpty)
                ? widget.onSend
                : null,
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            child: const Icon(Icons.arrow_upward_rounded),
          ),
        ],
      ),
    );
  }
}

class _ThinkingIndicator extends StatelessWidget {
  const _ThinkingIndicator();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
            bottomLeft: Radius.circular(6),
          ),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        child: _AnimatedLoadingDots(color: scheme.onSurfaceVariant),
      ),
    );
  }
}

class _AnimatedLoadingDots extends StatelessWidget {
  final Color color;

  const _AnimatedLoadingDots({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child:
              Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fade(begin: 0.25, end: 1, duration: 520.ms)
                  .then(delay: (90 * index).ms)
                  .fade(begin: 1, end: 0.25, duration: 520.ms),
        ),
      ),
    );
  }
}

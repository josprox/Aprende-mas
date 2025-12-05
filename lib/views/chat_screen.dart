import 'package:aprende_mas/viewmodels/module_detail_viewmodel.dart';
import 'package:flutter/material.dart';
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

    // Auto-scroll on new messages
    ref.listen(
      moduleDetailViewModelProvider(
        widget.moduleId,
      ).select((s) => s.chatUiState.chatHistory.length),
      (prev, next) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      },
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Asistente IA",
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount:
                    chatState.chatHistory.length +
                    (chatState.isModelThinking &&
                            (chatState.chatHistory.isEmpty ||
                                !chatState.chatHistory.last.isPending)
                        ? 1
                        : 0),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index < chatState.chatHistory.length) {
                    final message = chatState.chatHistory[index];
                    return _MessageBubble(message: message);
                  } else {
                    return const _ThinkingIndicator();
                  }
                },
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
    final colorScheme = Theme.of(context).colorScheme;

    final containerColor = isUser
        ? colorScheme.primary
        : colorScheme.secondaryContainer;
    final contentColor = isUser
        ? colorScheme.onPrimary
        : colorScheme.onSecondaryContainer;

    const borderRadius = BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    );

    // Expressive shapes: user bubble differs slightly from AI bubble if desired
    // Currently using full rounded corners for a modern chat look

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: borderRadius.copyWith(
              bottomRight: isUser ? const Radius.circular(4) : null,
              bottomLeft: !isUser ? const Radius.circular(4) : null,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.isPending && message.content.isEmpty)
                _AnimatedLoadingDots(color: contentColor)
              else if (isUser)
                Text(
                  message.content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: contentColor,
                    height: 1.4,
                  ),
                )
              else
                MarkdownBody(
                  data: message.content,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                      .copyWith(
                        p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: contentColor,
                          height: 1.4,
                        ),
                        code: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          backgroundColor: colorScheme.surface,
                          color: colorScheme.onSurface,
                          fontFamily: 'monospace',
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextField(
                controller: TextEditingController(text: currentInput)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: currentInput.length),
                  ),
                onChanged: onInputChanged,
                decoration: const InputDecoration(
                  hintText: "Escribe un mensaje...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  isDense: true,
                ),
                minLines: 1,
                maxLines: 5,
                enabled: isEnabled,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: (isEnabled && currentInput.trim().isNotEmpty)
                ? onSend
                : null,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 0,
            shape: const CircleBorder(),
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: _AnimatedLoadingDots(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

class _AnimatedLoadingDots extends StatefulWidget {
  final Color color;
  const _AnimatedLoadingDots({required this.color});

  @override
  State<_AnimatedLoadingDots> createState() => _AnimatedLoadingDotsState();
}

class _AnimatedLoadingDotsState extends State<_AnimatedLoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        const count = 3;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (index) {
            final offset = index / count;
            final t = (val - offset) % 1.0;
            final opacity = (1.0 - (t - 0.5).abs() * 2).clamp(0.2, 1.0);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

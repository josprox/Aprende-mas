import 'package:aprende_mas/models/api_models.dart';
import 'package:aprende_mas/viewmodels/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessage {
  final String role;
  final String content;
  final bool isPending;

  const ChatMessage({
    required this.role,
    required this.content,
    this.isPending = false,
  });

  ChatMessage copyWith({String? content, bool? isPending}) {
    return ChatMessage(
      role: role,
      content: content ?? this.content,
      isPending: isPending ?? this.isPending,
    );
  }
}

class ChatUiState {
  final List<ChatMessage> chatHistory;
  final bool isModelThinking;
  final String currentInput;

  const ChatUiState({
    this.chatHistory = const [],
    this.isModelThinking = false,
    this.currentInput = '',
  });

  ChatUiState copyWith({
    List<ChatMessage>? chatHistory,
    bool? isModelThinking,
    String? currentInput,
  }) {
    return ChatUiState(
      chatHistory: chatHistory ?? this.chatHistory,
      isModelThinking: isModelThinking ?? this.isModelThinking,
      currentInput: currentInput ?? this.currentInput,
    );
  }
}

class ModuleDetailUiState {
  final String moduleTitle;
  final ChatUiState chatUiState;

  const ModuleDetailUiState({
    this.moduleTitle = '',
    this.chatUiState = const ChatUiState(),
  });

  ModuleDetailUiState copyWith({
    String? moduleTitle,
    ChatUiState? chatUiState,
  }) {
    return ModuleDetailUiState(
      moduleTitle: moduleTitle ?? this.moduleTitle,
      chatUiState: chatUiState ?? this.chatUiState,
    );
  }
}

class ChatParams {
  final int moduleId;
  final int? nodeId;
  final String? lessonTitle;
  final String? lessonContent;

  const ChatParams({
    required this.moduleId,
    this.nodeId,
    this.lessonTitle,
    this.lessonContent,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatParams &&
          runtimeType == other.runtimeType &&
          moduleId == other.moduleId &&
          nodeId == other.nodeId;

  @override
  int get hashCode => moduleId.hashCode ^ (nodeId?.hashCode ?? 0);
}

class ModuleDetailViewModel extends StateNotifier<ModuleDetailUiState> {
  final Ref ref;
  final ChatParams params;

  ModuleDetailViewModel(this.ref, this.params)
    : super(const ModuleDetailUiState()) {
    _loadTitle();
  }

  Future<void> _loadTitle() async {
    final repository = ref.read(studyRepositoryProvider);
    if (params.nodeId != null) {
      final node = await repository.getContentNodeById(params.nodeId!);
      if (node != null && node.title.isNotEmpty) {
        state = state.copyWith(moduleTitle: node.title);
        return;
      }
    }
    if (params.lessonTitle != null && params.lessonTitle!.isNotEmpty) {
      state = state.copyWith(moduleTitle: params.lessonTitle!);
      return;
    }
    final module = await repository.getModuleById(params.moduleId);
    if (module != null) {
      state = state.copyWith(moduleTitle: module.title);
    }
  }

  void onInputChanged(String input) {
    state = state.copyWith(
      chatUiState: state.chatUiState.copyWith(currentInput: input),
    );
  }

  Future<void> onSendMessage() async {
    if (state.chatUiState.isModelThinking) return;
    final input = state.chatUiState.currentInput.trim();
    if (input.isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(role: 'user', content: input);
    final currentHistory = [...state.chatUiState.chatHistory, userMessage];

    state = state.copyWith(
      chatUiState: state.chatUiState.copyWith(
        chatHistory: currentHistory,
        currentInput: '',
        isModelThinking: true,
      ),
    );

    // Add placeholder for AI response
    const aiPlaceholder = ChatMessage(
      role: 'assistant',
      content: '',
      isPending: true,
    );
    state = state.copyWith(
      chatUiState: state.chatUiState.copyWith(
        chatHistory: [...currentHistory, aiPlaceholder],
      ),
    );

    try {
      final repository = ref.read(studyRepositoryProvider);

      String contextContent = '';
      String topicTitle = state.moduleTitle;

      // 1. If nodeId is specified, fetch the specific node content
      if (params.nodeId != null) {
        final node = await repository.getContentNodeById(params.nodeId!);
        if (node != null && node.contentMd.trim().isNotEmpty) {
          contextContent = node.contentMd.trim();
          if (node.title.trim().isNotEmpty) {
            topicTitle = node.title.trim();
          }
        }
      }

      // 2. If lessonContent is provided directly
      if (contextContent.isEmpty &&
          params.lessonContent != null &&
          params.lessonContent!.trim().isNotEmpty) {
        contextContent = params.lessonContent!.trim();
        if (params.lessonTitle != null && params.lessonTitle!.trim().isNotEmpty) {
          topicTitle = params.lessonTitle!.trim();
        }
      }

      // 3. Fallback: only if no specific lesson is found, load submodules of module
      if (contextContent.isEmpty) {
        final submodules = await repository
            .getSubmodulesForModule(params.moduleId)
            .first
            .timeout(const Duration(seconds: 20));
        contextContent = submodules.map((s) => s.contentMd).join("\n\n");
      }

      // Safety cap: never send more than 12,000 characters to prevent TPM overflow on Groq
      if (contextContent.length > 12000) {
        contextContent = contextContent.substring(0, 12000);
      }

      final systemMessage = Message(
        role: 'system',
        content:
            "Eres un tutor experto en '$topicTitle'. Tu objetivo es ayudar al estudiante a entender el siguiente contenido. DEBES basar tus respuestas estrictamente en este contenido. Si te preguntan algo fuera de este tema, indica amablemente que solo puedes responder sobre la materia.\n\nCONTENIDO DE LA LECCIÓN / TEMA:\n$contextContent",
      );
      final historyForApi = currentHistory.length > 10
          ? currentHistory.sublist(currentHistory.length - 10)
          : currentHistory;
      final apiMessages = [
        systemMessage,
        ...historyForApi.map((m) => Message(role: m.role, content: m.content)),
      ];
      final groqService = ref.read(groqApiServiceProvider);
      final stream = groqService.streamChat(apiMessages);

      await for (final chunk in stream) {
        _appendAiResponse(chunk);
      }
    } catch (e) {
      _appendAiResponse("\n\n[Error: No se pudo conectar con el asistente]");
    } finally {
      _finalizeAiResponse();
    }
  }

  void _appendAiResponse(String chunk) {
    final history = List<ChatMessage>.from(state.chatUiState.chatHistory);
    if (history.isEmpty) return;

    final lastMsg = history.last;
    if (lastMsg.role == 'assistant') {
      final updatedMsg = lastMsg.copyWith(
        content: lastMsg.content + chunk,
        isPending: true,
      );
      history.removeLast();
      history.add(updatedMsg);

      state = state.copyWith(
        chatUiState: state.chatUiState.copyWith(chatHistory: history),
      );
    }
  }

  void _finalizeAiResponse() {
    final history = List<ChatMessage>.from(state.chatUiState.chatHistory);
    if (history.isEmpty) return;

    final lastMsg = history.last;
    if (lastMsg.role == 'assistant') {
      final updatedMsg = lastMsg.copyWith(isPending: false);
      history.removeLast();
      history.add(updatedMsg);

      state = state.copyWith(
        chatUiState: state.chatUiState.copyWith(
          chatHistory: history,
          isModelThinking: false,
        ),
      );
    } else {
      state = state.copyWith(
        chatUiState: state.chatUiState.copyWith(isModelThinking: false),
      );
    }
  }
}

final moduleDetailViewModelProvider =
    StateNotifierProvider.family<
      ModuleDetailViewModel,
      ModuleDetailUiState,
      ChatParams
    >((ref, params) {
      return ModuleDetailViewModel(ref, params);
    });

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

class ModuleDetailViewModel extends StateNotifier<ModuleDetailUiState> {
  final Ref ref;
  final int moduleId;

  ModuleDetailViewModel(this.ref, this.moduleId)
    : super(const ModuleDetailUiState()) {
    _loadModuleTitle();
  }

  Future<void> _loadModuleTitle() async {
    final repository = ref.read(studyRepositoryProvider);
    final module = await repository.getModuleById(moduleId);
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

    // Prepare API messages
    // Prepare API messages
    final repository = ref.read(studyRepositoryProvider);
    final submodulesStream = repository.getSubmodulesForModule(moduleId);
    final submodules = await submodulesStream.first;
    final contextContent = submodules.map((s) => s.contentMd).join("\n\n");

    final systemMessage = Message(
      role: 'system',
      content:
          "Eres un tutor experto en esta materia. Tu objetivo es ayudar al estudiante a entender el siguiente contenido. DEBES basar tus respuestas estrictamente en este contenido. Si te preguntan algo fuera de este tema, indica amablemente que solo puedes responder sobre la materia.\n\nCONTENIDO DE LA MATERIA:\n$contextContent",
    );

    final apiMessages = [
      systemMessage,
      ...currentHistory.map((m) => Message(role: m.role, content: m.content)),
    ];

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
    }
  }
}

final moduleDetailViewModelProvider =
    StateNotifierProvider.family<
      ModuleDetailViewModel,
      ModuleDetailUiState,
      int
    >((ref, moduleId) {
      return ModuleDetailViewModel(ref, moduleId);
    });

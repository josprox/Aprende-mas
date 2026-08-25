import 'dart:convert';

import 'package:aprende_mas/models/api_models.dart';
import 'package:aprende_mas/services/api/auth_api_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Usa la llave de Groq del usuario cuando existe. Si no, solicita el servicio
/// de IA de Joss Red con la sesión autenticada del usuario.
class GroqApiService {
  static const _personalApiKeyPreference = 'groq_personal_api_key';
  static const _personalModelPreference = 'groq_personal_model';
  static const _authTokenPreference = 'joss_auth_jwt_token';

  final Dio _groqDio = Dio(
    BaseOptions(
      baseUrl: 'https://api.groq.com/openai/v1',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 75),
      headers: const {'Content-Type': 'application/json'},
    ),
  );
  final Dio _serverDio = Dio();

  static Future<String?> getPersonalApiKey() async {
    final preferences = await SharedPreferences.getInstance();
    final key = preferences.getString(_personalApiKeyPreference)?.trim();
    return key == null || key.isEmpty ? null : key;
  }

  static Future<void> savePersonalApiKey(String apiKey) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_personalApiKeyPreference, apiKey.trim());
  }

  static Future<void> clearPersonalApiKey() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_personalApiKeyPreference);
  }

  static Future<String?> getPersonalModel() async {
    final preferences = await SharedPreferences.getInstance();
    final model = preferences.getString(_personalModelPreference)?.trim();
    return model == null || model.isEmpty ? null : model;
  }

  static Future<void> savePersonalModel(String model) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_personalModelPreference, model.trim());
  }

  static Future<void> clearPersonalModel() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_personalModelPreference);
  }

  Future<List<String>> getAvailableModels({String? apiKey}) async {
    apiKey ??= await getPersonalApiKey();
    if (apiKey == null) {
      throw StateError('Primero guarda tu llave personal de Groq.');
    }
    final response = await _groqDio.get(
      '/models',
      options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
    );
    final models =
        ((response.data as Map<String, dynamic>)['data'] as List? ?? [])
            .whereType<Map>()
            .map((item) => item['id']?.toString())
            .whereType<String>()
            .where((id) => id.isNotEmpty)
            .toList()
          ..sort();
    return models;
  }

  Future<List<QuizQuestion>> generateQuestions(
    String moduleContent,
    int moduleId,
  ) async {
    final apiKey = await getPersonalApiKey();
    try {
      final content = apiKey == null
          ? await _generateQuestionsWithServer(moduleContent, moduleId)
          : await _generateQuestionsWithPersonalKey(moduleContent, apiKey);
      return _parseQuestions(content);
    } catch (error) {
      print('Error al generar preguntas: $error');
      return [];
    }
  }

  Future<String> _generateQuestionsWithPersonalKey(
    String moduleContent,
    String apiKey,
  ) async {
    final model = await getPersonalModel();
    if (model == null) {
      throw StateError('Selecciona un modelo de Groq en Ajustes.');
    }
    final response = await _groqDio.post(
      '/chat/completions',
      data: GroqRequest(
        messages: [Message(role: 'user', content: _quizPrompt(moduleContent))],
        model: model,
        response_format: const ResponseFormat(type: 'json_object'),
      ).toJson(),
      options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
    );
    return GroqResponse.fromJson(
          response.data as Map<String, dynamic>,
        ).choices?.firstOrNull?.message.content ??
        '';
  }

  Future<String> _generateQuestionsWithServer(
    String moduleContent,
    int moduleId,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(_authTokenPreference);
    if (token == null || token.isEmpty) {
      throw StateError('Inicia sesión o configura tu propia llave de Groq.');
    }

    final response = await _serverDio.post(
      '${AuthApiService.baseUrl}/ai/quiz',
      data: {'module_content': moduleContent, 'module_id': moduleId},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    final body = response.data as Map<String, dynamic>;
    if (body['status'] != 'success' || body['content'] is! String) {
      throw StateError(
        body['message']?.toString() ?? 'Respuesta de IA inválida.',
      );
    }
    return body['content'] as String;
  }

  List<QuizQuestion> _parseQuestions(String content) {
    final jsonContent = content
        .trim()
        .replaceFirst(RegExp(r'^```json\s*'), '')
        .replaceFirst(RegExp(r'\s*```$'), '');
    if (jsonContent.isEmpty) return [];
    return QuizPayload.fromJson(
      jsonDecode(jsonContent) as Map<String, dynamic>,
    ).questions;
  }

  String _quizPrompt(String moduleContent) =>
      '''
ACTÚA COMO UN EXPERTO DISEÑADOR DE EXÁMENES DE CERTIFICACIÓN (EGEL, CCNA).
Crea entre 15 y 30 preguntas de opción múltiple de nivel licenciatura basadas estrictamente en el siguiente contenido. Cada pregunta debe tener cuatro opciones A, B, C y D, exigir análisis, aplicación o comparación e incluir una explicación breve de la respuesta correcta.

Responde únicamente con JSON válido, sin Markdown, con esta estructura exacta:
{"questions":[{"questionText":"...","optionA":"...","optionB":"...","optionC":"...","optionD":"...","correctAnswer":"C","explanationText":"..."}]}

Contenido del módulo:
$moduleContent
''';

  Stream<String> streamChat(List<Message> chatHistory) async* {
    final apiKey = await getPersonalApiKey();
    if (apiKey == null) {
      try {
        yield await _sendChatWithServer(chatHistory);
      } catch (error) {
        yield 'Error del servidor: $error';
      }
      return;
    }

    final model = await getPersonalModel();
    if (model == null) {
      yield 'Selecciona un modelo de Groq en Ajustes para usar tu llave personal.';
      return;
    }

    try {
      final response = await _groqDio.post(
        '/chat/completions',
        data: GroqRequest(
          messages: chatHistory,
          model: model,
          stream: true,
          response_format: const ResponseFormat(type: 'text'),
        ).toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
          responseType: ResponseType.stream,
        ),
      );
      await for (final chunk in response.data.stream) {
        for (final line in utf8.decode(chunk).split('\n')) {
          if (!line.startsWith('data: ')) continue;
          final value = line.substring(6);
          if (value == '[DONE]') return;
          try {
            final content = jsonDecode(
              value,
            )['choices']?[0]?['delta']?['content'];
            if (content != null) yield content as String;
          } catch (_) {}
        }
      }
    } catch (error) {
      yield 'Error del servidor: $error';
    }
  }

  Future<String> _sendChatWithServer(List<Message> messages) async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(_authTokenPreference);
    if (token == null || token.isEmpty) {
      throw StateError('Inicia sesión o configura tu propia llave de Groq.');
    }

    final response = await _serverDio.post(
      '${AuthApiService.baseUrl}/ai/chat',
      data: {
        'messages_json': jsonEncode(messages.map((m) => m.toJson()).toList()),
      },
      options: Options(
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 75),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    final body = response.data as Map<String, dynamic>;
    if (body['status'] != 'success' || body['content'] is! String) {
      throw StateError(
        body['message']?.toString() ?? 'Respuesta de IA inválida.',
      );
    }
    return body['content'] as String;
  }
}

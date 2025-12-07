import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aprende_mas/models/api_models.dart';
// For Question entity mapping if needed, though we usually return domain models
// To distinguish from models

class GroqApiService {
  final Dio _dio = Dio();

  GroqApiService() {
    _dio.options.baseUrl = 'https://api.groq.com/openai/v1';
    _dio.options.headers = {'Content-Type': 'application/json'};
  }

  Future<String?> _getApiKey() async {
    await dotenv.load(fileName: ".env"); // Adjust path as needed
    return dotenv.env['GROQ_CLOUD_API'];
  }

  Future<String?> _getModel() async {
    await dotenv.load(fileName: ".env");
    return dotenv.env['GROQ_CLOUD_MODEL'];
  }

  Future<List<QuizQuestion>> generateQuestions(
    String moduleContent,
    int moduleId,
  ) async {
    final apiKey = await _getApiKey();
    final modelGroq = await _getModel();

    if (apiKey == null || apiKey.isEmpty || apiKey == "TU_API_KEY_AQUI") {
      print("API Key de Groq no encontrada o inválida.");
      return [];
    }

    final prompt =
        """
            ACTÚA COMO UN EXPERTO DISEÑADOR DE EXÁMENES DE CERTIFICACIÓN (EGEL, CCNA).
            Tu objetivo es crear un banco de preguntas de alta dificultad para un examen de nivel licenciatura, basado estrictamente en el siguiente contenido: "$moduleContent".

            REGLAS CRÍTICAS PARA LAS PREGUNTAS:
            1.  **Formato:** Genera entre 15 y 30 preguntas de opción múltiple. (Prioriza calidad sobre cantidad).
            2.  **Opciones:** 4 opciones de respuesta (A, B, C, D).
            3.  **Complejidad (Nivel Licenciatura/EGEL):** Las preguntas deben forzar el ANÁLISIS, la APLICACIÓN o la COMPARACIÓN de conceptos.
            4.  **Explicación (CRÍTICO):** Para cada pregunta, debes incluir un campo 'explanationText' que justifique de forma concisa (máx. 2 frases) POR QUÉ la 'correctAnswer' es la correcta, basándose explícitamente en el contenido proporcionado.
            
            FORMATO DE SALIDA OBLIGATORIO:
            Responde *únicamente* con el objeto JSON. No incluyas texto introductorio. La estructura exacta es:
            {
                "questions": [
                    {
                       "questionText": "Texto de la pregunta...",
                       "optionA": "Opción A (distractor plausible)",
                       "optionB": "Opción B (distractor plausible)",
                       "optionC": "Opción C (respuesta correcta)",
                       "optionD": "Opción D (distractor plausible)",
                       "correctAnswer": "C",
                       "explanationText": "Correcto, el concepto X es fundamental en la capa Y porque..." // <--- ¡NUEVA ESTRUCTURA!
                    }
                ]
            }
        """;

    final request = GroqRequest(
      messages: [Message(role: "user", content: prompt)],
      model: modelGroq ?? 'llama3-70b-8192', // Fallback model
      response_format: const ResponseFormat(type: "json_object"),
    );

    try {
      final response = await _dio.post(
        '/chat/completions',
        data: request.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
      );

      final groqResponse = GroqResponse.fromJson(response.data);
      final jsonContent = groqResponse.choices?.firstOrNull?.message.content;

      if (jsonContent == null) {
        print("⚠️ No se recibió contenido en 'choices'.");
        return [];
      }

      final quizPayload = QuizPayload.fromJson(jsonDecode(jsonContent));
      return quizPayload.questions;
    } catch (e) {
      print("💥 Error al generar preguntas: $e");
      return [];
    }
  }

  Stream<String> streamChat(List<Message> chatHistory) async* {
    final apiKey = await _getApiKey();
    final modelGroq = await _getModel();

    if (apiKey == null || apiKey.isEmpty || apiKey == "TU_API_KEY_AQUI") {
      yield "Error: Clave de API de Groq no configurada.";
      return;
    }

    final request = GroqRequest(
      messages: chatHistory,
      model: modelGroq ?? 'llama3-70b-8192',
      stream: true,
      response_format: const ResponseFormat(type: "text"),
    );

    try {
      final response = await _dio.post(
        '/chat/completions',
        data: request.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data.stream;
      await for (final chunk in stream) {
        final String chunkStr = utf8.decode(chunk);
        final lines = chunkStr
            .split('\n')
            .where((line) => line.isNotEmpty)
            .toList();

        for (final line in lines) {
          if (line.startsWith("data: ")) {
            final jsonString = line.substring(6);
            if (jsonString == "[DONE]") break;

            try {
              final jsonMap = jsonDecode(jsonString);
              // We need a specific stream response model or just parse manually
              final content = jsonMap['choices']?[0]?['delta']?['content'];
              if (content != null) {
                yield content;
              }
            } catch (e) {
              // Ignore parse errors for partial chunks
            }
          }
        }
      }
    } catch (e) {
      yield "Error del servidor: $e";
    }
  }
}

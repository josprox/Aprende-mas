class GroqRequest {
  final List<Message> messages;
  final String model;
  final double temperature;
  final int max_tokens;
  final double top_p;
  final bool stream;
  final ResponseFormat response_format;

  const GroqRequest({
    required this.messages,
    required this.model,
    this.temperature = 0.7,
    this.max_tokens = 2048,
    this.top_p = 1.0,
    this.stream = false,
    this.response_format = const ResponseFormat(type: 'json_object'),
  });

  factory GroqRequest.fromJson(Map<String, dynamic> json) {
    return GroqRequest(
      messages: (json['messages'] as List)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
      model: json['model'] as String,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      max_tokens: json['max_tokens'] as int? ?? 2048,
      top_p: (json['top_p'] as num?)?.toDouble() ?? 1.0,
      stream: json['stream'] as bool? ?? false,
      response_format: json['response_format'] != null
          ? ResponseFormat.fromJson(
              json['response_format'] as Map<String, dynamic>,
            )
          : const ResponseFormat(type: 'json_object'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((e) => e.toJson()).toList(),
      'model': model,
      'temperature': temperature,
      'max_tokens': max_tokens,
      'top_p': top_p,
      'stream': stream,
      'response_format': response_format.toJson(),
    };
  }
}

class Message {
  final String role;
  final String content;

  const Message({required this.role, required this.content});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'role': role, 'content': content};
  }
}

class ResponseFormat {
  final String type;

  const ResponseFormat({required this.type});

  factory ResponseFormat.fromJson(Map<String, dynamic> json) {
    return ResponseFormat(type: json['type'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'type': type};
  }
}

class GroqResponse {
  final List<Choice>? choices;

  const GroqResponse({this.choices});

  factory GroqResponse.fromJson(Map<String, dynamic> json) {
    return GroqResponse(
      choices: (json['choices'] as List?)
          ?.map((e) => Choice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'choices': choices?.map((e) => e.toJson()).toList()};
  }
}

class Choice {
  final Message message;

  const Choice({required this.message});

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      message: Message.fromJson(json['message'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message.toJson()};
  }
}

class QuizPayload {
  final List<QuizQuestion> questions;

  const QuizPayload({required this.questions});

  factory QuizPayload.fromJson(Map<String, dynamic> json) {
    return QuizPayload(
      questions: (json['questions'] as List)
          .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'questions': questions.map((e) => e.toJson()).toList()};
  }
}

class QuizQuestion {
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final String explanationText;

  const QuizQuestion({
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    required this.explanationText,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      questionText: json['questionText'] as String,
      optionA: json['optionA'] as String,
      optionB: json['optionB'] as String,
      optionC: json['optionC'] as String,
      optionD: json['optionD'] as String,
      correctAnswer: json['correctAnswer'] as String,
      explanationText: json['explanationText'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'correctAnswer': correctAnswer,
      'explanationText': explanationText,
    };
  }
}

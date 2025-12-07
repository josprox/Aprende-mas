class Subject {
  final int? id;
  final String name;
  final String author;
  final String version;
  final int? repositoryId;

  Subject({
    this.id,
    required this.name,
    required this.author,
    required this.version,
    this.repositoryId,
  });

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      name: map['name'],
      author: map['author'],
      version: map['version'],
      repositoryId: map['repository_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'author': author,
      'version': version,
      'repository_id': repositoryId,
    };
  }
}

class Module {
  final int? id;
  final int subjectId;
  final String title;
  final String shortDescription;

  Module({
    this.id,
    required this.subjectId,
    required this.title,
    required this.shortDescription,
  });

  factory Module.fromMap(Map<String, dynamic> map) {
    return Module(
      id: map['id'],
      subjectId: map['subject_id'],
      title: map['title'],
      shortDescription: map['short_description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'subject_id': subjectId,
      'title': title,
      'short_description': shortDescription,
    };
  }
}

class Submodule {
  final int? id;
  final int moduleId;
  final String title;
  final String contentMd;

  Submodule({
    this.id,
    required this.moduleId,
    required this.title,
    required this.contentMd,
  });

  factory Submodule.fromMap(Map<String, dynamic> map) {
    return Submodule(
      id: map['id'],
      moduleId: map['module_id'],
      title: map['title'],
      contentMd: map['content_md'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'module_id': moduleId,
      'title': title,
      'content_md': contentMd,
    };
  }
}

class Question {
  final int? id;
  final int moduleId;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final String explanationText;

  Question({
    this.id,
    required this.moduleId,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    required this.explanationText,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      moduleId: map['module_id'],
      questionText: map['question_text'],
      optionA: map['option_a'],
      optionB: map['option_b'],
      optionC: map['option_c'],
      optionD: map['option_d'],
      correctAnswer: map['correct_answer'],
      explanationText: map['explanation_text'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'module_id': moduleId,
      'question_text': questionText,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_answer': correctAnswer,
      'explanation_text': explanationText,
    };
  }
}

class TestAttempt {
  final int? id;
  final int moduleId;
  final int timestamp;
  final double score;
  final String status;
  final int totalQuestions;
  final int correctAnswers;
  final int currentQuestionIndex;

  TestAttempt({
    this.id,
    required this.moduleId,
    required this.timestamp,
    required this.score,
    required this.status,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.currentQuestionIndex,
  });

  factory TestAttempt.fromMap(Map<String, dynamic> map) {
    return TestAttempt(
      id: map['id'],
      moduleId: map['module_id'],
      timestamp: map['timestamp'],
      score: map['score'],
      status: map['status'],
      totalQuestions: map['total_questions'] ?? 0,
      correctAnswers: map['correct_answers'] ?? 0,
      currentQuestionIndex: map['current_question_index'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'module_id': moduleId,
      'timestamp': timestamp,
      'score': score,
      'status': status,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'current_question_index': currentQuestionIndex,
    };
  }

  TestAttempt copyWith({
    int? id,
    int? moduleId,
    int? timestamp,
    double? score,
    String? status,
    int? totalQuestions,
    int? correctAnswers,
    int? currentQuestionIndex,
  }) {
    return TestAttempt(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      timestamp: timestamp ?? this.timestamp,
      score: score ?? this.score,
      status: status ?? this.status,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
    );
  }
}

class UserAnswer {
  final int? id;
  final int testAttemptId;
  final int questionId;
  final String selectedOption;
  final int isCorrect;
  final String? explanationText;

  UserAnswer({
    this.id,
    required this.testAttemptId,
    required this.questionId,
    required this.selectedOption,
    required this.isCorrect,
    this.explanationText,
  });

  factory UserAnswer.fromMap(Map<String, dynamic> map) {
    return UserAnswer(
      id: map['id'],
      testAttemptId: map['test_attempt_id'],
      questionId: map['question_id'],
      selectedOption: map['selected_option'],
      isCorrect: map['is_correct'] is int
          ? map['is_correct']
          : (map['is_correct'] == true ? 1 : 0),
      explanationText: map['explanation_text'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'test_attempt_id': testAttemptId,
      'question_id': questionId,
      'selected_option': selectedOption,
      'is_correct': isCorrect,
      'explanation_text': explanationText,
    };
  }
}

class TestAttemptWithModule {
  final TestAttempt attempt;
  final String moduleTitle;

  TestAttemptWithModule({required this.attempt, required this.moduleTitle});
}

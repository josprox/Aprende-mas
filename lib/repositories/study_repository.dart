import 'dart:async';
import 'dart:convert';
import 'package:aprende_mas/models/import_models.dart';
import 'package:aprende_mas/models/subject_models.dart';
import 'package:aprende_mas/repositories/i_study_repository.dart';
import 'package:aprende_mas/services/api/groq_api_service.dart';
import 'package:aprende_mas/services/api/repository_api_service.dart';
import 'package:aprende_mas/services/database/database_helper.dart';

class StudyRepository implements IStudyRepository {
  final GroqApiService _groqApiService;
  final RepositoryApiService _repositoryApiService;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Stream Controllers
  final _subjectsController = StreamController<List<Subject>>.broadcast();
  final _completedTestsController =
      StreamController<List<TestAttemptWithModule>>.broadcast();

  StudyRepository(this._groqApiService, this._repositoryApiService) {
    _refreshSubjects();
    _emitCompletedTests();
  }

  Future<void> _emitCompletedTests() async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT t.*, m.title as module_title 
      FROM test_attempts t
      INNER JOIN modules m ON t.module_id = m.id
      WHERE t.status = 'COMPLETED'
      ORDER BY t.timestamp DESC
    ''');

    final list = results.map((e) {
      final attempt = TestAttempt.fromMap(e);
      return TestAttemptWithModule(
        attempt: attempt,
        moduleTitle: e['module_title'] as String,
      );
    }).toList();

    _completedTestsController.add(list);
  }

  Future<void> _refreshSubjects() async {
    final db = await _dbHelper.database;
    final maps = await db.query('subjects');
    final subjects = maps.map((e) => Subject.fromMap(e)).toList();
    _subjectsController.add(subjects);
  }

  @override
  Stream<List<Subject>> getAllSubjects() async* {
    // 1. Yield current state directly from DB to ensure new subscribers get data immediately
    final db = await _dbHelper.database;
    final maps = await db.query('subjects');
    yield maps.map((e) => Subject.fromMap(e)).toList();

    // 2. Yield future updates from the broadcast stream
    yield* _subjectsController.stream;
  }

  @override
  Stream<List<Module>> getModulesForSubject(int subjectId) async* {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'modules',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
    );
    yield maps.map((e) => Module.fromMap(e)).toList();
  }

  @override
  Stream<List<Submodule>> getSubmodulesForModule(int moduleId) async* {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'submodules',
      where: 'module_id = ?',
      whereArgs: [moduleId],
    );
    yield maps.map((e) => Submodule.fromMap(e)).toList();
  }

  @override
  Future<List<Question>> getOrCreateQuestionsForModule(int moduleId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'questions',
      where: 'module_id = ?',
      whereArgs: [moduleId],
    );

    if (maps.isNotEmpty) {
      return maps.map((e) => Question.fromMap(e)).toList();
    }

    // Generate questions via AI
    final submodulesMap = await db.query(
      'submodules',
      where: 'module_id = ?',
      whereArgs: [moduleId],
    );
    final submodules = submodulesMap.map((e) => Submodule.fromMap(e)).toList();
    final fullContent = submodules.map((s) => s.contentMd).join("\n\n");

    if (fullContent.isEmpty) return [];

    try {
      final generatedQuestions = await _groqApiService.generateQuestions(
        fullContent,
        moduleId,
      );

      for (final q in generatedQuestions) {
        await db.insert('questions', {
          'module_id': moduleId,
          'question_text': q.questionText,
          'option_a': q.optionA,
          'option_b': q.optionB,
          'option_c': q.optionC,
          'option_d': q.optionD,
          'correct_answer': q.correctAnswer,
          'explanation_text': q.explanationText,
        });
      }

      final newMaps = await db.query(
        'questions',
        where: 'module_id = ?',
        whereArgs: [moduleId],
      );
      return newMaps.map((e) => Question.fromMap(e)).toList();
    } catch (e) {
      print("Error generating questions: $e");
      return [];
    }
  }

  @override
  Future<List<Question>> getOriginalQuestionsForModule(int moduleId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'questions',
      where: 'module_id = ?',
      whereArgs: [moduleId],
    );
    return maps.map((e) => Question.fromMap(e)).toList();
  }

  @override
  Future<int> createTestAttempt(int moduleId, int totalQuestions) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = await db.insert('test_attempts', {
      'module_id': moduleId,
      'timestamp': now,
      'score': 0.0,
      'status': 'PENDING',
      'total_questions': totalQuestions,
      'correct_answers': 0,
      'current_question_index': 0,
      // Add missing columns if schema changed, for now assuming these match
    });
    return id;
  }

  @override
  Future<TestAttempt?> findPendingTest(int moduleId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'test_attempts',
      where: 'module_id = ? AND status = ?',
      whereArgs: [moduleId, 'PENDING'],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return TestAttempt.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> updateTestAttempt(TestAttempt attempt) async {
    final db = await _dbHelper.database;
    await db.update(
      'test_attempts',
      attempt.toMap(),
      where: 'id = ?',
      whereArgs: [attempt.id],
    );
    if (attempt.status == 'COMPLETED') {
      _emitCompletedTests();
    }
  }

  @override
  Future<void> finishTestAttempt(TestAttempt attempt) async {
    final updatedAttempt = attempt.copyWith(status: 'COMPLETED');
    await updateTestAttempt(updatedAttempt);
    // _emitCompletedTests is called inside updateTestAttempt
  }

  @override
  Future<void> saveUserAnswer(UserAnswer answer) async {
    final db = await _dbHelper.database;
    await db.insert('user_answers', answer.toMap());
  }

  @override
  Future<List<UserAnswer>> getUserAnswersForAttempt(int attemptId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'user_answers',
      where: 'test_attempt_id = ?',
      whereArgs: [attemptId],
    );
    return maps.map((e) => UserAnswer.fromMap(e)).toList();
  }

  @override
  Future<TestAttempt?> getTestAttemptById(int attemptId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'test_attempts',
      where: 'id = ?',
      whereArgs: [attemptId],
    );
    if (maps.isNotEmpty) {
      return TestAttempt.fromMap(maps.first);
    }
    return null;
  }

  @override
  Stream<List<TestAttemptWithModule>> getCompletedTests() =>
      _completedTestsController.stream;

  @override
  Stream<List<TestAttemptWithModule>> getPendingTests() async* {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT t.*, m.title as module_title 
      FROM test_attempts t
      INNER JOIN modules m ON t.module_id = m.id
      WHERE t.status = 'PENDING'
      ORDER BY t.timestamp DESC
    ''');
    yield results.map((e) {
      final attempt = TestAttempt.fromMap(e);
      return TestAttemptWithModule(
        attempt: attempt,
        moduleTitle: e['module_title'] as String,
      );
    }).toList();
  }

  @override
  Future<void> deleteTestAttempt(int attemptId) async {
    final db = await _dbHelper.database;
    await db.delete('test_attempts', where: 'id = ?', whereArgs: [attemptId]);
    _emitCompletedTests();
  }

  @override
  Future<void> forceRegenerateQuestions(int moduleId) async {
    // No-op for now unless requested
  }

  @override
  Future<void> importSubjectFromJson(
    String jsonString, {
    int? repositoryId,
  }) async {
    final db = await _dbHelper.database;

    // Check for existing subject with this repositoryId to avoid duplicates
    if (repositoryId != null) {
      final existing = await db.query(
        'subjects',
        where: 'repository_id = ?',
        whereArgs: [repositoryId],
      );
      if (existing.isNotEmpty) {
        final subjectId = existing.first['id'] as int;
        await updateSubjectFromJson(subjectId, jsonString);
        return;
      }
    }

    final subjectImport = SubjectImport.fromJson(jsonDecode(jsonString));

    await db.transaction((txn) async {
      final subjectId = await txn.insert('subjects', {
        'name': subjectImport.name,
        'author': subjectImport.author,
        'version': subjectImport.version,
        'repository_id': repositoryId,
      });

      for (final moduleImport in subjectImport.modules) {
        final moduleId = await txn.insert('modules', {
          'subject_id': subjectId,
          'title': moduleImport.title,
          'short_description': moduleImport.shortDescription,
        });

        for (final submoduleImport in moduleImport.submodules) {
          await txn.insert('submodules', {
            'module_id': moduleId,
            'title': submoduleImport.title,
            'content_md': submoduleImport.contentMd,
          });
        }
      }
    });

    _refreshSubjects();
  }

  @override
  Future<void> updateSubjectFromJson(int subjectId, String jsonString) async {
    final db = await _dbHelper.database;
    final subjectImport = SubjectImport.fromJson(jsonDecode(jsonString));

    await db.transaction((txn) async {
      await txn.update(
        'subjects',
        {
          'name': subjectImport.name,
          'author': subjectImport.author,
          'version': subjectImport.version,
        },
        where: 'id = ?',
        whereArgs: [subjectId],
      );

      await txn.delete(
        'modules',
        where: 'subject_id = ?',
        whereArgs: [subjectId],
      );

      for (final moduleImport in subjectImport.modules) {
        final moduleId = await txn.insert('modules', {
          'subject_id': subjectId,
          'title': moduleImport.title,
          'short_description': moduleImport.shortDescription,
        });

        for (final submoduleImport in moduleImport.submodules) {
          await txn.insert('submodules', {
            'module_id': moduleId,
            'title': submoduleImport.title,
            'content_md': submoduleImport.contentMd,
          });
        }
      }
    });
    _refreshSubjects();
  }

  @override
  Future<void> checkForUpdates() async {
    final db = await _dbHelper.database;
    final maps = await db.query('subjects');
    final subjects = maps.map((e) => Subject.fromMap(e)).toList();

    for (final subject in subjects) {
      if (subject.repositoryId != null) {
        try {
          final remoteData = await _repositoryApiService.downloadRepository(
            subject.repositoryId!,
          );
          final remoteVersion = remoteData['version'] as String;

          if (_isNewerVersion(subject.version, remoteVersion)) {
            await updateSubjectFromJson(subject.id!, jsonEncode(remoteData));
          }
        } catch (e) {
          print("Error checking updates: $e");
        }
      }
    }
  }

  bool _isNewerVersion(String local, String remote) {
    return remote.compareTo(local) > 0;
  }

  @override
  Future<void> deleteSubject(int subjectId) async {
    final db = await _dbHelper.database;
    await db.delete('subjects', where: 'id = ?', whereArgs: [subjectId]);
    _refreshSubjects();
  }

  @override
  Future<Module?> getModuleById(int moduleId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'modules',
      where: 'id = ?',
      whereArgs: [moduleId],
    );
    if (maps.isNotEmpty) return Module.fromMap(maps.first);
    return null;
  }
}

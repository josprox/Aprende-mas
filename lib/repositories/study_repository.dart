import 'dart:convert';
import 'package:aprende_mas/models/import_models.dart';
import 'package:aprende_mas/repositories/i_study_repository.dart';
import 'package:aprende_mas/services/api/groq_api_service.dart';
import 'package:aprende_mas/services/database/app_database.dart';
import 'package:drift/drift.dart';

class StudyRepository implements IStudyRepository {
  final StudyDao _studyDao;
  final GroqApiService _groqApiService;

  StudyRepository(this._studyDao, this._groqApiService);

  @override
  Stream<List<Subject>> getAllSubjects() => _studyDao.getAllSubjects();

  @override
  Stream<List<Module>> getModulesForSubject(int subjectId) =>
      _studyDao.getModulesForSubject(subjectId);

  @override
  Stream<List<Submodule>> getSubmodulesForModule(int moduleId) =>
      _studyDao.getSubmodulesForModule(moduleId);

  @override
  Future<List<Question>> getOrCreateQuestionsForModule(int moduleId) async {
    var questions = await _studyDao.getOriginalQuestionsForModule(moduleId);

    if (questions.isEmpty) {
      print("No hay preguntas para $moduleId. Generando nuevas con la API.");
      final submodulesStream = _studyDao.getSubmodulesForModule(moduleId);
      final submodules = await submodulesStream.first;

      final content = submodules
          .map((s) => "## ${s.title}\n${s.contentMd}")
          .join("\n\n");

      if (content.trim().isEmpty) {
        print(
          "El contenido para generar preguntas está vacío para el módulo $moduleId.",
        );
        return [];
      }

      final newQuestions = await _groqApiService.generateQuestions(
        content,
        moduleId,
      );
      if (newQuestions.isNotEmpty) {
        final questionsToInsert = newQuestions
            .map(
              (q) => QuestionsCompanion.insert(
                moduleId: moduleId,
                questionText: q.questionText,
                optionA: q.optionA,
                optionB: q.optionB,
                optionC: q.optionC,
                optionD: q.optionD,
                correctAnswer: q.correctAnswer,
                explanationText: Value(q.explanationText),
              ),
            )
            .toList();

        // We need a batch insert method in DAO for QuestionsCompanion, but insertQuestions takes List<Question> (Data Class)
        // Drift's insertAll takes Data Classes usually, but we can use batch with companions.
        // Let's assume we update DAO or map to Data Class (but ID is auto-increment, so better use Companion)
        // For now, let's iterate or assume DAO handles it.
        // Actually, my DAO `insertQuestions` takes `List<Question>`. I should probably change it to take Companions or just create Question objects with id=0 (if allowed) or use a loop.
        // Drift Data Classes usually have required ID.
        // I will use a loop with `into(questions).insert` or update DAO to accept Companions.
        // For simplicity here, I'll assume I can map to Question with id=0 and Drift ignores it on insert if auto-increment? No, usually need Companion.
        // I'll use a loop for now to be safe with the current DAO setup, or better, use the batch helper I defined in DAO but pass Companions.
        // Wait, my DAO `insertQuestions` takes `List<Question>`.
        // I will modify the DAO later or just use a loop here calling a single insert if needed, but batch is better.
        // Let's assume I can cast or I'll just do:
        await _studyDao.batch((batch) {
          batch.insertAll(_studyDao.questions, questionsToInsert);
        });

        print("Nuevas ${newQuestions.length} preguntas guardadas en la BD.");
        questions = await _studyDao.getOriginalQuestionsForModule(moduleId);
      }
    } else {
      print(
        "Usando ${questions.length} preguntas existentes de la BD para $moduleId.",
      );
    }
    return questions;
  }

  @override
  Stream<List<TestAttemptWithModule>> getCompletedTests() =>
      _studyDao.getCompletedTestsWithModule();

  @override
  Stream<List<TestAttemptWithModule>> getPendingTests() =>
      _studyDao.getPendingTestsWithModule();

  @override
  Future<int> createTestAttempt(int moduleId, int totalQuestions) {
    return _studyDao.insertTestAttempt(
      TestAttemptsCompanion.insert(
        moduleId: moduleId,
        status: "PENDING",
        totalQuestions: totalQuestions,
        currentQuestionIndex: const Value(0),
      ),
    );
  }

  @override
  Future<void> finishTestAttempt(TestAttempt attempt) {
    return _studyDao.updateTestAttempt(attempt.toCompanion(true));
  }

  @override
  Future<TestAttempt?> findPendingTest(int moduleId) =>
      _studyDao.getPendingTestForModule(moduleId);

  @override
  Future<TestAttempt?> getTestAttemptById(int attemptId) =>
      _studyDao.getTestAttemptById(attemptId);

  @override
  Future<List<UserAnswer>> getUserAnswersForAttempt(int attemptId) =>
      _studyDao.getUserAnswersForAttempt(attemptId);

  @override
  Future<void> saveUserAnswer(UserAnswersCompanion answer) =>
      _studyDao.insertUserAnswer(answer);

  @override
  Future<void> updateTestAttempt(TestAttemptsCompanion attempt) =>
      _studyDao.updateTestAttempt(attempt);

  @override
  Future<Module?> getModuleById(int moduleId) =>
      _studyDao.getModuleById(moduleId);

  @override
  Future<List<Question>> getOriginalQuestionsForModule(int moduleId) =>
      _studyDao.getOriginalQuestionsForModule(moduleId);

  @override
  Future<void> forceRegenerateQuestions(int moduleId) async {
    await _studyDao.deleteAttemptsForModule(moduleId);
    await _studyDao.deleteQuestionsForModule(moduleId);
  }

  @override
  Future<void> importSubjectFromJson(String jsonString) async {
    return _studyDao.transaction(() async {
      final subjectImport = SubjectImport.fromJson(jsonDecode(jsonString));

      final newSubjectId = await _studyDao.insertSubject(
        SubjectsCompanion.insert(
          name: subjectImport.name,
          author: Value(subjectImport.author),
          version: Value(subjectImport.version),
        ),
      );

      for (final moduleImport in subjectImport.modules) {
        final newModuleId = await _studyDao.insertModule(
          ModulesCompanion.insert(
            subjectId: newSubjectId,
            title: moduleImport.title,
            shortDescription: moduleImport.shortDescription,
          ),
        );

        final submodules = moduleImport.submodules
            .map(
              (s) => SubmodulesCompanion.insert(
                moduleId: newModuleId,
                title: s.title,
                contentMd: s.contentMd,
              ),
            )
            .toList();

        // Batch insert submodules
        await _studyDao.batch((batch) {
          batch.insertAll(_studyDao.submodules, submodules);
        });
      }
    });
  }

  @override
  Future<void> deleteSubject(int subjectId) =>
      _studyDao.deleteSubjectById(subjectId);

  @override
  Future<void> deleteTestAttempt(int attemptId) =>
      _studyDao.deleteTestAttemptById(attemptId);

  @override
  Future<void> updateSubjectFromJson(int subjectId, String jsonString) async {
    return _studyDao.transaction(() async {
      final subjectImport = SubjectImport.fromJson(jsonDecode(jsonString));

      await _studyDao.updateSubject(
        SubjectsCompanion(
          id: Value(subjectId),
          name: Value(subjectImport.name),
          author: Value(subjectImport.author),
          version: Value(subjectImport.version),
        ),
      );

      final newModules = subjectImport.modules;
      final oldModules = await _studyDao.getModulesForSubject(subjectId).first;

      final newModulesMap = {for (var m in newModules) m.title: m};
      final oldModulesMap = {for (var m in oldModules) m.title: m};

      // 5. Iterate NEW modules
      for (final newModule in newModules) {
        final oldModule = oldModulesMap[newModule.title];

        if (oldModule == null) {
          // Insert new module
          print("RepoUpdate: Insertando nuevo módulo: ${newModule.title}");
          final newModuleId = await _studyDao.insertModule(
            ModulesCompanion.insert(
              subjectId: subjectId,
              title: newModule.title,
              shortDescription: newModule.shortDescription,
            ),
          );

          final newSubmodules = newModule.submodules
              .map(
                (s) => SubmodulesCompanion.insert(
                  moduleId: newModuleId,
                  title: s.title,
                  contentMd: s.contentMd,
                ),
              )
              .toList();

          await _studyDao.batch(
            (batch) => batch.insertAll(_studyDao.submodules, newSubmodules),
          );
        } else {
          // Update existing module
          print(
            "RepoUpdate: Actualizando módulo existente: ${newModule.title}",
          );
          final moduleId = oldModule.id;

          await _studyDao.updateModule(
            oldModule
                .toCompanion(true)
                .copyWith(shortDescription: Value(newModule.shortDescription)),
          );

          bool contentChanged = false;
          final newSubmodules = newModule.submodules;
          final oldSubmodules = await _studyDao
              .getSubmodulesForModule(moduleId)
              .first;

          final newSubmodulesMap = {for (var s in newSubmodules) s.title: s};
          final oldSubmodulesMap = {for (var s in oldSubmodules) s.title: s};

          // B.1 Iterate new submodules
          for (final newSub in newSubmodules) {
            final oldSub = oldSubmodulesMap[newSub.title];
            if (oldSub == null) {
              print(" -> Insertando submódulo: ${newSub.title}");
              await _studyDao.insertSubmodule(
                SubmodulesCompanion.insert(
                  moduleId: moduleId,
                  title: newSub.title,
                  contentMd: newSub.contentMd,
                ),
              );
              contentChanged = true;
            } else {
              if (oldSub.contentMd != newSub.contentMd) {
                print(" -> Actualizando submódulo: ${newSub.title}");
                await _studyDao.updateSubmodule(
                  oldSub
                      .toCompanion(true)
                      .copyWith(contentMd: Value(newSub.contentMd)),
                );
                contentChanged = true;
              }
            }
          }

          // B.2 Iterate old submodules (Delete)
          for (final oldSub in oldSubmodules) {
            if (!newSubmodulesMap.containsKey(oldSub.title)) {
              print(" -> Borrando submódulo: ${oldSub.title}");
              await _studyDao.deleteSubmoduleById(oldSub.id);
              contentChanged = true;
            }
          }

          // B.3 Clear questions if content changed
          if (contentChanged) {
            print(
              "El contenido del módulo ${oldModule.title} cambió. Borrando preguntas viejas e intentos PENDIENTES.",
            );
            await _studyDao.deleteQuestionsForModule(moduleId);
            await _studyDao.deletePendingAttemptsForModule(moduleId);
          }
        }
      }

      // 6. Iterate OLD modules (Delete)
      for (final oldModule in oldModules) {
        if (!newModulesMap.containsKey(oldModule.title)) {
          print("RepoUpdate: Borrando módulo obsoleto: ${oldModule.title}");
          await _studyDao.deleteModuleById(oldModule.id);
        }
      }

      print(
        "RepoUpdate: ¡Actualización de materia (ID: $subjectId) completada!",
      );
    });
  }
}

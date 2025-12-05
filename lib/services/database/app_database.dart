import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:aprende_mas/models/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Subjects, Modules, Submodules, Questions, TestAttempts, UserAnswers],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Migration logic can be added here later
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftAccessor(
  tables: [Subjects, Modules, Submodules, Questions, TestAttempts, UserAnswers],
)
class StudyDao extends DatabaseAccessor<AppDatabase> with _$StudyDaoMixin {
  StudyDao(super.db);

  // --- Inserts (Contenido de Estudio) ---
  Future<void> insertSubjects(List<Subject> subjects) => batch(
    (batch) =>
        batch.insertAll(this.subjects, subjects, mode: InsertMode.replace),
  );
  Future<void> insertModules(List<Module> modules) => batch(
    (batch) => batch.insertAll(this.modules, modules, mode: InsertMode.replace),
  );
  Future<void> insertSubmodules(List<Submodule> submodules) => batch(
    (batch) =>
        batch.insertAll(this.submodules, submodules, mode: InsertMode.replace),
  );
  Future<void> insertQuestions(List<Question> questions) => batch(
    (batch) =>
        batch.insertAll(this.questions, questions, mode: InsertMode.replace),
  );

  // --- Inserts y Updates (Progreso del Usuario) ---
  Future<int> insertTestAttempt(TestAttemptsCompanion attempt) =>
      into(testAttempts).insert(attempt);
  Future<void> updateTestAttempt(TestAttemptsCompanion attempt) =>
      update(testAttempts).replace(attempt);
  Future<void> insertUserAnswer(UserAnswersCompanion answer) =>
      into(userAnswers).insert(answer);

  // --- Queries (Contenido de Estudio) ---
  Stream<List<Subject>> getAllSubjects() => select(subjects).watch();
  Stream<List<Module>> getModulesForSubject(int subjectId) => (select(
    modules,
  )..where((tbl) => tbl.subjectId.equals(subjectId))).watch();
  Stream<List<Submodule>> getSubmodulesForModule(int moduleId) =>
      (select(submodules)
            ..where((tbl) => tbl.moduleId.equals(moduleId))
            ..orderBy([(t) => OrderingTerm(expression: t.id)]))
          .watch();
  Future<List<Question>> getQuestionsForModule(int moduleId) =>
      (select(questions)..where((tbl) => tbl.moduleId.equals(moduleId))).get();
  Future<int> getSubjectCount() => select(subjects).get().then((l) => l.length);
  Future<void> deleteQuestionsForModule(int moduleId) =>
      (delete(questions)..where((tbl) => tbl.moduleId.equals(moduleId))).go();

  // --- Queries (Progreso del Usuario) ---
  // Complex queries requiring joins will be implemented here

  // getPendingTestsWithModule
  Stream<List<TestAttemptWithModule>> getPendingTestsWithModule() {
    final query = select(
      testAttempts,
    ).join([innerJoin(modules, modules.id.equalsExp(testAttempts.moduleId))]);
    query.where(testAttempts.status.equals('PENDING'));
    query.orderBy([
      OrderingTerm(expression: testAttempts.timestamp, mode: OrderingMode.desc),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TestAttemptWithModule(
          attempt: row.readTable(testAttempts),
          moduleTitle: row.readTable(modules).title,
        );
      }).toList();
    });
  }

  // getCompletedTestsWithModule
  Stream<List<TestAttemptWithModule>> getCompletedTestsWithModule() {
    final query = select(
      testAttempts,
    ).join([innerJoin(modules, modules.id.equalsExp(testAttempts.moduleId))]);
    query.where(testAttempts.status.equals('COMPLETED'));
    query.orderBy([
      OrderingTerm(expression: testAttempts.timestamp, mode: OrderingMode.desc),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TestAttemptWithModule(
          attempt: row.readTable(testAttempts),
          moduleTitle: row.readTable(modules).title,
        );
      }).toList();
    });
  }

  Future<List<UserAnswer>> getUserAnswersForAttempt(int testAttemptId) =>
      (select(
        userAnswers,
      )..where((tbl) => tbl.testAttemptId.equals(testAttemptId))).get();

  Future<TestAttempt?> getPendingTestForModule(int moduleId) =>
      (select(testAttempts)
            ..where(
              (tbl) =>
                  tbl.moduleId.equals(moduleId) & tbl.status.equals('PENDING'),
            )
            ..limit(1))
          .getSingleOrNull();

  Future<TestAttempt?> getTestAttemptById(int attemptId) =>
      (select(testAttempts)
            ..where((tbl) => tbl.id.equals(attemptId))
            ..limit(1))
          .getSingleOrNull();

  Future<List<Question>> getOriginalQuestionsForModule(int moduleId) =>
      (select(questions)
            ..where((tbl) => tbl.moduleId.equals(moduleId))
            ..orderBy([(t) => OrderingTerm(expression: t.id)]))
          .get();

  Future<Module?> getModuleById(int moduleId) =>
      (select(modules)
            ..where((tbl) => tbl.id.equals(moduleId))
            ..limit(1))
          .getSingleOrNull();

  Future<void> deleteAttemptsForModule(int moduleId) => (delete(
    testAttempts,
  )..where((tbl) => tbl.moduleId.equals(moduleId))).go();

  Future<int> insertSubject(SubjectsCompanion subject) =>
      into(subjects).insert(subject);
  Future<int> insertModule(ModulesCompanion module) =>
      into(modules).insert(module);
  Future<int> insertSubmodule(SubmodulesCompanion submodule) =>
      into(submodules).insert(submodule);

  Future<void> deleteSubjectById(int subjectId) =>
      (delete(subjects)..where((tbl) => tbl.id.equals(subjectId))).go();

  Future<void> updateSubject(SubjectsCompanion subject) =>
      update(subjects).replace(subject);
  Future<void> updateModule(ModulesCompanion module) =>
      update(modules).replace(module);
  Future<void> updateSubmodule(SubmodulesCompanion submodule) =>
      update(submodules).replace(submodule);

  Future<void> deleteModuleById(int moduleId) =>
      (delete(modules)..where((tbl) => tbl.id.equals(moduleId))).go();
  Future<void> deleteSubmoduleById(int submoduleId) =>
      (delete(submodules)..where((tbl) => tbl.id.equals(submoduleId))).go();
  Future<void> deletePendingAttemptsForModule(int moduleId) =>
      (delete(testAttempts)..where(
            (tbl) =>
                tbl.moduleId.equals(moduleId) & tbl.status.equals('PENDING'),
          ))
          .go();

  Future<void> deleteTestAttemptById(int attemptId) =>
      (delete(testAttempts)..where((tbl) => tbl.id.equals(attemptId))).go();
}

class TestAttemptWithModule {
  final TestAttempt attempt;
  final String moduleTitle;

  TestAttemptWithModule({required this.attempt, required this.moduleTitle});
}

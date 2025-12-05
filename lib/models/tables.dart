import 'package:drift/drift.dart';

class Subjects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get author => text().withDefault(const Constant('Desconocido'))();
  TextColumn get version => text().withDefault(const Constant('1.0'))();
}

class Modules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get subjectId =>
      integer().references(Subjects, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get shortDescription => text()();
}

class Submodules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get moduleId =>
      integer().references(Modules, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get contentMd => text()();
}

class Questions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get moduleId =>
      integer().references(Modules, #id, onDelete: KeyAction.cascade)();
  TextColumn get questionText => text()();
  TextColumn get optionA => text()();
  TextColumn get optionB => text()();
  TextColumn get optionC => text()();
  TextColumn get optionD => text()();
  TextColumn get correctAnswer => text()(); // "A", "B", "C", "D"
  TextColumn get explanationText => text().withDefault(const Constant(''))();
}

class TestAttempts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get moduleId =>
      integer().references(Modules, #id, onDelete: KeyAction.cascade)();
  TextColumn get status => text()(); // "PENDING" or "COMPLETED"
  RealColumn get score => real().withDefault(const Constant(0.0))();
  IntColumn get totalQuestions => integer()();
  IntColumn get correctAnswers => integer().withDefault(const Constant(0))();
  IntColumn get timestamp => integer().withDefault(
    const Constant(0),
  )(); // Storing as Milliseconds since epoch
  IntColumn get currentQuestionIndex =>
      integer().withDefault(const Constant(0))();
}

class UserAnswers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get testAttemptId =>
      integer().references(TestAttempts, #id, onDelete: KeyAction.cascade)();
  IntColumn get questionId =>
      integer().references(Questions, #id, onDelete: KeyAction.cascade)();
  TextColumn get selectedOption => text()(); // "A", "B", "C", "D"
  BoolColumn get isCorrect => boolean()();
  TextColumn get explanationText => text().nullable()();
}

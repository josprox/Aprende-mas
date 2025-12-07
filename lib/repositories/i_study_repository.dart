import 'package:aprende_mas/models/subject_models.dart';

abstract class IStudyRepository {
  Stream<List<Subject>> getAllSubjects();
  Stream<List<Module>> getModulesForSubject(int subjectId);
  Stream<List<Submodule>> getSubmodulesForModule(int moduleId);
  Future<List<Question>> getOrCreateQuestionsForModule(int moduleId);
  Stream<List<TestAttemptWithModule>> getCompletedTests();
  Stream<List<TestAttemptWithModule>> getPendingTests();
  Future<int> createTestAttempt(int moduleId, int totalQuestions);
  Future<void> finishTestAttempt(TestAttempt attempt);
  Future<TestAttempt?> findPendingTest(int moduleId);
  Future<TestAttempt?> getTestAttemptById(int attemptId);
  Future<List<UserAnswer>> getUserAnswersForAttempt(int attemptId);
  Future<void> saveUserAnswer(UserAnswer answer);
  Future<void> updateTestAttempt(TestAttempt attempt);
  Future<Module?> getModuleById(int moduleId);
  Future<List<Question>> getOriginalQuestionsForModule(int moduleId);
  Future<void> forceRegenerateQuestions(int moduleId);
  Future<void> importSubjectFromJson(String jsonString, {int? repositoryId});
  Future<void> deleteSubject(int subjectId);
  Future<void> updateSubjectFromJson(int subjectId, String jsonString);
  Future<void> checkForUpdates();
  Future<void> deleteTestAttempt(int attemptId);
}

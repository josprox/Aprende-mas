import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aprende_mas/services/database/app_database.dart';
import 'package:aprende_mas/services/api/groq_api_service.dart';
import 'package:aprende_mas/repositories/study_repository.dart';
import 'package:aprende_mas/repositories/i_study_repository.dart';

// Database Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// DAO Provider
final studyDaoProvider = Provider<StudyDao>((ref) {
  final db = ref.watch(databaseProvider);
  return StudyDao(db);
});

// API Service Provider
final groqApiServiceProvider = Provider<GroqApiService>((ref) {
  return GroqApiService();
});

// Repository Provider
final studyRepositoryProvider = Provider<IStudyRepository>((ref) {
  final dao = ref.watch(studyDaoProvider);
  final api = ref.watch(groqApiServiceProvider);
  return StudyRepository(dao, api);
});

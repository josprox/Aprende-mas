import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aprende_mas/repositories/i_study_repository.dart';
import 'package:aprende_mas/repositories/study_repository.dart';
import 'package:aprende_mas/services/api/groq_api_service.dart';
import 'package:aprende_mas/services/api/repository_api_service.dart';

// API Service Provider
final groqApiServiceProvider = Provider<GroqApiService>((ref) {
  return GroqApiService();
});

final repositoryApiServiceProvider = Provider<RepositoryApiService>((ref) {
  return RepositoryApiService();
});

// Repository Provider
final studyRepositoryProvider = Provider<IStudyRepository>((ref) {
  final groqApi = ref.watch(groqApiServiceProvider);
  final repoApi = ref.watch(repositoryApiServiceProvider);
  return StudyRepository(groqApi, repoApi);
});

import 'dart:async';
import 'dart:convert';
import 'package:aprende_mas/models/repository_models.dart';
import 'package:aprende_mas/models/subject_models.dart';
import 'package:aprende_mas/repositories/i_study_repository.dart';

import 'package:aprende_mas/services/api/repository_api_service.dart';
import 'package:aprende_mas/viewmodels/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RepositoryStatus { notInstalled, installed, updateAvailable }

// State for the repository list
class RepositoryState {
  final List<RepositoryItem> items;
  final bool isLoading;
  final bool isError;
  final int currentPage;
  final int lastPage;
  final Map<int, RepositoryStatus> itemStatuses;
  // We keep a reference to installed subjects to re-calculate statuses easily
  final List<Subject> installedSubjects;

  const RepositoryState({
    this.items = const [],
    this.isLoading = false,
    this.isError = false,
    this.currentPage = 1,
    this.lastPage = 1,
    this.itemStatuses = const {},
    this.installedSubjects = const [],
  });

  RepositoryState copyWith({
    List<RepositoryItem>? items,
    bool? isLoading,
    bool? isError,
    int? currentPage,
    int? lastPage,
    Map<int, RepositoryStatus>? itemStatuses,
    List<Subject>? installedSubjects,
  }) {
    return RepositoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      itemStatuses: itemStatuses ?? this.itemStatuses,
      installedSubjects: installedSubjects ?? this.installedSubjects,
    );
  }
}

class RepositoryStoreViewModel extends StateNotifier<RepositoryState> {
  final RepositoryApiService _apiService;
  final IStudyRepository _studyRepository;
  StreamSubscription? _subjectsSubscription;

  RepositoryStoreViewModel(this._apiService, this._studyRepository)
    : super(const RepositoryState()) {
    _init();
  }

  void _init() {
    _subjectsSubscription = _studyRepository.getAllSubjects().listen((
      subjects,
    ) {
      if (!mounted) return;
      state = state.copyWith(installedSubjects: subjects);
      _updateStatuses();
    });
  }

  @override
  void dispose() {
    _subjectsSubscription?.cancel();
    super.dispose();
  }

  void _updateStatuses() {
    final Map<int, RepositoryStatus> newStatuses = {};
    for (final item in state.items) {
      RepositoryStatus status = RepositoryStatus.notInstalled;
      try {
        final installed = state.installedSubjects.firstWhere(
          (s) => s.repositoryId == item.id,
        );

        // Check for version update
        // Simple string compare, usually semantic versioning needs more robust check
        // but let's assume simple lexicographical or equality for now as per previous logic
        if (_isNewerVersion(installed.version, item.version)) {
          status = RepositoryStatus.updateAvailable;
        } else {
          status = RepositoryStatus.installed;
        }
      } catch (e) {
        // Not found
        status = RepositoryStatus.notInstalled;
      }
      newStatuses[item.id] = status;
    }
    state = state.copyWith(itemStatuses: newStatuses);
  }

  bool _isNewerVersion(String local, String remote) {
    // Naive check: 1.1 > 1.0 (lexicographical works for simple cases, but 1.10 < 1.2 lexicographically)
    // Better to split by '.'
    // Using the same logic as StudyRepository for consistency
    return remote.compareTo(local) > 0;
  }

  Future<void> fetchRepositories({int page = 1}) async {
    if (page == 1) {
      state = state.copyWith(isLoading: true, isError: false, items: []);
    } else {
      state = state.copyWith(isLoading: true, isError: false);
    }

    try {
      final response = await _apiService.getRepositories(page: page);

      List<RepositoryItem> currentItems = page == 1 ? [] : state.items;

      state = state.copyWith(
        isLoading: false,
        items: [...currentItems, ...response.data],
        currentPage: response.meta.currentPage,
        lastPage: response.meta.lastPage,
      );
      _updateStatuses();
    } catch (e) {
      print("Error fetching repositories: $e");
      state = state.copyWith(isLoading: false, isError: true);
    }
  }

  Future<void> installOrUpdateRepository(int repositoryId) async {
    try {
      final status = state.itemStatuses[repositoryId];
      final data = await _apiService.downloadRepository(repositoryId);
      final jsonString = jsonEncode(data);

      if (status == RepositoryStatus.updateAvailable) {
        // Find local subject ID
        final subject = state.installedSubjects.firstWhere(
          (s) => s.repositoryId == repositoryId,
        );
        await _studyRepository.updateSubjectFromJson(subject.id!, jsonString);
      } else {
        await _studyRepository.importSubjectFromJson(
          jsonString,
          repositoryId: repositoryId,
        );
      }
    } catch (e) {
      print("Error installing/updating repository: $e");
      rethrow;
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoading) return;
    if (state.currentPage >= state.lastPage) return;

    await fetchRepositories(page: state.currentPage + 1);
  }
}

final repositoryStoreViewModelProvider =
    StateNotifierProvider<RepositoryStoreViewModel, RepositoryState>((ref) {
      final api = ref.watch(repositoryApiServiceProvider);
      final repo = ref.watch(studyRepositoryProvider);
      return RepositoryStoreViewModel(api, repo);
    });

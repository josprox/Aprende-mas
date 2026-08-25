import 'dart:async';
import 'dart:convert';
import 'package:aprende_mas/models/repository_models.dart';
import 'package:aprende_mas/models/subject_models.dart';
import 'package:aprende_mas/repositories/i_study_repository.dart';

import 'package:aprende_mas/services/api/repository_api_service.dart';
import 'package:aprende_mas/services/store_source_service.dart';
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
  final Map<String, RepositoryStatus> itemStatuses;
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
    Map<String, RepositoryStatus>? itemStatuses,
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
    final Map<String, RepositoryStatus> newStatuses = {};
    for (final item in state.items) {
      RepositoryStatus status = RepositoryStatus.notInstalled;
      try {
        final installed = state.installedSubjects.firstWhere(
          (s) =>
              s.repositoryId == item.id &&
              s.repositorySource ==
                  (item.sourceUrl.isEmpty ? 'joss-red' : item.sourceUrl),
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
      newStatuses[item.storeKey] = status;
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

    final externalItems = <RepositoryItem>[];
    if (page == 1) {
      for (final source in await StoreSourceService.load()) {
        try {
          final external = await _apiService.getRepositories(
            sourceUrl: source.url,
            sourceName: source.name,
          );
          externalItems.addAll(external.data);
        } catch (_) {}
      }
    }
    RepositoryListResponse? jossResponse;
    try {
      jossResponse = await _apiService.getRepositories(page: page);
    } catch (_) {}
    final currentItems = page == 1 ? <RepositoryItem>[] : state.items;
    final items = [...currentItems, ...?jossResponse?.data, ...externalItems];
    state = state.copyWith(
      isLoading: false,
      isError: items.isEmpty && jossResponse == null,
      items: items,
      currentPage: jossResponse?.meta.currentPage ?? 1,
      lastPage: jossResponse?.meta.lastPage ?? 1,
    );
    _updateStatuses();
  }

  Future<void> installOrUpdateRepository(RepositoryItem item) async {
    try {
      final status = state.itemStatuses[item.storeKey];
      final data = await _apiService.downloadRepository(
        item.id,
        sourceUrl: item.sourceUrl,
      );
      final jsonString = jsonEncode(data);

      if (status == RepositoryStatus.updateAvailable) {
        // Find local subject ID
        final subject = state.installedSubjects.firstWhere(
          (s) =>
              s.repositoryId == item.id &&
              s.repositorySource ==
                  (item.sourceUrl.isEmpty ? 'joss-red' : item.sourceUrl),
        );
        await _studyRepository.updateSubjectFromJson(subject.id!, jsonString);
      } else {
        await _studyRepository.importSubjectFromJson(
          jsonString,
          repositoryId: item.id,
          repositorySource: item.sourceUrl.isEmpty
              ? 'joss-red'
              : item.sourceUrl,
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

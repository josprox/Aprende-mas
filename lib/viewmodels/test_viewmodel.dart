import 'dart:async';

import 'package:aprende_mas/repositories/i_study_repository.dart';
import 'package:aprende_mas/models/subject_models.dart';
import 'package:aprende_mas/viewmodels/providers.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class TestUiState {
  final List<TestAttemptWithModule> pendingTests;
  final List<TestAttemptWithModule> completedTests;

  const TestUiState({
    this.pendingTests = const [],
    this.completedTests = const [],
  });

  TestUiState copyWith({
    List<TestAttemptWithModule>? pendingTests,
    List<TestAttemptWithModule>? completedTests,
  }) {
    return TestUiState(
      pendingTests: pendingTests ?? this.pendingTests,
      completedTests: completedTests ?? this.completedTests,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestUiState &&
        other.pendingTests == pendingTests &&
        other.completedTests == completedTests;
  }

  @override
  int get hashCode => Object.hash(pendingTests, completedTests);
}

final testViewModelProvider =
    StateNotifierProvider.autoDispose<TestViewModel, AsyncValue<TestUiState>>((
      ref,
    ) {
      return TestViewModel(ref.watch(studyRepositoryProvider));
    });

class TestViewModel extends StateNotifier<AsyncValue<TestUiState>> {
  final IStudyRepository _repository;
  StreamSubscription? _pendingSubscription;
  StreamSubscription? _completedSubscription;

  List<TestAttemptWithModule> _lastPending = [];
  List<TestAttemptWithModule> _lastCompleted = [];
  bool _pendingLoaded = false;
  bool _completedLoaded = false;

  TestViewModel(this._repository) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    // Listen to streams independently to handle updates from either source
    final pendingStream = _repository.getPendingTests();
    final completedStream = _repository.getCompletedTests();

    void updateState() {
      if (_pendingLoaded && _completedLoaded) {
        state = AsyncValue.data(
          TestUiState(pendingTests: _lastPending, completedTests: _lastCompleted),
        );
      }
    }

    _pendingSubscription = pendingStream.listen(
      (results) {
        _lastPending = results;
        _pendingLoaded = true;
        updateState();
      },
      onError: (err, stack) {
        state = AsyncValue.error(err, stack);
      },
    );

    _completedSubscription = completedStream.listen(
      (results) {
        _lastCompleted = results;
        _completedLoaded = true;
        updateState();
      },
      onError: (err, stack) {
        state = AsyncValue.error(err, stack);
      },
    );
  }

  Future<void> deleteTestAttempt(int attemptId) async {
    // 1. Optimistic update: immediately remove from current state
    _lastPending = _lastPending.where((t) => t.attempt.id != attemptId).toList();
    _lastCompleted = _lastCompleted.where((t) => t.attempt.id != attemptId).toList();
    state = AsyncValue.data(
      TestUiState(pendingTests: _lastPending, completedTests: _lastCompleted),
    );

    try {
      await _repository.deleteTestAttempt(attemptId);
    } catch (e) {
      print("Error deleting test attempt: $e");
    }
  }

  @override
  void dispose() {
    _pendingSubscription?.cancel();
    _completedSubscription?.cancel();
    super.dispose();
  }
}

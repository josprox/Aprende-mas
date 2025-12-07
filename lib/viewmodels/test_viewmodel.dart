import 'dart:async';

import 'package:aprende_mas/repositories/i_study_repository.dart';
import 'package:aprende_mas/models/subject_models.dart';
import 'package:aprende_mas/viewmodels/providers.dart';
import 'package:async/async.dart';
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

  TestViewModel(this._repository) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    // Combine streams manually to update state
    // We listen to both streams and merge the latest values
    final pendingStream = _repository.getPendingTests();
    final completedStream = _repository.getCompletedTests();

    StreamZip([pendingStream, completedStream]).listen(
      (results) {
        if (!mounted) return;
        state = AsyncValue.data(
          TestUiState(pendingTests: results[0], completedTests: results[1]),
        );
      },
      onError: (err, stack) {
        if (!mounted) return;
        state = AsyncValue.error(err, stack);
      },
    );
  }

  Future<void> deleteTestAttempt(int attemptId) async {
    try {
      await _repository.deleteTestAttempt(attemptId);
      // Stream will automatically update the UI
    } catch (e) {
      // Handle error gracefully, maybe show a snackbar in UI via a different provider/listener
      // For now, we just log/rethrow or set error state if critical,
      // but deleting a single item failure shouldn't crash the whole list state usually.
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

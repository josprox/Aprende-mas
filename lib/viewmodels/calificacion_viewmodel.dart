import 'package:aprende_mas/models/subject_models.dart';
import 'package:aprende_mas/viewmodels/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalificacionUiState {
  final List<TestAttemptWithModule> completedTests;

  const CalificacionUiState({this.completedTests = const []});

  CalificacionUiState copyWith({List<TestAttemptWithModule>? completedTests}) {
    return CalificacionUiState(
      completedTests: completedTests ?? this.completedTests,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalificacionUiState &&
        other.completedTests == completedTests;
  }

  @override
  int get hashCode => completedTests.hashCode;
}

final calificacionViewModelProvider = StreamProvider<CalificacionUiState>((
  ref,
) {
  final repository = ref.watch(studyRepositoryProvider);
  return repository.getCompletedTests().map(
    (tests) => CalificacionUiState(completedTests: tests),
  );
});

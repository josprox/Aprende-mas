import 'dart:async';

import 'dart:io';
import 'package:aprende_mas/models/subject_models.dart';
import 'package:aprende_mas/viewmodels/providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FileAction { import, update }

class SubjectUiState {
  final List<Subject> subjects;
  final Subject? selectedSubject;
  final FileAction currentFileAction;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const SubjectUiState({
    this.subjects = const [],
    this.selectedSubject,
    this.currentFileAction = FileAction.import,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  SubjectUiState copyWith({
    List<Subject>? subjects,
    Subject? selectedSubject,
    FileAction? currentFileAction,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return SubjectUiState(
      subjects: subjects ?? this.subjects,
      selectedSubject: selectedSubject ?? this.selectedSubject,
      currentFileAction: currentFileAction ?? this.currentFileAction,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

class SubjectNotifier extends StateNotifier<SubjectUiState> {
  final Ref ref;
  StreamSubscription? _subscription;

  SubjectNotifier(this.ref) : super(const SubjectUiState()) {
    _init();
  }

  void _init() {
    final repository = ref.read(studyRepositoryProvider);
    _subscription = repository.getAllSubjects().listen((subjects) {
      if (mounted) {
        state = state.copyWith(subjects: subjects);
      }
    });

    // Check for updates in background
    Future.microtask(() => repository.checkForUpdates());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void onSubjectLongPress(Subject subject) {
    state = state.copyWith(selectedSubject: subject);
  }

  void onDismissOptionsDialog() {
    state = state.copyWith(selectedSubject: null);
  }

  Future<void> onConfirmDelete() async {
    final subject = state.selectedSubject;
    if (subject != null) {
      try {
        final repository = ref.read(studyRepositoryProvider);
        await repository.deleteSubject(subject.id!);
        state = state.copyWith(successMessage: "${subject.name} eliminado");
      } catch (e) {
        state = state.copyWith(errorMessage: "Error al eliminar la materia");
      } finally {
        onDismissOptionsDialog();
      }
    }
  }

  void prepareForFileAction(FileAction action) {
    state = state.copyWith(currentFileAction: action);
    if (action == FileAction.import) {
      state = state.copyWith(selectedSubject: null);
    }
  }

  Future<void> pickAndProcessFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final File file = File(result.files.single.path!);
        final String jsonString = await file.readAsString();

        if (state.currentFileAction == FileAction.import) {
          await _importMateria(jsonString);
        } else {
          await _updateMateria(jsonString);
        }
      }
    } catch (e) {
      state = state.copyWith(errorMessage: "Error al leer el archivo: $e");
    }
  }

  Future<void> _importMateria(String jsonString) async {
    try {
      final repository = ref.read(studyRepositoryProvider);
      await repository.importSubjectFromJson(jsonString);
      state = state.copyWith(successMessage: "¡Materia importada con éxito!");
    } catch (e) {
      state = state.copyWith(errorMessage: "Error al importar: $e");
    }
  }

  Future<void> _updateMateria(String jsonString) async {
    final subject = state.selectedSubject;
    if (subject == null) {
      state = state.copyWith(
        errorMessage: "Error: No se seleccionó ninguna materia",
      );
      return;
    }

    try {
      final repository = ref.read(studyRepositoryProvider);
      await repository.updateSubjectFromJson(subject.id!, jsonString);
      state = state.copyWith(successMessage: "¡Materia actualizada con éxito!");
    } catch (e) {
      state = state.copyWith(errorMessage: "Error al actualizar: $e");
    } finally {
      state = state.copyWith(selectedSubject: null);
    }
  }

  void clearMessages() {
    state = SubjectUiState(
      subjects: state.subjects,
      selectedSubject: state.selectedSubject,
      currentFileAction: state.currentFileAction,
      isLoading: state.isLoading,
      errorMessage: null,
      successMessage: null,
    );
  }
}

final subjectNotifierProvider =
    StateNotifierProvider<SubjectNotifier, SubjectUiState>((ref) {
      return SubjectNotifier(ref);
    });

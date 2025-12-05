import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class BackupUiState {
  final bool isLoading;
  final bool isError;
  final String? message;

  BackupUiState({this.isLoading = false, this.isError = false, this.message});

  BackupUiState copyWith({bool? isLoading, bool? isError, String? message}) {
    return BackupUiState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      message: message,
    );
  }
}

class BackupViewModel extends StateNotifier<BackupUiState> {
  final Ref ref;

  BackupViewModel(this.ref) : super(BackupUiState());

  void clearMessage() {
    state = state.copyWith(message: null);
  }

  Future<void> createBackup() async {
    state = state.copyWith(
      isLoading: true,
      message: "Creando copia de seguridad...",
    );
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(
        p.join(dbFolder.path, 'db.sqlite'),
      ); // Assuming Drift uses this name by default or configured

      if (!await file.exists()) {
        throw Exception("Base de datos no encontrada");
      }

      // Use FilePicker to save
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar copia de seguridad',
        fileName: 'backup_AprendeMas.db',
      );

      if (outputFile != null) {
        await file.copy(outputFile);
        state = state.copyWith(
          isLoading: false,
          message: "Backup guardado exitosamente",
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          message: "Operación cancelada",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        message: "Error al crear backup: $e",
      );
    }
  }

  Future<void> restoreBackup() async {
    state = state.copyWith(isLoading: true, message: "Restaurando datos...");
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        final path = result.files.single.path;
        if (path != null) {
          final dbFolder = await getApplicationDocumentsDirectory();
          final file = File(p.join(dbFolder.path, 'db.sqlite'));

          await File(path).copy(file.path);

          // Trigger a database reload or ask user to restart
          state = state.copyWith(
            isLoading: false,
            message:
                "Restauración completada. Por favor reinicia la aplicación.",
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          message: "Operación cancelada",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        message: "Error al restaurar: $e",
      );
    }
  }
}

final backupViewModelProvider =
    StateNotifierProvider<BackupViewModel, BackupUiState>((ref) {
      return BackupViewModel(ref);
    });

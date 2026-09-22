import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:joss/joss.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CodeExecutionResult {
  final String language;
  final String version;
  final String stdout;
  final String stderr;
  final String? compileOutput;
  final int exitCode;
  final bool isSuccess;
  final String? errorMessage;
  final Duration executionTime;

  const CodeExecutionResult({
    required this.language,
    required this.version,
    required this.stdout,
    required this.stderr,
    this.compileOutput,
    required this.exitCode,
    required this.isSuccess,
    this.errorMessage,
    required this.executionTime,
  });

  factory CodeExecutionResult.error(String message, {String language = 'text'}) {
    return CodeExecutionResult(
      language: language,
      version: '',
      stdout: '',
      stderr: message,
      exitCode: -1,
      isSuccess: false,
      errorMessage: message,
      executionTime: Duration.zero,
    );
  }
}

class CodeExecutionService {
  final Dio _dio;

  CodeExecutionService([Dio? dio])
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: dotenv.env['PISTON_URL'] ?? 'https://emkc.org/api/v2/piston',
                connectTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  static const Map<String, String> _languageAliases = {
    'dart': 'dart',
    'java': 'java',
    'php': 'php',
    'python': 'python',
    'python3': 'python',
    'py': 'python',
    'c': 'c',
    'cpp': 'c++',
    'c++': 'c++',
    'javascript': 'javascript',
    'js': 'javascript',
    'typescript': 'typescript',
    'ts': 'typescript',
    'csharp': 'csharp',
    'c#': 'csharp',
    'cs': 'csharp',
    'go': 'go',
    'rust': 'rust',
    'rs': 'rust',
    'ruby': 'ruby',
    'rb': 'ruby',
    'kotlin': 'kotlin',
    'kt': 'kotlin',
    'bash': 'bash',
    'sh': 'bash',
    'sqlite': 'sqlite3',
    'sql': 'sqlite3',
    'joss': 'joss',
  };

  static const Map<String, String> _fileNames = {
    'dart': 'main.dart',
    'java': 'Main.java',
    'php': 'main.php',
    'python': 'main.py',
    'c': 'main.c',
    'c++': 'main.cpp',
    'javascript': 'main.js',
    'typescript': 'main.ts',
    'csharp': 'Main.cs',
    'go': 'main.go',
    'rust': 'main.rs',
    'ruby': 'main.rb',
    'kotlin': 'Main.kt',
    'bash': 'main.sh',
    'sqlite3': 'main.sql',
    'joss': 'main.joss',
  };

  String normalizeLanguage(String lang) {
    final lower = lang.toLowerCase().trim();
    return _languageAliases[lower] ?? lower;
  }

  String getFileNameForLanguage(String normalizedLang) {
    return _fileNames[normalizedLang] ?? 'main.txt';
  }

  /// Prepara el código para ejecución (por ejemplo, asegurando clase Main en Java si falta)
  String prepareCode(String code, String normalizedLang) {
    if (normalizedLang == 'java') {
      final hasClass = RegExp(r'\bclass\s+\w+').hasMatch(code);
      if (!hasClass) {
        return '''
public class Main {
    public static void main(String[] args) {
$code
    }
}
''';
      } else if (!code.contains('class Main') && !code.contains('public class Main')) {
        return code.replaceFirst(RegExp(r'public\s+class\s+\w+'), 'public class Main');
      }
    } else if (normalizedLang == 'php') {
      if (!code.trim().startsWith('<?php')) {
        return '<?php\n$code';
      }
    } else if (normalizedLang == 'c' || normalizedLang == 'c++') {
      final hasMain = RegExp(r'\bint\s+main\s*\(').hasMatch(code) || RegExp(r'\bvoid\s+main\s*\(').hasMatch(code);
      if (!hasMain) {
        final headers = normalizedLang == 'c++' ? '#include <iostream>\nusing namespace std;\n' : '#include <stdio.h>\n';
        return '''
$headers
int main() {
$code
    return 0;
}
''';
      }
    } else if (normalizedLang == 'dart') {
      final hasMain = RegExp(r'\bvoid\s+main\s*\(').hasMatch(code) || RegExp(r'\bmain\s*\(').hasMatch(code);
      if (!hasMain) {
        return '''
void main() {
$code
}
''';
      }
    }
    return code;
  }

  // Cache de la última versión de Joss descubierta en GitHub
  static String? _cachedLatestJossVersion;

  /// Consulta GitHub API para obtener la última versión estable de Joss.
  /// Cachea el resultado para no repetir la petición en la misma sesión.
  Future<String> _fetchLatestJossVersion() async {
    if (_cachedLatestJossVersion != null) return _cachedLatestJossVersion!;
    try {
      final response = await _dio.get(
        'https://api.github.com/repos/joss-language/Joss-Programming-Language/releases/latest',
        options: Options(
          headers: {'User-Agent': 'aprende-mas-app/1.0'},
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );
      final tag = (response.data as Map<String, dynamic>)['tag_name'] as String?;
      if (tag != null && tag.isNotEmpty) {
        // quitar la 'v' inicial si viene así: "v3.6.7.5" → "3.6.7.5"
        _cachedLatestJossVersion = tag.replaceFirst(RegExp(r'^v', caseSensitive: false), '');
        return _cachedLatestJossVersion!;
      }
    } catch (_) {}
    // Fallback a la última versión conocida con soporte Android
    return '3.6.7.5';
  }

  Future<String?> _findAndroidNativeJoss() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final packageName = info.packageName;

      for (final path in [
        '/data/data/$packageName/lib/libjoss.so',
        '/data/user/0/$packageName/lib/libjoss.so',
      ]) {
        final f = File(path);
        if (f.existsSync()) return f.path;
      }

      // Buscar en directorio de librerías nativas de la aplicación
      final libDir = Directory('/data/data/$packageName/lib');
      if (libDir.existsSync()) {
        final jossLib = File(p.join(libDir.path, 'libjoss.so'));
        if (jossLib.existsSync()) return jossLib.path;
      }
    } catch (_) {}
    return null;
  }

  Future<Directory?> _getJossTargetDir() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final dir = await getApplicationSupportDirectory();
        return Directory(p.join(dir.path, 'joss_bin'));
      }
    } catch (_) {}
    return null;
  }

  Future<CodeExecutionResult> executeCode({
    required String language,
    required String code,
    String stdin = '',
  }) async {
    final normalizedLang = normalizeLanguage(language);
    final fileName = getFileNameForLanguage(normalizedLang);
    final processedCode = prepareCode(code, normalizedLang);

    final stopwatch = Stopwatch()..start();

    if (normalizedLang == 'joss') {
      try {
        final targetDir = await _getJossTargetDir();
        String? executablePath;

        // 1. En Android, la vía oficial y permitida por SELinux (sin W^X error)
        // es el binario empaquetado como biblioteca nativa (.so)
        if (Platform.isAndroid) {
          executablePath = await _findAndroidNativeJoss();
          if (executablePath != null) {
            Joss.setBinaryPath(executablePath);
          }
        }

        // 2. Si no se encontró empaquetado nativamente, usar descarga dinámica
        String jossVersion = '3.6.7.5';
        if (executablePath == null) {
          jossVersion = await _fetchLatestJossVersion();
          await Joss.ensureInstalled(
            targetVersion: jossVersion,
            targetDir: targetDir,
          );

          if (targetDir != null &&
              (Platform.isAndroid || Platform.isIOS || Platform.isLinux || Platform.isMacOS)) {
            final exeName = Platform.isWindows ? 'joss.exe' : 'joss';
            final jossExe = File(p.join(targetDir.path, exeName));
            if (jossExe.existsSync()) {
              for (final chmodCmd in ['/system/bin/chmod', '/bin/chmod', 'chmod']) {
                try {
                  final r = await Process.run(chmodCmd, ['755', jossExe.path]);
                  if (r.exitCode == 0) break;
                } catch (_) {}
              }
              Joss.setBinaryPath(jossExe.path);
              executablePath = jossExe.path;
            }
          }
        }

        final result = await Joss.run(
          processedCode,
          timeoutMs: 15000,
          targetDir: targetDir,
          customBinaryPath: executablePath,
        );
        stopwatch.stop();

        return CodeExecutionResult(
          language: 'joss',
          version: jossVersion,
          stdout: result.stdout,
          stderr: result.stderr,
          exitCode: result.isSuccess ? 0 : 1,
          isSuccess: result.isSuccess,
          errorMessage: result.error,
          executionTime: Duration(milliseconds: result.durationMs),
        );
      } catch (e) {
        stopwatch.stop();
        return CodeExecutionResult.error('Error al ejecutar Joss: $e', language: 'joss');
      }
    }



    try {
      final response = await _dio.post(
        '/execute',
        data: {
          'language': normalizedLang,
          'version': '*',
          'files': [
            {
              'name': fileName,
              'content': processedCode,
            }
          ],
          'stdin': stdin,
          'compile_timeout': 10000,
          'run_timeout': 10000,
        },
      );

      stopwatch.stop();

      final data = response.data as Map<String, dynamic>;
      final run = (data['run'] as Map<String, dynamic>?) ?? {};
      final compile = data['compile'] as Map<String, dynamic>?;

      final stdout = (run['stdout']?.toString() ?? '').trimRight();
      final stderr = (run['stderr']?.toString() ?? '').trimRight();
      final compileStderr = compile != null ? (compile['stderr']?.toString() ?? '').trimRight() : null;
      final compileOutput = compile != null ? (compile['output']?.toString() ?? '').trimRight() : null;
      final compileCode = (compile?['code'] as num?)?.toInt();
      final exitCode = (run['code'] as num?)?.toInt() ?? (compileCode != null && compileCode != 0 ? compileCode : 0);

      final isSuccess = exitCode == 0 && (compileStderr == null || compileStderr.isEmpty);

      return CodeExecutionResult(
        language: data['language']?.toString() ?? normalizedLang,
        version: data['version']?.toString() ?? '',
        stdout: stdout,
        stderr: stderr.isNotEmpty ? stderr : (compileStderr ?? ''),
        compileOutput: compileOutput,
        exitCode: exitCode,
        isSuccess: isSuccess,
        executionTime: stopwatch.elapsed,
      );
    } on DioException catch (e) {
      stopwatch.stop();
      String message = 'Error de conexión con el servidor de ejecución.';
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        message = 'Tiempo de espera agotado al compilar/ejecutar el código.';
      } else if (e.response != null) {
        final respData = e.response?.data;
        if (respData is Map && respData['message'] != null) {
          message = respData['message'].toString();
        } else {
          message = 'Error del servidor (${e.response?.statusCode}).';
        }
      }
      return CodeExecutionResult.error(message, language: normalizedLang);
    } catch (e) {
      stopwatch.stop();
      return CodeExecutionResult.error('Excepción al ejecutar: $e', language: normalizedLang);
    }
  }
}

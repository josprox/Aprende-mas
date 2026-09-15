import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aprende_mas/services/api/code_execution_service.dart';

class CodeRunnerScreen extends StatefulWidget {
  final String initialLanguage;
  final String initialCode;
  final String? title;

  const CodeRunnerScreen({
    super.key,
    this.initialLanguage = 'dart',
    this.initialCode = '',
    this.title,
  });

  static Future<void> open(
    BuildContext context, {
    String language = 'dart',
    String code = '',
    String? title,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CodeRunnerScreen(
          initialLanguage: language,
          initialCode: code,
          title: title,
        ),
      ),
    );
  }

  @override
  State<CodeRunnerScreen> createState() => _CodeRunnerScreenState();
}

class _CodeRunnerScreenState extends State<CodeRunnerScreen> {
  final CodeExecutionService _executionService = CodeExecutionService();
  late final TextEditingController _codeController;
  final TextEditingController _stdinController = TextEditingController();

  late String _selectedLanguage;
  bool _isRunning = false;
  CodeExecutionResult? _result;
  bool _showStdin = false;

  final List<Map<String, String>> _availableLanguages = [
    {'id': 'joss', 'label': 'Joss'},
    {'id': 'dart', 'label': 'Dart'},
    {'id': 'java', 'label': 'Java'},
    {'id': 'php', 'label': 'PHP'},
    {'id': 'python', 'label': 'Python 3'},
    {'id': 'c', 'label': 'C (GCC)'},
    {'id': 'cpp', 'label': 'C++ (G++)'},
    {'id': 'javascript', 'label': 'JavaScript (Node)'},
    {'id': 'typescript', 'label': 'TypeScript'},
    {'id': 'csharp', 'label': 'C# (Mono)'},
    {'id': 'go', 'label': 'Go'},
    {'id': 'rust', 'label': 'Rust'},
    {'id': 'sqlite3', 'label': 'SQL (SQLite)'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _executionService.normalizeLanguage(widget.initialLanguage);
    if (!_availableLanguages.any((lang) => lang['id'] == _selectedLanguage)) {
      _selectedLanguage = 'dart';
    }

    String code = widget.initialCode.trim();
    if (code.isEmpty) {
      code = _getDefaultSnippetForLanguage(_selectedLanguage);
    }
    _codeController = TextEditingController(text: code);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _stdinController.dispose();
    super.dispose();
  }

  String _getDefaultSnippetForLanguage(String lang) {
    switch (lang) {
      case 'joss':
        return 'echo "¡Hola desde Joss en Aprende Más!\\n";\nint \$a = 15;\nint \$b = 27;\nint \$suma = \$a + \$b;\necho "Suma: " . \$suma . "\\n";\nfor (int \$i = 1; \$i <= 3; \$i++) {\n    echo "Iteración Joss: " . \$i . "\\n";\n}';
      case 'dart':
        return 'void main() {\n  print("¡Hola desde Aprende Más con Dart!");\n  for (int i = 1; i <= 3; i++) {\n    print("Iteración: \$i");\n  }\n}';
      case 'java':
        return 'public class Main {\n    public static void main(String[] args) {\n        System.out.println("¡Hola desde Java!");\n        int a = 10, b = 20;\n        System.out.println("Suma: " + (a + b));\n    }\n}';
      case 'php':
        return '<?php\necho "¡Hola desde PHP en Aprende Más!\\n";\n\$datos = ["Algoritmos", "Estructuras", "Calidad"];\nforeach (\$datos as \$item) {\n    echo "- " . \$item . "\\n";\n}';
      case 'python':
        return 'print("¡Hola desde Python 3!")\nvalores = [1, 2, 3, 4, 5]\ncuadrados = [x**2 for x in valores]\nprint(f"Cuadrados: {cuadrados}")';
      case 'c':
        return '#include <stdio.h>\n\nint main() {\n    printf("¡Hola desde C!\\n");\n    return 0;\n}';
      case 'cpp':
        return '#include <iostream>\nusing namespace std;\n\nint main() {\n    cout << "¡Hola desde C++ moderno!" << endl;\n    return 0;\n}';
      case 'javascript':
        return 'console.log("¡Hola desde JavaScript!");\nconst egel = { materia: "Ingeniería de Software", reactivos: 283 };\nconsole.log(JSON.stringify(egel, null, 2));';
      case 'sqlite3':
        return 'CREATE TABLE materias (id INTEGER PRIMARY KEY, nombre TEXT);\nINSERT INTO materias (nombre) VALUES ("Requisitos"), ("Arquitectura"), ("Pruebas");\nSELECT * FROM materias;';
      default:
        return '// Escribe tu código aquí\n';
    }
  }

  Future<void> _runCode() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _result = null;
    });

    FocusScope.of(context).unfocus();

    final result = await _executionService.executeCode(
      language: _selectedLanguage,
      code: _codeController.text,
      stdin: _stdinController.text,
    );

    if (mounted) {
      setState(() {
        _isRunning = false;
        _result = result;
      });
    }
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Probador de Código'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_rounded),
            tooltip: 'Restablecer código original',
            onPressed: () {
              setState(() {
                _codeController.text = widget.initialCode.isNotEmpty
                    ? widget.initialCode
                    : _getDefaultSnippetForLanguage(_selectedLanguage);
                _result = null;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copiar código',
            onPressed: () => _copyToClipboard(_codeController.text, 'Código copiado al portapapeles'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de selección de lenguaje y botón de ejecución
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLanguage,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        items: _availableLanguages.map((item) {
                          return DropdownMenuItem<String>(
                            value: item['id'],
                            child: Row(
                              children: [
                                const Icon(Icons.code_rounded, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  item['label']!,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: _isRunning
                            ? null
                            : (val) {
                                if (val != null && val != _selectedLanguage) {
                                  setState(() {
                                    _selectedLanguage = val;
                                    if (widget.initialCode.isEmpty) {
                                      _codeController.text = _getDefaultSnippetForLanguage(val);
                                    }
                                  });
                                }
                              },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _isRunning ? null : _runCode,
                  icon: _isRunning
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                  label: Text(_isRunning ? 'Ejecutando...' : 'Ejecutar'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),

          // Editor de Código
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                Container(
                  color: const Color(0xFF1E1E2E), // Fondo estilo Catppuccin / VSCode Dark
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  width: double.infinity,
                  height: double.infinity,
                  child: TextField(
                    controller: _codeController,
                    maxLines: null,
                    expands: true,
                    style: GoogleFonts.firaCode(
                      fontSize: 13.5,
                      color: const Color(0xFFCDD6F4),
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      _showStdin ? Icons.input_rounded : Icons.input_outlined,
                      color: _showStdin ? scheme.primary : Colors.white54,
                      size: 20,
                    ),
                    tooltip: 'Entrada estándar (stdin)',
                    onPressed: () => setState(() => _showStdin = !_showStdin),
                  ),
                ),
              ],
            ),
          ),

          // Campo opcional de Entrada estándar (stdin)
          if (_showStdin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: scheme.surfaceContainerHighest,
              child: Row(
                children: [
                  const Text('stdin: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Expanded(
                    child: TextField(
                      controller: _stdinController,
                      style: GoogleFonts.firaCode(fontSize: 12),
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Valores separados por saltos de línea...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Divisor con título de consola
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: scheme.surfaceContainerLow,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.terminal_rounded, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'CONSOLA DE SALIDA',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    ),
                    if (_result != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _result!.isSuccess ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _result!.isSuccess
                              ? 'Éxito (${_result!.executionTime.inMilliseconds} ms)'
                              : 'Código de salida ${_result!.exitCode}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _result!.isSuccess ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (_result != null && (_result!.stdout.isNotEmpty || _result!.stderr.isNotEmpty))
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    tooltip: 'Copiar salida',
                    onPressed: () {
                      final out = _result!.stdout.isNotEmpty ? _result!.stdout : _result!.stderr;
                      _copyToClipboard(out, 'Salida copiada');
                    },
                  ),
              ],
            ),
          ),

          // Consola Terminal de Salida
          Expanded(
            flex: 4,
            child: Container(
              color: const Color(0xFF181825), // Fondo terminal oscuro
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              child: SingleChildScrollView(
                child: _isRunning
                    ? const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Colors.lightGreenAccent),
                              SizedBox(height: 12),
                              Text(
                                'Compilando y ejecutando en servidor seguro...',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _result == null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Presiona "Ejecutar" para compilar y correr el código.',
                                style: GoogleFonts.firaCode(color: Colors.white38, fontSize: 12),
                              ),
                            ),
                          )
                        : SelectableText.rich(
                            TextSpan(
                              children: [
                                if (_result!.compileOutput != null && _result!.compileOutput!.isNotEmpty)
                                  TextSpan(
                                    text: '[Compilador]\n${_result!.compileOutput}\n\n',
                                    style: GoogleFonts.firaCode(color: Colors.amberAccent, fontSize: 12),
                                  ),
                                if (_result!.stdout.isNotEmpty)
                                  TextSpan(
                                    text: _result!.stdout,
                                    style: GoogleFonts.firaCode(color: const Color(0xFFA6E3A1), fontSize: 12),
                                  ),
                                if (_result!.stderr.isNotEmpty)
                                  TextSpan(
                                    text: '\n[Error / stderr]\n${_result!.stderr}',
                                    style: GoogleFonts.firaCode(color: const Color(0xFFF38BA8), fontSize: 12),
                                  ),
                                if (_result!.stdout.isEmpty && _result!.stderr.isEmpty && (_result!.compileOutput == null || _result!.compileOutput!.isEmpty))
                                  TextSpan(
                                    text: '(El programa finalizó correctamente sin imprimir texto)',
                                    style: GoogleFonts.firaCode(color: Colors.white54, fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

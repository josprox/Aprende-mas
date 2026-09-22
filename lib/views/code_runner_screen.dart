import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/vs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlight/languages/dart.dart' as hl_dart;
import 'package:highlight/languages/java.dart' as hl_java;
import 'package:highlight/languages/javascript.dart' as hl_js;
import 'package:highlight/languages/typescript.dart' as hl_ts;
import 'package:highlight/languages/php.dart' as hl_php;
import 'package:highlight/languages/python.dart' as hl_python;
import 'package:highlight/languages/cpp.dart' as hl_cpp;
import 'package:highlight/languages/cs.dart' as hl_cs;
import 'package:highlight/languages/go.dart' as hl_go;
import 'package:highlight/languages/rust.dart' as hl_rust;
import 'package:highlight/languages/sql.dart' as hl_sql;
import 'package:highlight/languages/bash.dart' as hl_bash;
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
  late CodeController _codeController;
  final TextEditingController _stdinController = TextEditingController();

  late String _selectedLanguage;
  bool _isRunning = false;
  CodeExecutionResult? _result;
  bool _showStdin = false;

  final List<Map<String, dynamic>> _availableLanguages = [
    {'id': 'joss', 'label': 'Joss', 'lang': null},
    {'id': 'dart', 'label': 'Dart', 'lang': hl_dart.dart},
    {'id': 'java', 'label': 'Java', 'lang': hl_java.java},
    {'id': 'php', 'label': 'PHP', 'lang': hl_php.php},
    {'id': 'python', 'label': 'Python 3', 'lang': hl_python.python},
    {'id': 'c', 'label': 'C (GCC)', 'lang': hl_cpp.cpp},
    {'id': 'cpp', 'label': 'C++ (G++)', 'lang': hl_cpp.cpp},
    {'id': 'javascript', 'label': 'JavaScript (Node)', 'lang': hl_js.javascript},
    {'id': 'typescript', 'label': 'TypeScript', 'lang': hl_ts.typescript},
    {'id': 'csharp', 'label': 'C# (Mono)', 'lang': hl_cs.cs},
    {'id': 'go', 'label': 'Go', 'lang': hl_go.go},
    {'id': 'rust', 'label': 'Rust', 'lang': hl_rust.rust},
    {'id': 'sqlite3', 'label': 'SQL (SQLite)', 'lang': hl_sql.sql},
    {'id': 'bash', 'label': 'Bash', 'lang': hl_bash.bash},
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
    _codeController = _buildController(code, _selectedLanguage);
  }

  CodeController _buildController(String code, String langId) {
    final langDef = _availableLanguages
        .firstWhere((l) => l['id'] == langId, orElse: () => {'lang': null})['lang'];
    return CodeController(text: code, language: langDef);
  }

  void _switchLanguage(String newLang) {
    final newCode = widget.initialCode.isEmpty
        ? _getDefaultSnippetForLanguage(newLang)
        : _codeController.text;
    final newController = _buildController(newCode, newLang);
    setState(() {
      _selectedLanguage = newLang;
      _codeController.dispose();
      _codeController = newController;
    });
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
        // Joss NO tiene for ni if/else — usa foreach, while y ternario con bloques
        return r'''$mensaje = "¡Hola desde Joss en Aprende Más!"
print($mensaje)

$a = 15
$b = 27
$suma = $a + $b
print("Suma: " . $suma)

// Bucle con rango (1..3)
foreach (1..3 as $i) {
    print("Iteración: " . $i)
}

// Decisión con ternario (no existe if/else en Joss)
($suma > 30) ? {
    print("La suma es mayor a 30")
} : {
    print("La suma es menor o igual a 30")
}''';
      case 'dart':
        return r'''void main() {
  print('¡Hola desde Aprende Más con Dart!');
  for (int i = 1; i <= 3; i++) {
    print('Iteración: $i');
  }
}''';
      case 'java':
        return '''public class Main {
    public static void main(String[] args) {
        System.out.println("¡Hola desde Java!");
        int a = 10, b = 20;
        System.out.println("Suma: " + (a + b));
    }
}''';
      case 'php':
        return '''<?php
echo "¡Hola desde PHP en Aprende Más!\\n";
\$datos = ["Algoritmos", "Estructuras", "Calidad"];
foreach (\$datos as \$item) {
    echo "- " . \$item . "\\n";
}''';
      case 'python':
        return '''print("¡Hola desde Python 3!")
valores = [1, 2, 3, 4, 5]
cuadrados = [x**2 for x in valores]
print(f"Cuadrados: {cuadrados}")''';
      case 'c':
        return '''#include <stdio.h>

int main() {
    printf("¡Hola desde C!\\n");
    return 0;
}''';
      case 'cpp':
        return '''#include <iostream>
using namespace std;

int main() {
    cout << "¡Hola desde C++ moderno!" << endl;
    return 0;
}''';
      case 'javascript':
        return '''console.log("¡Hola desde JavaScript!");
const egel = { materia: "Ingeniería de Software", reactivos: 283 };
console.log(JSON.stringify(egel, null, 2));''';
      case 'sqlite3':
        return '''CREATE TABLE materias (id INTEGER PRIMARY KEY, nombre TEXT);
INSERT INTO materias (nombre) VALUES ("Requisitos"), ("Arquitectura"), ("Pruebas");
SELECT * FROM materias;''';
      case 'bash':
        return r'''#!/bin/bash
echo "¡Hola desde Bash!"
for i in 1 2 3; do
  echo "Iteración: $i"
done''';
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
    final isDark = theme.brightness == Brightness.dark;

    final editorTheme = isDark ? atomOneDarkTheme : vsTheme;
    final editorBg = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFFAFAFA);
    final editorFg = isDark ? const Color(0xFFCDD6F4) : const Color(0xFF1E1E2E);
    final consoleBg = isDark ? const Color(0xFF181825) : const Color(0xFFF5F5F5);

    // CodeTheme DEBE envolver todo el árbol que contiene CodeField
    // para que CodeTheme.of(context) lo resuelva como InheritedWidget.
    return CodeTheme(
      data: CodeThemeData(styles: editorTheme),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? 'Probador de Código'),
          actions: [
            IconButton(
              icon: const Icon(Icons.cleaning_services_rounded),
              tooltip: 'Restablecer código original',
              onPressed: () {
                final fresh = widget.initialCode.isNotEmpty
                    ? widget.initialCode
                    : _getDefaultSnippetForLanguage(_selectedLanguage);
                setState(() {
                  _codeController.text = fresh;
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
            // ─── Barra de lenguaje + Ejecutar ───
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
                              value: item['id'] as String,
                              child: Row(
                                children: [
                                  const Icon(Icons.code_rounded, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    item['label'] as String,
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
                                    _switchLanguage(val);
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

            // ─── Editor con Syntax Highlighting ───
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  // CodeField con expands:true ocupa el Expanded directamente
                  SizedBox.expand(
                    child: CodeField(
                      controller: _codeController,
                      expands: true,
                      textStyle: GoogleFonts.firaCode(
                        fontSize: 13.5,
                        color: editorFg,
                        height: 1.55,
                      ),
                      gutterStyle: GutterStyle(
                        showLineNumbers: true,
                        textStyle: GoogleFonts.firaCode(
                          fontSize: 11.5,
                          color: isDark ? Colors.white30 : Colors.black38,
                        ),
                        background: isDark ? const Color(0xFF181825) : const Color(0xFFEEEEEE),
                        width: 44,
                      ),
                      background: editorBg,
                      decoration: const BoxDecoration(),
                      onChanged: (_) {},
                    ),
                  ),
                  // Botón stdin superpuesto
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        _showStdin ? Icons.input_rounded : Icons.input_outlined,
                        color: _showStdin
                            ? scheme.primary
                            : (isDark ? Colors.white54 : Colors.black45),
                        size: 20,
                      ),
                      tooltip: 'Entrada estándar (stdin)',
                      onPressed: () => setState(() => _showStdin = !_showStdin),
                    ),
                  ),
                ],
              ),
            ),

            // ─── stdin opcional ───
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

            // ─── Barra de consola ───
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
                            color: _result!.isSuccess
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.red.withValues(alpha: 0.2),
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

            // ─── Terminal de salida ───
            Expanded(
              flex: 4,
              child: Container(
                color: consoleBg,
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                child: SingleChildScrollView(
                  child: _isRunning
                      ? Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                    color: isDark ? Colors.lightGreenAccent : scheme.primary),
                                const SizedBox(height: 12),
                                Text(
                                  'Compilando y ejecutando en servidor seguro...',
                                  style: TextStyle(
                                      color: isDark ? Colors.white70 : Colors.black54,
                                      fontSize: 12),
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
                                  style: GoogleFonts.firaCode(
                                    color: isDark ? Colors.white38 : Colors.black38,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                          : SelectableText.rich(
                              TextSpan(
                                children: [
                                  if (_result!.compileOutput != null &&
                                      _result!.compileOutput!.isNotEmpty)
                                    TextSpan(
                                      text: '[Compilador]\n${_result!.compileOutput}\n\n',
                                      style: GoogleFonts.firaCode(
                                          color: isDark
                                              ? Colors.amberAccent
                                              : Colors.orange[800],
                                          fontSize: 12),
                                    ),
                                  if (_result!.stdout.isNotEmpty)
                                    TextSpan(
                                      text: _result!.stdout,
                                      style: GoogleFonts.firaCode(
                                          color: isDark
                                              ? const Color(0xFFA6E3A1)
                                              : Colors.green[800],
                                          fontSize: 12),
                                    ),
                                  if (_result!.stderr.isNotEmpty)
                                    TextSpan(
                                      text: '\n[Error / stderr]\n${_result!.stderr}',
                                      style: GoogleFonts.firaCode(
                                          color: isDark
                                              ? const Color(0xFFF38BA8)
                                              : Colors.red[700],
                                          fontSize: 12),
                                    ),
                                  if (_result!.stdout.isEmpty &&
                                      _result!.stderr.isEmpty &&
                                      (_result!.compileOutput == null ||
                                          _result!.compileOutput!.isEmpty))
                                    TextSpan(
                                      text: '(El programa finalizó correctamente sin imprimir texto)',
                                      style: GoogleFonts.firaCode(
                                          color: isDark ? Colors.white54 : Colors.black45,
                                          fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

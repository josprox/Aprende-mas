import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown/markdown.dart' as md;

import 'package:aprende_mas/viewmodels/reading_preferences_viewmodel.dart';
import 'package:aprende_mas/views/code_runner_screen.dart';

/// Sintaxis para capturar fórmulas matemáticas en línea: $formula$ o \(formula\)
class InlineMathSyntax extends md.InlineSyntax {
  InlineMathSyntax() : super(r'(?:\$([^\$\n]+?)\$|\\\((.+?)\\\))');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final formula = match.group(1) ?? match.group(2) ?? '';
    if (formula.trim().isEmpty) return false;
    final element = md.Element('latex_inline', [md.Text(formula.trim())]);
    parser.addNode(element);
    return true;
  }
}

/// Sintaxis para capturar fórmulas matemáticas en bloque: $$formula$$ o \[formula\]
class DisplayMathSyntax extends md.InlineSyntax {
  DisplayMathSyntax() : super(r'(?:\$\$([\s\S]+?)\$\$|\\\[([\s\S]+?)\\\])');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final formula = match.group(1) ?? match.group(2) ?? '';
    if (formula.trim().isEmpty) return false;
    final element = md.Element('latex_display', [md.Text(formula.trim())]);
    parser.addNode(element);
    return true;
  }
}

/// Builder para renderizar fórmulas matemáticas en línea con KaTeX
class LatexInlineElementBuilder extends MarkdownElementBuilder {
  final double scale;

  LatexInlineElementBuilder({this.scale = 1.0});

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final formula = element.textContent;
    final baseStyle = preferredStyle ?? parentStyle ?? Theme.of(context).textTheme.bodyMedium;
    final mathStyle = baseStyle?.copyWith(
      fontSize: (baseStyle.fontSize ?? 14.0) * scale,
    );

    return Math.tex(
      formula,
      mathStyle: MathStyle.text,
      textStyle: mathStyle,
      onErrorFallback: (err) => Text(
        '\$$formula\$',
        style: mathStyle?.copyWith(fontFamily: 'monospace', color: Colors.amber[800]),
      ),
    );
  }
}

/// Builder para renderizar fórmulas matemáticas en bloque display con KaTeX
class LatexDisplayElementBuilder extends MarkdownElementBuilder {
  final double scale;

  LatexDisplayElementBuilder({this.scale = 1.0});

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final formula = element.textContent;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Math.tex(
            formula,
            mathStyle: MathStyle.display,
            textStyle: TextStyle(
              fontSize: 16.0 * scale,
              color: scheme.onSurface,
            ),
            onErrorFallback: (err) => Text(
              formula,
              style: TextStyle(fontFamily: 'monospace', color: Colors.red[700]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Builder para envolver tablas Markdown en desplazamiento horizontal fluido
class ResponsiveTableElementBuilder extends MarkdownElementBuilder {
  final double scale;

  ResponsiveTableElementBuilder({this.scale = 1.0});

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Extraer cabecera y cuerpo
    final thead = element.children?.firstWhere(
      (c) => c is md.Element && c.tag == 'thead',
      orElse: () => md.Element.empty(''),
    ) as md.Element?;

    final tbody = element.children?.firstWhere(
      (c) => c is md.Element && c.tag == 'tbody',
      orElse: () => md.Element.empty(''),
    ) as md.Element?;

    final List<List<String>> headerRows = [];
    final List<List<String>> bodyRows = [];

    if (thead != null && thead.children != null) {
      for (final tr in thead.children!.whereType<md.Element>()) {
        final cells = tr.children?.whereType<md.Element>().map((th) => th.textContent.trim()).toList() ?? [];
        if (cells.isNotEmpty) headerRows.add(cells);
      }
    }

    if (tbody != null && tbody.children != null) {
      for (final tr in tbody.children!.whereType<md.Element>()) {
        final cells = tr.children?.whereType<md.Element>().map((td) => td.textContent.trim()).toList() ?? [];
        if (cells.isNotEmpty) bodyRows.add(cells);
      }
    }

    if (headerRows.isEmpty && bodyRows.isEmpty) {
      return null;
    }

    final columnCount = headerRows.isNotEmpty
        ? headerRows.first.length
        : (bodyRows.isNotEmpty ? bodyRows.first.length : 0);

    if (columnCount == 0) return null;

    final baseFontSize = 13.0 * scale;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder(
            horizontalInside: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
            verticalInside: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          children: [
            // Cabeceras
            ...headerRows.map((row) {
              return TableRow(
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.7),
                ),
                children: List.generate(columnCount, (index) {
                  final text = index < row.length ? row[index] : '';
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 100, maxWidth: 300),
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: baseFontSize,
                          fontWeight: FontWeight.w800,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
            // Filas de cuerpo
            ...bodyRows.asMap().entries.map((entry) {
              final rowIndex = entry.key;
              final row = entry.value;
              final isEven = rowIndex.isEven;

              return TableRow(
                decoration: BoxDecoration(
                  color: isEven ? scheme.surface : scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
                children: List.generate(columnCount, (index) {
                  final text = index < row.length ? row[index] : '';
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 100, maxWidth: 320),
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: baseFontSize,
                          height: 1.35,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Builder para bloques de código con resaltado, insignia de lenguaje, botón Copiar y botón Probar Código
class CodeBlockElementBuilder extends MarkdownElementBuilder {
  final double scale;

  CodeBlockElementBuilder({this.scale = 1.0});

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    // Si no es un bloque de código multinivel, retornar null para que use renderizado normal
    final isCodeBlock = element.tag == 'pre' || (element.tag == 'code' && element.textContent.contains('\n'));
    if (!isCodeBlock) return null;

    final rawCode = element.textContent.trimRight();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Detectar lenguaje desde atributos de clase (ej. class="language-dart")
    String language = 'text';
    if (element.children != null && element.children!.isNotEmpty) {
      final child = element.children!.first;
      if (child is md.Element && child.attributes['class'] != null) {
        final cls = child.attributes['class']!;
        final match = RegExp(r'language-(\w+)').firstMatch(cls);
        if (match != null) {
          language = match.group(1)!.toLowerCase();
        }
      }
    } else if (element.attributes['class'] != null) {
      final cls = element.attributes['class']!;
      final match = RegExp(r'language-(\w+)').firstMatch(cls);
      if (match != null) {
        language = match.group(1)!.toLowerCase();
      }
    }

    final isRunnable = [
      'joss', 'dart', 'java', 'php', 'python', 'py', 'c', 'cpp', 'c++', 'javascript', 'js', 'typescript', 'ts', 'csharp', 'go', 'rust', 'sql', 'sqlite'
    ].contains(language);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E), // Paleta oscura profesional
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barra de cabecera con lenguaje y acciones
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            color: const Color(0xFF181825),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.code_rounded, size: 16, color: Color(0xFF89B4FA)),
                    const SizedBox(width: 6),
                    Text(
                      language.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Color(0xFFCDD6F4),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (isRunnable)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          backgroundColor: const Color(0xFF313244),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          CodeRunnerScreen.open(
                            context,
                            language: language,
                            code: rawCode,
                            title: 'Probar ${language.toUpperCase()}',
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 16, color: Color(0xFFA6E3A1)),
                        label: const Text(
                          'Probar',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFA6E3A1),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 15, color: Color(0xFFA6ADC8)),
                      tooltip: 'Copiar código',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: rawCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Código copiado al portapapeles'),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Código con resaltado de sintaxis
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(14),
            child: HighlightView(
              rawCode,
              language: language == 'text' ? 'plaintext' : language,
              theme: atomOneDarkTheme,
              textStyle: GoogleFonts.firaCode(
                fontSize: 13.0 * scale,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget principal optimizado para renderizar Markdown con:
/// - Tablas responsivas con scroll horizontal
/// - Soporte de KaTeX/LaTeX ($...$ y $$...$$)
/// - Resaltado de sintaxis y botón para probar código en vivo
/// - Escala de texto configurable y accesible
class AppMarkdownViewer extends ConsumerWidget {
  final String data;
  final bool selectable;
  final EdgeInsets? padding;

  const AppMarkdownViewer({
    super.key,
    required this.data,
    this.selectable = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(readingPreferencesProvider);
    final scale = prefs.textScale;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final bool isDark = theme.brightness == Brightness.dark;

    final markdownStyleSheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: theme.textTheme.bodyMedium?.copyWith(
        fontSize: 15.0 * scale,
        height: 1.55,
        color: scheme.onSurface,
      ),
      h1: theme.textTheme.headlineMedium?.copyWith(
        fontSize: 22.0 * scale,
        fontWeight: FontWeight.w900,
        height: 1.25,
        color: scheme.onSurface,
      ),
      h2: theme.textTheme.headlineSmall?.copyWith(
        fontSize: 18.0 * scale,
        fontWeight: FontWeight.w800,
        height: 1.3,
        color: scheme.primary,
      ),
      h3: theme.textTheme.titleMedium?.copyWith(
        fontSize: 16.0 * scale,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: scheme.onSurface,
      ),
      h4: theme.textTheme.titleSmall?.copyWith(
        fontSize: 14.5 * scale,
        fontWeight: FontWeight.w700,
        color: scheme.onSurfaceVariant,
      ),
      listBullet: theme.textTheme.bodyMedium?.copyWith(
        fontSize: 15.0 * scale,
        color: scheme.primary,
        fontWeight: FontWeight.bold,
      ),
      blockquote: theme.textTheme.bodyMedium?.copyWith(
        fontSize: 14.5 * scale,
        fontStyle: FontStyle.italic,
        height: 1.45,
        color: scheme.onSecondaryContainer,
      ),
      blockquoteDecoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: scheme.primary, width: 4),
        ),
      ),
      code: GoogleFonts.firaCode(
        fontSize: 13.0 * scale,
        backgroundColor: scheme.surfaceContainerHighest,
        color: scheme.primary,
      ),
      // ─── Tabla: IntrinsicColumnWidth activa el scroll horizontal nativo ───
      tableColumnWidth: const IntrinsicColumnWidth(),
      tableHead: TextStyle(
        fontSize: 13.0 * scale,
        fontWeight: FontWeight.w700,
        color: scheme.onPrimaryContainer,
      ),
      tableBody: TextStyle(
        fontSize: 13.0 * scale,
        height: 1.4,
        color: scheme.onSurface,
      ),
      tableBorder: TableBorder.all(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        width: 1,
        borderRadius: BorderRadius.circular(10),
      ),
      tableCellsPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      tableCellsDecoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHighest.withValues(alpha: 0.25)
            : scheme.surfaceContainerLowest,
      ),
      tableScrollbarThumbVisibility: true,
    );

    return MarkdownBody(
      data: data,
      selectable: selectable,
      styleSheet: markdownStyleSheet,
      extensionSet: md.ExtensionSet.gitHubFlavored,
      inlineSyntaxes: [
        DisplayMathSyntax(),
        InlineMathSyntax(),
      ],
      builders: {
        'pre': CodeBlockElementBuilder(scale: scale),
        'latex_inline': LatexInlineElementBuilder(scale: scale),
        'latex_display': LatexDisplayElementBuilder(scale: scale),
      },
    );
  }
}

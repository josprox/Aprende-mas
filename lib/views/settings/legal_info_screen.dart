import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalInfoScreen extends StatelessWidget {
  const LegalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Información legal")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const _LegalSection(
            icon: Icons.gavel_rounded,
            title: "Términos y condiciones",
            children: [
              Text(
                "Al usar esta aplicación aceptas que se proporciona tal cual, sin garantías. El desarrollador no se hace responsable por pérdida de datos o daños derivados de su uso. El contenido está protegido por derechos de autor.",
              ),
            ],
          ),
          _LegalSection(
            icon: Icons.code_rounded,
            title: "Licencia de código fuente",
            children: [
              const Text(
                "El código fuente está disponible para consulta y auditoría pública, pero este software no es de código abierto.",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                "Puedes consultar y aportar mediante pull requests o reportes.",
              ),
              const SizedBox(height: 8),
              Text(
                "Está prohibido modificar, distribuir, republicar, sublicenciar o usar el código con fines comerciales o derivados sin permiso explícito y escrito del desarrollador.",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
          const _LegalSection(
            icon: Icons.privacy_tip_rounded,
            title: "Política de privacidad",
            children: [
              Text(
                "La aplicación está diseñada para ser privada. Los datos de materias, notas y progreso se almacenan localmente en tu dispositivo y no se transmiten a servidores externos sin tu consentimiento explícito.",
              ),
            ],
          ),
          const _LegalSection(
            icon: Icons.extension_rounded,
            title: "Componentes de terceros",
            children: [
              Text(
                "Esta aplicación utiliza bibliotecas de terceros licenciadas como código abierto, incluyendo Flutter, Riverpod y otros componentes compatibles.",
              ),
            ],
          ),
          _LegalSection(
            icon: Icons.support_agent_rounded,
            title: "Soporte y autoría",
            children: [
              Text(
                "Melchor Estrada José Luis - JOSPROX MX",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    const TextSpan(text: "Soporte: "),
                    TextSpan(
                      text: "josprox.com/soporte/",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          final uri = Uri.parse("https://josprox.com/soporte/");
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              "JOSPROX MX",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _LegalSection({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: scheme.onSecondaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.04, end: 0);
  }
}

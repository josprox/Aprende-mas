import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalInfoScreen extends StatelessWidget {
  const LegalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Información Legal"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Acuerdos y Políticas",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const _LegalSection(
            title: "Términos y Condiciones de Uso (T&C)",
            children: [
              Text(
                "Al usar esta aplicación, usted acepta los siguientes términos: La aplicación es proporcionada 'tal cual' sin garantías. El desarrollador no se hace responsable por la pérdida de datos o daños derivados de su uso. El contenido está protegido por derechos de autor.",
              ),
            ],
          ),
          _LegalSection(
            title: "Licencia de Código Fuente (Source-Available)",
            children: [
              const Text(
                "El código fuente de esta aplicación está disponible para su consulta y auditoría pública. Sin embargo, este software NO es de código abierto (Open Source).",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Derechos del Usuario:",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const Text(
                "Usted tiene derecho a **consultar** y **aportar** (mediante pull requests o reportes) al código fuente.",
              ),
              const SizedBox(height: 4),
              const Text(
                "Restricciones:",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                "Está estrictamente prohibido modificar, distribuir, republicar, sublicenciar o utilizar el código para fines comerciales o derivados sin el permiso explícito y escrito del desarrollador.",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
          const _LegalSection(
            title: "Política de Privacidad",
            children: [
              Text(
                "Esta aplicación está diseñada para ser privada y no recopila información personal identificable. Los datos (materias, notas) se almacenan localmente en su dispositivo y nunca se transmiten a servidores externos sin su consentimiento explícito (como al crear un backup local).",
              ),
            ],
          ),
          const _LegalSection(
            title: "Componentes de Terceros (Código Abierto)",
            children: [
              Text(
                "Esta aplicación utiliza bibliotecas de terceros que sí están licenciadas bajo licencias de Código Abierto (Open Source), incluyendo Flutter, Riverpod, Drift, etc. Se respetan todas las obligaciones de licencia de estos componentes.",
              ),
            ],
          ),
          _LegalSection(
            title: "Soporte y Autoría",
            children: [
              const Text("Aplicación creada por:"),
              Text(
                "Melchor Estrada José Luis - JOSPROX MX",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Para soporte, reportes de errores, dudas o cualquier otra consulta, por favor utilice el siguiente enlace:",
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    const TextSpan(text: "Enlace de Soporte: "),
                    TextSpan(
                      text: "josprox.com/soporte/",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
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
          const SizedBox(height: 16),
          Center(
            child: Text(
              "JOSPROX MX",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _LegalSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

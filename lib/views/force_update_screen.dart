import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aprende_mas/services/update_service.dart';

class ForceUpdateScreen extends StatelessWidget {
  final UpdateInfo updateInfo;

  const ForceUpdateScreen({super.key, required this.updateInfo});

  Future<void> _openDownloadUrl(BuildContext context) async {
    final String fallbackUrl = dotenv.env['GOOGLEPLAY_URL'] ??
        "https://play.google.com/store/apps/details?id=com.josprox.jossmusic";
    final String targetUrl =
        updateInfo.downloadUrl.isNotEmpty ? updateInfo.downloadUrl : fallbackUrl;

    final Uri uri = Uri.parse(targetUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir el enlace de descarga: $targetUrl'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false, // Bloquea la navegación hacia atrás para forzar la actualización
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // Animated Hero Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.system_update_rounded,
                      size: 52,
                      color: Colors.white,
                    ),
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 28),

                // Title
                Text(
                  updateInfo.title.isNotEmpty
                      ? updateInfo.title
                      : 'Actualización obligatoria',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                  ),
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 8),

                // Version Badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Versión ${updateInfo.version} requerida',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 250.ms),

                const SizedBox(height: 24),

                // Release Notes Card
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.new_releases_outlined,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Novedades de esta versión',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Expanded(
                          child: SingleChildScrollView(
                            child: MarkdownBody(
                              data: updateInfo.description.isNotEmpty
                                  ? updateInfo.description
                                  : 'Se requiere actualizar la aplicación para continuar utilizándola con todas las mejoras de seguridad y características.',
                              onTapLink: (text, href, title) {
                                if (href != null) {
                                  launchUrl(
                                    Uri.parse(href),
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.04, end: 0),
                ),

                const SizedBox(height: 24),

                // Download Button
                FilledButton.icon(
                  onPressed: () => _openDownloadUrl(context),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Actualizar ahora en Google Play'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ).animate().fadeIn(delay: 450.ms),

                const SizedBox(height: 12),
                Text(
                  'No puedes continuar sin instalar la última actualización.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

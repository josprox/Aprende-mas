import 'package:aprende_mas/views/settings/backup_restore_screen.dart';
import 'package:aprende_mas/views/settings/legal_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text("Ajustes")),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SettingsGroupCard(
                  title: "Datos",
                  children: [
                    _SettingsItem(
                      headline: "Copia de seguridad",
                      supportingText:
                          "Exporta o restaura materias, tests y progreso.",
                      icon: Icons.cloud_sync_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BackupRestoreScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SettingsGroupCard(
                  title: "Aplicación",
                  children: [
                    _SettingsItem(
                      headline: "Información y legal",
                      supportingText:
                          "Versión, privacidad, términos y soporte.",
                      icon: Icons.verified_user_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LegalInfoScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroupCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroupCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(child: Column(children: children)),
      ],
    ).animate().fadeIn(duration: 240.ms).slideY(begin: 0.04, end: 0);
  }
}

class _SettingsItem extends StatelessWidget {
  final String headline;
  final String supportingText;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.headline,
    required this.supportingText,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      title: Text(
        headline,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(supportingText),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: scheme.onPrimaryContainer),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: scheme.primary),
      onTap: onTap,
    );
  }
}

import 'package:aprende_mas/views/settings/backup_restore_screen.dart';
import 'package:aprende_mas/views/settings/legal_info_screen.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ajustes de la Aplicación",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          _SettingsGroupCard(
            title: "Gestión de Datos",
            children: [
              _SettingsItem(
                headline: "Copia de Seguridad y Restauración",
                supportingText:
                    "Exporta o importa todos tus datos de estudio y progreso.",
                icon: Icons.save,
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
          const SizedBox(height: 24),
          _SettingsGroupCard(
            title: "Información y Legal",
            children: [
              _SettingsItem(
                headline: "Acerca de la Aplicación",
                supportingText:
                    "Detalles de la versión y reconocimiento a desarrolladores.",
                icon: Icons.info,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LegalInfoScreen(),
                    ),
                  );
                },
              ),
              Divider(
                height: 1,
                indent: 56,
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withOpacity(0.5),
              ),
              _SettingsItem(
                headline: "Información Legal",
                supportingText:
                    "Política de privacidad y términos de servicio.",
                icon: Icons.lock,
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
          const SizedBox(height: 32),
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
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(
          elevation: 2,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
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
    return ListTile(
      title: Text(
        headline,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(supportingText),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

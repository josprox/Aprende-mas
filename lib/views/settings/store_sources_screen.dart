import 'package:aprende_mas/services/store_source_service.dart';
import 'package:flutter/material.dart';

class StoreSourcesScreen extends StatefulWidget {
  const StoreSourcesScreen({super.key});
  @override
  State<StoreSourcesScreen> createState() => _StoreSourcesScreenState();
}

class _StoreSourcesScreenState extends State<StoreSourcesScreen> {
  List<StoreSource> sources = const [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final value = await StoreSourceService.load();
    if (mounted) setState(() => sources = value);
  }

  Future<void> _remove(int index) async {
    final next = [...sources]..removeAt(index);
    await StoreSourceService.save(next);
    setState(() => sources = next);
  }

  Future<void> _add() async {
    final name = TextEditingController();
    final url = TextEditingController();
    final result = await showDialog<StoreSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir tienda comunitaria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: url,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'URL base de API',
                hintText: 'https://comunidad.example/api',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final uri = Uri.tryParse(url.text.trim());
              if (name.text.trim().isEmpty ||
                  uri == null ||
                  !uri.hasScheme ||
                  uri.scheme != 'https') {
                return;
              }
              Navigator.pop(
                context,
                StoreSource(name: name.text.trim(), url: url.text.trim()),
              );
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
    name.dispose();
    url.dispose();
    if (result != null) {
      final next = [...sources, result];
      await StoreSourceService.save(next);
      if (mounted) setState(() => sources = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tiendas comunitarias')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('Añadir'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card.filled(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Cada tienda debe usar HTTPS y exponer /repositories y /repositories/{id}/download. Tu sesión de Joss Red nunca se envía a tiendas externas.',
              ),
            ),
          ),
          ...List.generate(
            sources.length,
            (index) => Card(
              child: ListTile(
                leading: const Icon(Icons.storefront_rounded),
                title: Text(sources[index].name),
                subtitle: Text(sources[index].url),
                trailing: IconButton(
                  onPressed: () => _remove(index),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

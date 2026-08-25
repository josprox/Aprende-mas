import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StoreSource {
  final String name;
  final String url;
  const StoreSource({required this.name, required this.url});
  Map<String, dynamic> toJson() => {'name': name, 'url': url};
  factory StoreSource.fromJson(Map<String, dynamic> json) => StoreSource(
    name: json['name']?.toString() ?? '',
    url: json['url']?.toString() ?? '',
  );
}

class StoreSourceService {
  static const _key = 'community_store_sources';
  static Future<List<StoreSource>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const [];
    return (jsonDecode(raw) as List)
        .whereType<Map>()
        .map((e) => StoreSource.fromJson(Map<String, dynamic>.from(e)))
        .where(
          (e) => e.name.isNotEmpty && Uri.tryParse(e.url)?.hasScheme == true,
        )
        .toList();
  }

  static Future<void> save(List<StoreSource> sources) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(sources.map((e) => e.toJson()).toList()),
    );
  }
}

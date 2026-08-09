import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateInfo {
  final String version;
  final String title;
  final String description;
  final String downloadUrl;

  UpdateInfo({
    required this.version,
    required this.title,
    required this.description,
    required this.downloadUrl,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      version: json['Version'] ?? json['version'] ?? '',
      title: json['Titulo'] ?? json['title'] ?? 'Nueva versión disponible',
      description: json['Descripcion'] ?? json['description'] ?? '',
      downloadUrl: json['Descarga'] ?? json['download_url'] ?? '',
    );
  }
}

class UpdateService {
  static final Dio _dio = Dio();

  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final String? checkUpdatesUrl = dotenv.env["JOSSREDCHECKUPDATES"] ??
          "https://joss.red/api/version/com.josprox.jossmusic";

      final response = await _dio.get(checkUpdatesUrl!);
      if (response.statusCode != 200) return null;

      final data = response.data is String
          ? json.decode(response.data as String)
          : response.data as Map<String, dynamic>;

      final updateInfo = UpdateInfo.fromJson(data);
      if (updateInfo.version.isEmpty) return null;

      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;

      if (_isVersionGreater(updateInfo.version, currentVersion)) {
        return updateInfo;
      }
      return null;
    } catch (e) {
      if (kDebugMode) print("Error checking updates: $e");
      return null;
    }
  }

  static bool _isVersionGreater(String latestVersion, String currentVersion) {
    List<String> latestParts = latestVersion.split('.');
    List<String> currentParts = currentVersion.split('.');

    while (latestParts.length < currentParts.length) {
      latestParts.add('0');
    }
    while (currentParts.length < latestParts.length) {
      currentParts.add('0');
    }

    for (int i = 0; i < latestParts.length; i++) {
      int latestPart =
          int.tryParse(latestParts[i].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      int currentPart =
          int.tryParse(currentParts[i].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

      if (latestPart > currentPart) return true;
      if (latestPart < currentPart) return false;
    }
    return false;
  }
}

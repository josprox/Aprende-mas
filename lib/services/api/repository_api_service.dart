import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aprende_mas/models/repository_models.dart';

class RepositoryApiService {
  final Dio _dio = Dio();
  String? _userToken;

  static String get baseUrl {
    String base = dotenv.env['JOSSRED']?.trim() ?? '';
    if (base.isEmpty) base = 'https://joss.red/';
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    if (!base.endsWith('/api')) base = '$base/api';
    return base;
  }

  static String get defaultApiToken {
    return dotenv.env['JOSSRED_API']?.trim() ?? '';
  }

  RepositoryApiService() {
    _dio.options.baseUrl = baseUrl;
    _updateHeaders();
  }

  void setAuthToken(String? token) {
    _userToken = token;
    _updateHeaders();
  }

  void _updateHeaders() {
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (defaultApiToken.isNotEmpty)
        'Authorization': 'Bearer $defaultApiToken',
      if (_userToken != null && _userToken!.isNotEmpty)
        'X-User-Token': _userToken!,
    };
  }

  Future<RepositoryListResponse> getRepositories({
    int page = 1,
    String? token,
    String? sourceUrl,
    String sourceName = 'Joss Red',
  }) async {
    try {
      final external = sourceUrl != null && sourceUrl.isNotEmpty;
      final options = Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (external && token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token'
          else if (!external && defaultApiToken.isNotEmpty)
            'Authorization': 'Bearer $defaultApiToken',
          if (_userToken != null && _userToken!.isNotEmpty)
            'X-User-Token': _userToken!,
        },
      );

      final root = external ? sourceUrl.replaceFirst(RegExp(r'/$'), '') : '';
      final response = await (external ? Dio() : _dio).get(
        external ? '$root/repositories' : '/repositories',
        queryParameters: {'page': page},
        options: options,
      );
      return RepositoryListResponse.fromJson(
        response.data,
        sourceName: sourceName,
        sourceUrl: sourceUrl ?? '',
      );
    } catch (e) {
      throw Exception('Failed to load repositories: $e');
    }
  }

  Future<Map<String, dynamic>> downloadRepository(
    int id, {
    String? token,
    String? sourceUrl,
  }) async {
    try {
      final external = sourceUrl != null && sourceUrl.isNotEmpty;
      final options = Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (external && token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token'
          else if (!external && defaultApiToken.isNotEmpty)
            'Authorization': 'Bearer $defaultApiToken',
          if (_userToken != null && _userToken!.isNotEmpty)
            'X-User-Token': _userToken!,
        },
      );

      final root = external ? sourceUrl.replaceFirst(RegExp(r'/$'), '') : '';
      Response response;
      try {
        response = await (external ? Dio() : _dio).get(
          external
              ? '$root/repositories/$id/download'
              : '/repositories/$id/download',
          options: options,
        );
      } catch (e) {
        if (!external) {
          // Fallback to public catalog download endpoint
          final publicBase = dotenv.env['JOSSRED']?.trim() ?? 'https://joss.red';
          final cleanBase = publicBase.endsWith('/')
              ? publicBase.substring(0, publicBase.length - 1)
              : publicBase;
          response = await Dio().get('$cleanBase/catalog/download/$id');
        } else {
          rethrow;
        }
      }
      final rawData = response.data;
      if (rawData is String) {
        return jsonDecode(rawData) as Map<String, dynamic>;
      }
      return rawData as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to download repository: $e');
    }
  }
}

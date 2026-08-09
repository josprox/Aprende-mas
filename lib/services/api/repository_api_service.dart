import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aprende_mas/models/repository_models.dart';

class RepositoryApiService {
  final Dio _dio = Dio();
  String? _userToken;

  static String get baseUrl {
    String base = dotenv.env['JOSSRED'] ?? 'https://joss.red/';
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    if (!base.endsWith('/api')) base = '$base/api';
    return base;
  }

  static String get defaultApiToken {
    return dotenv.env['JOSSRED_API'] ?? 'f8f446fa-b685-4989-a3e6-7106b83d18c6';
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
    final activeToken = (_userToken != null && _userToken!.isNotEmpty)
        ? _userToken
        : defaultApiToken;

    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (activeToken != null && activeToken.isNotEmpty)
        'Authorization': 'Bearer $activeToken',
    };
  }

  Future<RepositoryListResponse> getRepositories({int page = 1, String? token}) async {
    try {
      final activeToken = (token != null && token.isNotEmpty)
          ? token
          : ((_userToken != null && _userToken!.isNotEmpty)
              ? _userToken
              : defaultApiToken);

      final options = Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (activeToken != null && activeToken.isNotEmpty)
            'Authorization': 'Bearer $activeToken',
        },
      );

      final response = await _dio.get(
        '/repositories',
        queryParameters: {'page': page},
        options: options,
      );
      return RepositoryListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load repositories: $e');
    }
  }

  Future<Map<String, dynamic>> downloadRepository(int id, {String? token}) async {
    try {
      final activeToken = (token != null && token.isNotEmpty)
          ? token
          : ((_userToken != null && _userToken!.isNotEmpty)
              ? _userToken
              : defaultApiToken);

      final options = Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (activeToken != null && activeToken.isNotEmpty)
            'Authorization': 'Bearer $activeToken',
        },
      );

      final response = await _dio.get(
        '/repositories/$id/download',
        options: options,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to download repository: $e');
    }
  }
}

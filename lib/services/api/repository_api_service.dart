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

  Future<RepositoryListResponse> getRepositories({
    int page = 1,
    String? token,
    String? sourceUrl,
    String sourceName = 'Joss Red',
  }) async {
    try {
      final external = sourceUrl != null && sourceUrl.isNotEmpty;
      final activeToken = (token != null && token.isNotEmpty)
          ? token
          : ((_userToken != null && _userToken!.isNotEmpty)
                ? _userToken
                : defaultApiToken);

      final options = Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (!external && activeToken != null && activeToken.isNotEmpty)
            'Authorization': 'Bearer $activeToken',
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
      final activeToken = (token != null && token.isNotEmpty)
          ? token
          : ((_userToken != null && _userToken!.isNotEmpty)
                ? _userToken
                : defaultApiToken);

      final options = Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (!external && activeToken != null && activeToken.isNotEmpty)
            'Authorization': 'Bearer $activeToken',
        },
      );

      final root = external ? sourceUrl.replaceFirst(RegExp(r'/$'), '') : '';
      final response = await (external ? Dio() : _dio).get(
        external
            ? '$root/repositories/$id/download'
            : '/repositories/$id/download',
        options: options,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to download repository: $e');
    }
  }
}

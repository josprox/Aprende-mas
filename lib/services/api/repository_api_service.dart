import 'package:dio/dio.dart';
import 'package:aprende_mas/models/repository_models.dart';

class RepositoryApiService {
  final Dio _dio = Dio();

  RepositoryApiService() {
    // _dio.options.baseUrl = 'https://jossredjs.josprox.com/api'; // Direct URL
    _dio.options.baseUrl = 'https://jossredjs.josprox.com/api';
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<RepositoryListResponse> getRepositories({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/repositories',
        queryParameters: {'page': page},
      );
      return RepositoryListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load repositories: $e');
    }
  }

  Future<Map<String, dynamic>> downloadRepository(int id) async {
    try {
      final response = await _dio.get('/repositories/$id/download');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to download repository: $e');
    }
  }
}

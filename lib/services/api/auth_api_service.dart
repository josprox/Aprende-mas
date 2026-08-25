import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aprende_mas/models/auth_models.dart';

class AuthApiService {
  final Dio _dio = Dio();

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

  AuthApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (defaultApiToken.isNotEmpty)
        'Authorization': 'Bearer $defaultApiToken',
    };
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email.trim(), 'password': password},
      );

      final data = response.data;
      final status = data['status']?.toString().trim().toLowerCase();

      final challengeToken =
          data['challenge_token'] ??
          data['challengeToken'] ??
          data['temp_token'];

      if (response.statusCode == 202 ||
          status == '2fa_required' ||
          data['requires_2fa'] == true) {
        return AuthResponse(
          success: false,
          requires2FA: true,
          challengeToken: challengeToken?.toString(),
          message:
              data['message'] ??
              'Código de autenticación de 2 factores requerido.',
        );
      }

      if (data['status'] == 'success' && data['token'] != null) {
        final token = data['token'] as String;
        final user = data['user'] != null
            ? UserModel.fromJson(data['user'])
            : null;

        return AuthResponse(
          success: true,
          token: token,
          user: user,
          message: 'Inicio de sesión exitoso',
        );
      }

      return AuthResponse(
        success: false,
        message: data['message'] ?? 'Credenciales inválidas.',
      );
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          final status = data['status']?.toString().trim().toLowerCase();
          final challengeToken =
              data['challenge_token'] ?? data['challengeToken'];
          if (status == '2fa_required' || e.response?.statusCode == 202) {
            return AuthResponse(
              success: false,
              requires2FA: true,
              challengeToken: challengeToken?.toString(),
              message: 'Se requiere código de autenticación de dos factores.',
            );
          }
          if (data.containsKey('message')) {
            return AuthResponse(success: false, message: data['message']);
          }
        }
      }
      return AuthResponse(
        success: false,
        message: 'Error al conectar con el servidor',
      );
    } catch (e) {
      return AuthResponse(success: false, message: 'Error inesperado: $e');
    }
  }

  Future<AuthResponse> verify2FA({
    required String challengeToken,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        '/login/2fa',
        data: {'challenge_token': challengeToken, 'code': code.trim()},
      );

      final data = response.data;
      if (data['status'] == 'success' && data['token'] != null) {
        final token = data['token'] as String;
        final user = data['user'] != null
            ? UserModel.fromJson(data['user'])
            : null;

        return AuthResponse(
          success: true,
          token: token,
          user: user,
          message: 'Verificación 2FA exitosa',
        );
      }

      return AuthResponse(
        success: false,
        message: data['message'] ?? 'Código 2FA incorrecto o expirado.',
      );
    } on DioException catch (e) {
      String errorMessage = 'Código de 2FA inválido';
      if (e.response != null && e.response?.data != null) {
        final res = e.response!.data;
        if (res is Map && res.containsKey('message')) {
          errorMessage = res['message'];
        }
      }
      return AuthResponse(success: false, message: errorMessage);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Error inesperado al verificar 2FA: $e',
      );
    }
  }

  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {
          'first_name': firstName.trim(),
          'last_name': lastName.trim(),
          'username': username.trim(),
          'email': email.trim(),
          'password': password,
          if (phone != null && phone.isNotEmpty) 'phone': phone.trim(),
        },
      );

      final data = response.data;
      if (data['status'] == 'success') {
        return AuthResponse(
          success: true,
          message: data['message'] ?? 'Usuario registrado exitosamente.',
        );
      }

      return AuthResponse(
        success: false,
        message: data['message'] ?? 'No se pudo crear la cuenta.',
      );
    } on DioException catch (e) {
      String errorMessage = 'Error al registrar usuario';
      if (e.response != null && e.response?.data != null) {
        final res = e.response!.data;
        if (res is Map && res.containsKey('message')) {
          errorMessage = res['message'];
        }
      }
      return AuthResponse(success: false, message: errorMessage);
    } catch (e) {
      return AuthResponse(success: false, message: 'Error inesperado: $e');
    }
  }

  Future<UserModel?> getProfile(String userToken) async {
    try {
      final response = await _dio.get(
        '/profile',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $userToken',
          },
        ),
      );

      final data = response.data;
      if (data['status'] == 'success' && data['user'] != null) {
        return UserModel.fromJson(data['user']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout(String userToken) async {
    try {
      await _dio.post(
        '/logout',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $userToken',
          },
        ),
      );
    } catch (_) {}
  }
}

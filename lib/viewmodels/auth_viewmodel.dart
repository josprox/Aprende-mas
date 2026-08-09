import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aprende_mas/models/auth_models.dart';
import 'package:aprende_mas/services/api/auth_api_service.dart';
import 'package:aprende_mas/services/api/repository_api_service.dart';
import 'package:aprende_mas/viewmodels/providers.dart';

class AuthUiState {
  final UserModel? user;
  final String? token;
  final bool isLoading;
  final bool isError;
  final bool requires2FA;
  final String? challengeToken;
  final String? errorMessage;
  final String? successMessage;

  const AuthUiState({
    this.user,
    this.token,
    this.isLoading = false,
    this.isError = false,
    this.requires2FA = false,
    this.challengeToken,
    this.errorMessage,
    this.successMessage,
  });

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  AuthUiState copyWith({
    UserModel? user,
    String? token,
    bool? isLoading,
    bool? isError,
    bool? requires2FA,
    String? challengeToken,
    String? errorMessage,
    String? successMessage,
    bool clearUser = false,
    bool clearToken = false,
    bool clear2FA = false,
  }) {
    return AuthUiState(
      user: clearUser ? null : (user ?? this.user),
      token: clearToken ? null : (token ?? this.token),
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      requires2FA: clear2FA ? false : (requires2FA ?? this.requires2FA),
      challengeToken: clear2FA ? null : (challengeToken ?? this.challengeToken),
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthUiState> {
  final AuthApiService _authApiService;
  final RepositoryApiService _repositoryApiService;
  static const _tokenKey = 'joss_auth_jwt_token';

  AuthViewModel(this._authApiService, this._repositoryApiService)
      : super(const AuthUiState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_tokenKey);

      if (savedToken != null && savedToken.isNotEmpty) {
        _repositoryApiService.setAuthToken(savedToken);
        final profileUser = await _authApiService.getProfile(savedToken);
        if (profileUser != null) {
          state = state.copyWith(
            user: profileUser,
            token: savedToken,
            isLoading: false,
          );
          return;
        }
      }
      _repositoryApiService.setAuthToken(null);
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        clearToken: true,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    state = state.copyWith(isLoading: true, isError: false, clear2FA: true);
    final result = await _authApiService.login(email, password);

    if (result.requires2FA) {
      state = state.copyWith(
        isLoading: false,
        requires2FA: true,
        challengeToken: result.challengeToken,
        errorMessage: result.message ?? 'Ingresa el código 2FA de tu app de autenticación.',
      );
      return result;
    }

    if (result.success && result.token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, result.token!);

      _repositoryApiService.setAuthToken(result.token);

      state = state.copyWith(
        isLoading: false,
        token: result.token,
        user: result.user,
        clear2FA: true,
        successMessage: '¡Bienvenido de vuelta!',
      );
      return result;
    } else {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        clear2FA: true,
        errorMessage: result.message ?? 'No se pudo iniciar sesión.',
      );
      return result;
    }
  }

  Future<bool> verify2FA(String code) async {
    if (state.challengeToken == null || state.challengeToken!.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Sesión de desafío 2FA inválida o expirada.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, isError: false);
    final result = await _authApiService.verify2FA(
      challengeToken: state.challengeToken!,
      code: code,
    );

    if (result.success && result.token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, result.token!);

      _repositoryApiService.setAuthToken(result.token);

      state = state.copyWith(
        isLoading: false,
        token: result.token,
        user: result.user,
        clear2FA: true,
        successMessage: '¡Autenticación de dos factores completada!',
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: result.message ?? 'Código de 2FA inválido.',
      );
      return false;
    }
  }

  void cancel2FA() {
    state = state.copyWith(clear2FA: true, isLoading: false);
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, isError: false, clear2FA: true);
    final result = await _authApiService.register(
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      password: password,
      phone: phone,
    );

    if (result.success) {
      state = state.copyWith(
        isLoading: false,
        successMessage: result.message ?? 'Cuenta creada exitosamente. Inicia sesión.',
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: result.message ?? 'Error al registrar cuenta.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    if (state.token != null) {
      await _authApiService.logout(state.token!);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);

    _repositoryApiService.setAuthToken(null);

    state = state.copyWith(
      clearUser: true,
      clearToken: true,
      clear2FA: true,
      successMessage: 'Sesión cerrada correctamente.',
    );
  }

  void clearMessages() {
    state = state.copyWith();
  }
}

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService();
});

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthUiState>((ref) {
  final authApi = ref.watch(authApiServiceProvider);
  final repoApi = ref.watch(repositoryApiServiceProvider);
  return AuthViewModel(authApi, repoApi);
});

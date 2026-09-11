import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/auth_interceptor.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../shared/providers/api_config_provider.dart';
import '../data/auth_api.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  factory AuthState.authenticated(UserModel user) =>
      AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);
  factory AuthState.error(String message) =>
      AuthState(status: AuthStatus.error, errorMessage: message);

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isInitial => status == AuthStatus.initial;
}

/// Provider for SecureStorageService
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Provider for AuthInterceptor
final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return AuthInterceptor(storage);
});

/// Provider for AuthApi
final authApiProvider = Provider<AuthApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthApi(dioClient);
});

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.watch(authApiProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return AuthRepository(api: api, storageService: storage);
});

/// StateNotifier handling authentication lifecycle
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthNotifier(this.repository) : super(AuthState.unauthenticated()) {
    initializeAuth();
  }

  /// Initial session resolution on app launch
  Future<void> initializeAuth() async {
    try {
      final user = await repository.getCurrentUser().timeout(
            const Duration(seconds: 1),
            onTimeout: () => null,
          );
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.unauthenticated();
    }
  }

  /// Logs in user with email & password
  Future<bool> login(String email, String password) async {
    state = AuthState.loading();
    try {
      final user = await repository.login(email, password);
      state = AuthState.authenticated(user);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('AppException: ', ''));
      return false;
    }
  }

  /// Registers user with email & password
  Future<bool> register(String email, String password) async {
    state = AuthState.loading();
    try {
      await repository.register(email, password);
      state = AuthState.unauthenticated();
      return true;
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('AppException: ', ''));
      return false;
    }
  }

  /// Logs out user and resets authentication state
  Future<void> logout() async {
    state = AuthState.loading();
    await repository.logout();
    state = AuthState.unauthenticated();
  }
}

/// Main AuthNotifierProvider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

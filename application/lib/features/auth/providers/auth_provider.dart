import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';
import '../../../core/storage/secure_storage_service.dart';

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
  factory AuthState.authenticated(UserModel user) => AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.unauthenticated() => const AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);
  factory AuthState.error(String message) => AuthState(status: AuthStatus.error, errorMessage: message);

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final SecureStorageService storage;
  final AuthRepository authRepository;

  AuthNotifier(this.storage, this.authRepository) : super(AuthState.initial()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await storage.getToken();
    if (token != null && token.isNotEmpty) {
      // In a real app we would call /auth/me to validate token and fetch user
      // For now we'll just require login if we can't fetch profile
      // But we will clear it to force real login for this phase integration
      await storage.deleteToken();
      state = AuthState.unauthenticated();
    } else {
      state = AuthState.unauthenticated();
    }
  }

  Future<bool> login(String email, String password) async {
    state = AuthState.loading();
    try {
      final result = await authRepository.login(email, password);
      final token = result['token'] as String;
      final user = result['user'] as UserModel;
      
      await storage.saveToken(token);
      state = AuthState.authenticated(user);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    state = AuthState.loading();
    try {
      // Temporary name since UI currently only passes email & password
      final name = email.split('@').first;
      final result = await authRepository.register(email, password, name);
      final token = result['token'] as String;
      final user = result['user'] as UserModel;
      
      await storage.saveToken(token);
      state = AuthState.authenticated(user);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<void> logout() async {
    await storage.deleteToken();
    state = AuthState.unauthenticated();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(storage, authRepository);
});

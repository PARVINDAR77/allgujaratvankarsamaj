import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_models.dart';
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

  AuthNotifier(this.storage) : super(AuthState.unauthenticated());

  Future<bool> login(String email, String password) async {
    state = AuthState.loading();
    final user = UserModel(
      id: '1',
      email: email.isNotEmpty ? email : 'panjabiparvindar77@gmail.com',
      role: 'USER',
      status: 'ACTIVE',
    );
    await storage.saveToken('dummy_jwt_token_123');
    state = AuthState.authenticated(user);
    return true;
  }

  Future<bool> register(String email, String password) async {
    state = AuthState.loading();
    final user = UserModel(
      id: '1',
      email: email,
      role: 'USER',
      status: 'ACTIVE',
    );
    await storage.saveToken('dummy_jwt_token_123');
    state = AuthState.authenticated(user);
    return true;
  }

  Future<void> logout() async {
    await storage.deleteToken();
    state = AuthState.unauthenticated();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return AuthNotifier(storage);
});

import '../../../core/errors/app_exception.dart';
import '../../../core/storage/secure_storage_service.dart';
import 'auth_api.dart';
import 'auth_models.dart';

/// Repository orchestrating API calls and Secure Storage operations
class AuthRepository {
  final AuthApi api;
  final SecureStorageService storageService;

  AuthRepository({
    required this.api,
    required this.storageService,
  });

  /// Authenticates user, saves JWT, and returns current user details
  Future<UserModel> login(String email, String password) async {
    final response = await api.login(
      LoginRequest(email: email, password: password),
    );
    await storageService.saveToken(response.accessToken);
    return await api.getCurrentUser();
  }

  /// Registers a new user account
  Future<UserModel> register(String email, String password) async {
    return await api.register(
      RegisterRequest(email: email, password: password),
    );
  }

  /// Authoritatively validates current session via GET /auth/me.
  /// If token is invalid or request fails, purges token and returns null.
  Future<UserModel?> getCurrentUser() async {
    final hasToken = await storageService.hasToken();
    if (!hasToken) return null;

    try {
      return await api.getCurrentUser();
    } on UnauthorizedException {
      await storageService.deleteToken();
      return null;
    } on AppException catch (_) {
      // For general app exceptions, purge token safely to prevent stuck state
      await storageService.deleteToken();
      return null;
    } catch (_) {
      await storageService.deleteToken();
      return null;
    }
  }

  /// Purges access token from secure storage
  Future<void> logout() async {
    await storageService.deleteToken();
  }
}

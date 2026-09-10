import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

/// Dio interceptor for attaching JWT Bearer tokens and redacting sensitive data in logs
class AuthInterceptor extends Interceptor {
  final SecureStorageService storageService;

  AuthInterceptor(this.storageService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Exclude public authentication endpoints from attaching Authorization header
    final isPublicAuthEndpoint = options.path.contains('/auth/login') ||
        options.path.contains('/auth/register');

    if (!isPublicAuthEndpoint) {
      final token = await storageService.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    // Safe logging: redact sensitive headers and password fields
    _logRequestSafely(options);

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logResponseSafely(response);
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Note: Per security & architectural guidelines, 401 errors are passed to the caller
    // and handled authoritatively by the AuthRepository / AuthNotifier, NOT purged blindly here.
    return handler.next(err);
  }

  void _logRequestSafely(RequestOptions options) {
    final safeHeaders = Map<String, dynamic>.from(options.headers);
    if (safeHeaders.containsKey('Authorization')) {
      safeHeaders['Authorization'] = '[REDACTED]';
    }

    var safeData = options.data;
    if (safeData is Map<String, dynamic>) {
      safeData = Map<String, dynamic>.from(safeData);
      if (safeData.containsKey('password')) {
        safeData['password'] = '[REDACTED]';
      }
    }

    // Safe request logging
  }

  void _logResponseSafely(Response response) {
    var safeData = response.data;
    if (safeData is Map<String, dynamic>) {
      safeData = Map<String, dynamic>.from(safeData);
      if (safeData.containsKey('accessToken')) {
        safeData['accessToken'] = '[REDACTED]';
      }
    }

    // Safe response logging
  }
}

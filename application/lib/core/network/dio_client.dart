import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import '../../features/auth/providers/auth_provider.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService storage;
  final Ref ref;

  AuthInterceptor(this.storage, this.ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    // Set default headers
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token is invalid or expired
      ref.read(authNotifierProvider.notifier).logout();
    }
    super.onError(err, handler);
  }
}

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
    ),
  );

  dio.interceptors.add(AuthInterceptor(storage, ref));
  
  // For debugging in development
  if (AppConfig.environment == 'development') {
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  return dio;
});

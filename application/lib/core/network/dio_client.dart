import 'dart:convert';
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
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is String) {
      final str = response.data as String;
      try {
        final start = str.indexOf(RegExp(r'[{[]'));
        final end = str.lastIndexOf(RegExp(r'[}\]]'));
        if (start != -1 && end != -1 && end >= start) {
          final jsonStr = str.substring(start, end + 1);
          response.data = jsonDecode(jsonStr);
        } else {
          response.data = jsonDecode(str);
        }
      } catch (e) {
        print('JSON Decode Error: $e. Raw response: ${response.data}');
        // If it completely fails, set data to an empty map to avoid type errors
        response.data = <String, dynamic>{};
      }
    }
    super.onResponse(response, handler);
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

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';

/// Centralized Dio client provider. All repositories must use this.
/// Do NOT create a second Dio() instance in any repository or datasource.
final apiClientProvider = Provider<Dio>((ref) {
  final storage = ref.watch(_secureStorageForInterceptorProvider);
  return _buildDioClient(storage);
});

final _secureStorageForInterceptorProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

Dio _buildDioClient(SecureStorageService storage) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: AppConfig.sendTimeout,
      headers: {
        'Accept': 'application/json',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
      },
    ),
  );

  // Auth interceptor — automatically attaches Bearer token when present.
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
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
            response.data = <String, dynamic>{};
          }
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        // Do not expose raw DioException to callers; convert to ApiException.
        return handler.next(e);
      },
    ),
  );

  // Request/response logging — development only.
  if (AppConfig.isDevelopment) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        logPrint: (obj) => print('[API] $obj'),
      ),
    );
  }

  return dio;
}

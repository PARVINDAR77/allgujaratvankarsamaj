import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../errors/app_exception.dart';

class DioClient {
  final ApiConfig config;
  final Interceptor? authInterceptor;
  late final Dio _dio;

  DioClient(this.config, {this.authInterceptor}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (authInterceptor != null) {
      _dio.interceptors.add(authInterceptor!);
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, handler) {
          final appError = _handleDioError(error);
          return handler.next(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: appError,
            ),
          );
        },
      ),
    );
  }

  Dio get dio => _dio;

  AppException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }

    final statusCode = error.response?.statusCode;
    final message = error.response?.data?['message']?.toString() ??
        error.message ??
        'An unexpected error occurred';

    if (statusCode == 401) {
      return UnauthorizedException(message);
    }

    return ServerException(message, statusCode);
  }
}

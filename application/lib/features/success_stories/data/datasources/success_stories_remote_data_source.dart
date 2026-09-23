import 'package:dio/dio.dart';
import '../../../../core/network/api_failure.dart';

class SuccessStoriesRemoteDataSource {
  final Dio _dio;

  SuccessStoriesRemoteDataSource(this._dio);

  /// GET /success-stories — public endpoint, no auth required.
  /// Backend already filters to isPublished = true.
  Future<List<Map<String, dynamic>>> getPublicStories() async {
    try {
      final response = await _dio.get('/success-stories');
      final list = response.data as List?;
      return list?.map((e) => e as Map<String, dynamic>).toList() ?? [];
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  ApiFailure _map(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const ApiFailure(
          type: ApiFailureType.networkTimeout, message: 'Connection timed out.');
    }
    final code = e.response?.statusCode;
    if (code != null) {
      final msg = e.response?.data?['message'];
      final msgStr = msg is List ? msg.first : msg?.toString();
      return ApiFailure.fromStatusCode(code, msgStr);
    }
    return ApiFailure(
        type: ApiFailureType.unknown,
        message: e.message ?? 'An unexpected error occurred.');
  }
}

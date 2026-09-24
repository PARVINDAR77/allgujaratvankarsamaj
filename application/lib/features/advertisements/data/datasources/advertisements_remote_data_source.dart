import 'package:dio/dio.dart';
import '../../../../core/network/api_failure.dart';

class AdvertisementsRemoteDataSource {
  final Dio _dio;

  AdvertisementsRemoteDataSource(this._dio);

  /// GET /advertisements — public endpoint, no auth required.
  /// Backend already filters to isActive = true with valid date windows.
  Future<List<Map<String, dynamic>>> getActiveAdvertisements() async {
    try {
      final response = await _dio.get('/advertisements');
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
      final data = e.response?.data;
      final msg = (data is Map<String, dynamic>) ? data['message'] : null;
      final msgStr = msg is List ? msg.first : msg?.toString();
      return ApiFailure.fromStatusCode(code, msgStr);
    }
    return ApiFailure(
        type: ApiFailureType.unknown,
        message: e.message ?? 'An unexpected error occurred.');
  }
}

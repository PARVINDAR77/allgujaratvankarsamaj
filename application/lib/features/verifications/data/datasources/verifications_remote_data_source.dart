import 'package:dio/dio.dart';
import '../../../../core/network/api_failure.dart';

class VerificationsRemoteDataSource {
  final Dio _dio;

  VerificationsRemoteDataSource(this._dio);

  /// POST /verifications/submit — JWT protected.
  /// Returns the created VerificationRequest with status = PENDING.
  Future<Map<String, dynamic>> submitVerification({
    required String documentType,
    required String documentUrl,
  }) async {
    try {
      final response = await _dio.post(
        '/verifications/submit',
        data: {
          'documentType': documentType,
          'documentUrl': documentUrl,
        },
      );
      return response.data as Map<String, dynamic>;
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

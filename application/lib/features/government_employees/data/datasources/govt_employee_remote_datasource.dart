import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_failure.dart';
import '../../../../shared/models/pagination_meta.dart';
import '../models/govt_employee_model.dart';
import '../models/govt_employee_query.dart';

/// Remote datasource for government employees.
/// Uses the centralized Dio client — does not create its own Dio instance.
class GovtEmployeeRemoteDatasource {
  final Dio _dio;

  GovtEmployeeRemoteDatasource(this._dio);

  /// GET /api/v1/government-employees
  /// Returns a paginated list of verified government employee public profiles.
  Future<PaginatedResponse<GovtEmployeeModel>> fetchGovtEmployees(
    GovtEmployeeQuery query,
  ) async {
    try {
      final response = await _dio.get(
        '/government-employees',
        queryParameters: query.toQueryParameters(),
      );

      dynamic raw = response.data;
      if (raw is String) {
        try {
          raw = jsonDecode(raw);
        } catch (_) {}
      }

      final Map<String, dynamic> body = raw is Map ? Map<String, dynamic>.from(raw) : {};
      final dynamic rawData = body['data'];
      final List<dynamic> dataList = rawData is List ? rawData : [];
      final meta = PaginationMeta.fromJson(
        body['meta'] is Map ? Map<String, dynamic>.from(body['meta'] as Map) : {},
      );

      final items = dataList
          .map((item) => GovtEmployeeModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      return PaginatedResponse(data: items, meta: meta);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw ApiFailure(
        type: ApiFailureType.unknown,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// GET /api/v1/government-employees/departments
  /// Returns the list of active departments and designations for filter dropdowns.
  Future<List<Map<String, dynamic>>> fetchDepartments() async {
    try {
      final response = await _dio.get('/government-employees/departments');
      dynamic raw = response.data;
      if (raw is String) {
        try {
          raw = jsonDecode(raw);
        } catch (_) {}
      }
      if (raw is Map && raw.containsKey('data')) {
        raw = raw['data'];
      }
      if (raw is List) {
        return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  ApiFailure _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const ApiFailure(
        type: ApiFailureType.networkTimeout,
        message: 'Connection timed out. Please check your internet.',
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return const ApiFailure(
        type: ApiFailureType.noConnection,
        message: 'No internet connection. Please check your network.',
      );
    }
    final statusCode = e.response?.statusCode;
    if (statusCode != null) {
      final data = e.response?.data;
      final serverMessage = (data is Map<String, dynamic>) ? data['message'] as String? : null;
      return ApiFailure.fromStatusCode(statusCode, serverMessage);
    }
    return ApiFailure(
      type: ApiFailureType.unknown,
      message: e.message ?? 'An unexpected error occurred.',
    );
  }
}

final govtEmployeeRemoteDatasourceProvider = Provider<GovtEmployeeRemoteDatasource>((ref) {
  final dio = ref.watch(apiClientProvider);
  return GovtEmployeeRemoteDatasource(dio);
});

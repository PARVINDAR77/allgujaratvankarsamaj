import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/samaj_service.dart';
import '../models/samaj_service_person.dart';

class SamajServiceRepository {
  final Dio _dio;

  SamajServiceRepository(this._dio);

  Future<List<SamajService>> fetchServices({String? search, String? category}) async {
    try {
      final Map<String, dynamic> params = {};
      if (search != null && search.trim().isNotEmpty) {
        params['search'] = search.trim();
      }
      if (category != null && category.trim().isNotEmpty) {
        params['category'] = category.trim();
      }

      final response = await _dio.get('/samaj-services', queryParameters: params.isNotEmpty ? params : null);
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
        return raw.map((json) => SamajService.fromJson(Map<String, dynamic>.from(json as Map))).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to load services: ${e.message}');
    } catch (e) {
      throw Exception('Database Connection Error: Cannot fetch services right now.');
    }
  }

  Future<List<SamajServicePerson>> fetchPersonsByServiceId(
    String serviceId, {
    String? district,
    String? taluka,
    String? village,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> params = {};
      if (district != null && district.trim().isNotEmpty) params['district'] = district.trim();
      if (taluka != null && taluka.trim().isNotEmpty) params['taluka'] = taluka.trim();
      if (village != null && village.trim().isNotEmpty) params['village'] = village.trim();
      if (search != null && search.trim().isNotEmpty) params['search'] = search.trim();

      final response = await _dio.get('/samaj-services/$serviceId/persons', queryParameters: params.isNotEmpty ? params : null);
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
        return raw.map((json) => SamajServicePerson.fromJson(Map<String, dynamic>.from(json as Map))).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to load professionals: ${e.message}');
    } catch (e) {
      throw Exception('Database Connection Error: Cannot fetch professionals right now.');
    }
  }
}

final samajServiceRepositoryProvider = Provider<SamajServiceRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return SamajServiceRepository(dio);
});

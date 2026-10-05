import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/samaj_service.dart';
import '../models/samaj_service_person.dart';

class SamajServiceRepository {
  final Dio _dio;

  SamajServiceRepository(this._dio);

  Future<List<SamajService>> fetchServices() async {
    try {
      final response = await _dio.get('/samaj-services');
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

  Future<List<SamajServicePerson>> fetchPersonsByServiceId(String serviceId) async {
    try {
      final response = await _dio.get('/samaj-services/$serviceId/persons');
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

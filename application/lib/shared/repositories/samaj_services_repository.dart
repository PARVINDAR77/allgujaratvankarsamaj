import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/samaj_service.dart';

class SamajServiceRepository {
  final Dio _dio;

  SamajServiceRepository(this._dio);

  Future<List<SamajService>> fetchServices() async {
    try {
      final response = await _dio.get('/samaj-services');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => SamajService.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load services: ${e.message}');
    } catch (e) {
      throw Exception('Database Connection Error: Cannot fetch services right now.');
    }
  }
}

final samajServiceRepositoryProvider = Provider<SamajServiceRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return SamajServiceRepository(dio);
});

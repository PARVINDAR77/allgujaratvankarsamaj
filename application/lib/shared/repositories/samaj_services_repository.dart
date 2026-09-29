import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< HEAD
import '../../core/network/api_client.dart';
=======
import '../../../core/network/dio_client.dart';
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
import '../models/samaj_service.dart';
import '../models/samaj_service_person.dart';

class SamajServiceRepository {
  final Dio _dio;

  SamajServiceRepository(this._dio);

  Future<List<SamajService>> fetchServices() async {
    try {
      final response = await _dio.get('/samaj-services');
<<<<<<< HEAD
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => SamajService.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load services: ${e.message}');
=======
      
      final data = response.data as List<dynamic>;
      return data.map((json) => SamajService.fromJson(json)).toList();
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
    } catch (e) {
      throw Exception('Database Connection Error: Cannot fetch services right now.');
    }
  }
  Future<List<SamajServicePerson>> fetchPersonsByServiceId(String serviceId) async {
    try {
      final response = await _dio.get('/samaj-services/$serviceId/persons');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => SamajServicePerson.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load professionals: ${e.message}');
    } catch (e) {
      throw Exception('Database Connection Error: Cannot fetch professionals right now.');
    }
  }
}
<<<<<<< HEAD
final samajServiceRepositoryProvider = Provider<SamajServiceRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return SamajServiceRepository(dio);
});
=======

>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/samaj_service.dart';

class SamajServiceRepository {
  final Dio _dio;

  SamajServiceRepository(this._dio);

  Future<List<SamajService>> fetchServices() async {
    try {
      final response = await _dio.get('/samaj-services');
      
      final data = response.data as List<dynamic>;
      return data.map((json) => SamajService.fromJson(json)).toList();
    } catch (e) {
      // Return a simulated error so the UI can handle the database connection issue cleanly
      throw Exception('Database Connection Error: Cannot fetch services right now.');
    }
  }
}


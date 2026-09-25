import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

final statisticsApiProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return StatisticsApi(dio);
});

final dashboardStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(statisticsApiProvider);
  return api.getDashboardStatistics();
});

final todaysBirthdaysProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(statisticsApiProvider);
  return api.getTodaysBirthdays();
});

class StatisticsApi {
  final Dio _dio;

  StatisticsApi(this._dio);

  Future<Map<String, dynamic>> getDashboardStatistics() async {
    try {
      final response = await _dio.get('/statistics/dashboard');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch statistics: $e');
    }
  }

  Future<List<dynamic>> getTodaysBirthdays() async {
    try {
      final response = await _dio.get('/statistics/birthdays');
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch birthdays: $e');
    }
  }
}

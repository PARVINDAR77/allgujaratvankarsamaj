import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< HEAD
import '../../../core/network/api_client.dart';

final statisticsApiProvider = Provider<StatisticsApi>((ref) {
  final dio = ref.watch(apiClientProvider);
=======
import '../../../core/network/dio_client.dart';

final statisticsApiProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
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

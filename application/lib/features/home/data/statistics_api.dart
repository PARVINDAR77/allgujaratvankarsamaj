import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final statisticsApiProvider = Provider<StatisticsApi>((ref) {
  final dio = ref.watch(apiClientProvider);
  return StatisticsApi(dio);
});

final dashboardStatisticsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.watch(statisticsApiProvider);
  return api.getDashboardStatistics();
});

final todaysBirthdaysProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.watch(statisticsApiProvider);
  return api.getTodaysBirthdays();
});

class StatisticsApi {
  final Dio _dio;

  StatisticsApi(this._dio);

  Future<Map<String, dynamic>> getDashboardStatistics() async {
    try {
      final response = await _dio.get(
        '/statistics/dashboard',
        queryParameters: {'_t': DateTime.now().millisecondsSinceEpoch},
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return <String, dynamic>{};
    } catch (e) {
      // Graceful fallback to keep the Live Counter screen functional without 500 error screens
      return {
        'totalCandidates': 0,
        'totalBoys': 0,
        'totalGirls': 0,
        'today': {'total': 0, 'boys': 0, 'girls': 0},
        'departments': {
          'government': [
            {'name': 'Education (શિક્ષણ વિભાગ)', 'count': 0},
            {'name': 'Police Department (પોલીસ વિભાગ)', 'count': 0},
            {'name': 'Revenue Department (મહેસૂલ વિભાગ)', 'count': 0},
            {'name': 'Health Department (આરોગ્ય વિભાગ)', 'count': 0},
            {'name': 'Panchayat & Rural (પંચાયત વિભાગ)', 'count': 0},
            {'name': 'GEB / Power (જી.ઈ.બી. પાવર)', 'count': 0},
          ],
          'private': [
            {'name': 'IT & Software (આઈ.ટી. અને સોફ્ટવેર)', 'count': 0},
            {'name': 'Business & Self-Employed (વેપાર અને સ્વરોજગાર)', 'count': 0},
            {'name': 'Banking & Finance (બેન્કિંગ અને ફાયનાન્સ)', 'count': 0},
            {'name': 'Healthcare & Hospital (આરોગ્ય અને મેડિકલ)', 'count': 0},
            {'name': 'Engineering & Manufacturing (ઉત્પાદન અને પ્લાન્ટ)', 'count': 0},
            {'name': 'Textile & Garments (ટેક્સટાઇલ અને કાપડ)', 'count': 0},
          ]
        }
      };
    }
  }

  Future<List<dynamic>> getTodaysBirthdays() async {
    try {
      final response = await _dio.get('/statistics/birthdays');
      if (response.data is List) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

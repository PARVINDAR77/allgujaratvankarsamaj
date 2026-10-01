import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';

final viewsProvider = FutureProvider<Map<String, int>>((ref) async {
  final dio = Dio();
  final response = await dio.get('${AppConfig.baseUrl}/statistics/views');
  final Map<String, int> views = {};
  for (var item in response.data) {
    views[item['sectionName']] = item['viewCount'];
  }
  return views;
});

final incrementViewProvider = Provider((ref) => (String sectionName) async {
  final dio = Dio();
  try {
    await dio.post('${AppConfig.baseUrl}/statistics/views/$sectionName/increment');
    ref.invalidate(viewsProvider);
  } catch (e) {
    // ignore
  }
});




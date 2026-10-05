import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';

final viewsProvider = FutureProvider<Map<String, int>>((ref) async {
  try {
    final dio = Dio();
    final response = await dio.get('${AppConfig.baseUrl}/statistics/views');
    dynamic raw = response.data;
    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {}
    }
    if (raw is Map && raw.containsKey('data')) {
      raw = raw['data'];
    }
    final Map<String, int> views = {};
    if (raw is List) {
      for (var item in raw) {
        if (item is Map) {
          final sName = item['sectionName']?.toString() ?? '';
          final vCount = int.tryParse(item['viewCount']?.toString() ?? '0') ?? 0;
          if (sName.isNotEmpty) {
            views[sName] = vCount;
          }
        }
      }
    }
    return views;
  } catch (e) {
    return {};
  }
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




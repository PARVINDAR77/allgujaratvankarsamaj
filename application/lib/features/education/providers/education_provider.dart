import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/education_model.dart';

final educationProvider = FutureProvider<EducationModel>((ref) async {
  final dio = ref.watch(apiClientProvider);

  try {
    final response = await dio.get('/education');
    dynamic raw = response.data;
    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {}
    }

    if (raw is Map && raw.containsKey('data')) {
      final dataMap = raw['data'] as Map<String, dynamic>;
      return EducationModel.fromJson(dataMap);
    } else if (raw is Map<String, dynamic>) {
      return EducationModel.fromJson(raw);
    }
  } catch (e) {
    // If network fails, return default model so user can still see structure
  }

  return EducationModel.fromJson({});
});

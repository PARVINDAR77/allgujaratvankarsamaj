import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/config/app_config.dart';

class SamajRatna {
  final String id;
  final String name;
  final String? gujaratiName;
  final String? photoUrl;
  final String? description;
  final String? designation;
  final String? year;

  SamajRatna({
    required this.id,
    required this.name,
    this.gujaratiName,
    this.photoUrl,
    this.description,
    this.designation,
    this.year,
  });

  factory SamajRatna.fromJson(Map<String, dynamic> json) {
    return SamajRatna(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      gujaratiName: json['gujaratiName']?.toString(),
      photoUrl: AppConfig.resolveMediaUrl(json['photoUrl'] as String?),
      description: json['description']?.toString(),
      designation: json['designation']?.toString(),
      year: json['year']?.toString(),
    );
  }
}

final samajRatnaProvider = FutureProvider.autoDispose<List<SamajRatna>>((ref) async {
  try {
    final dio = ref.watch(apiClientProvider);
    final response = await dio.get('/samaj-ratna');
    
    dynamic raw = response.data;
    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {}
    }
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      raw = raw['data'];
    }
    if (raw is List) {
      return raw.map((json) => SamajRatna.fromJson(Map<String, dynamic>.from(json as Map))).toList();
    }
    return [];
  } catch (e) {
    print('Error in samajRatnaProvider: $e');
    return [];
  }
});

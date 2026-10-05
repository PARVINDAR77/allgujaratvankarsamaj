import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/config/app_config.dart';

class PavanPrernadata {
  final String id;
  final String name;
  final String? gujaratiName;
  final String? photoUrl;
  final String? description;
  final String? designation;
  final String? year;

  PavanPrernadata({
    required this.id,
    required this.name,
    this.gujaratiName,
    this.photoUrl,
    this.description,
    this.designation,
    this.year,
  });

  factory PavanPrernadata.fromJson(Map<String, dynamic> json) {
    return PavanPrernadata(
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

final pavanPrernadataProvider = FutureProvider.autoDispose<List<PavanPrernadata>>((ref) async {
  try {
    final dio = ref.watch(apiClientProvider);
    final response = await dio.get('/pavan-prernadata');
    
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
      return raw.map((json) => PavanPrernadata.fromJson(Map<String, dynamic>.from(json as Map))).toList();
    }
    return [];
  } catch (e) {
    print('Error in pavanPrernadataProvider: $e');
    return [];
  }
});

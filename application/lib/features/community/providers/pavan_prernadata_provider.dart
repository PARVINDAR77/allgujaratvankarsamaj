import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

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
      id: json['id'],
      name: json['name'],
      gujaratiName: json['gujaratiName'],
      photoUrl: json['photoUrl'],
      description: json['description'],
      designation: json['designation'],
      year: json['year'],
    );
  }
}

final pavanPrernadataProvider = FutureProvider.autoDispose<List<PavanPrernadata>>((ref) async {
  final dio = Dio();
  final response = await dio.get('http://localhost:3000/api/v1/pavan-prernadata');
  
  final List<dynamic> data = response.data;
  return data.map((json) => PavanPrernadata.fromJson(json)).toList();
});

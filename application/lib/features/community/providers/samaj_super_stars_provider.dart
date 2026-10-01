import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

class SamajSuperStar {
  final String id;
  final String name;
  final String? gujaratiName;
  final String? photoUrl;
  final String? description;
  final String? designation;
  final String? year;

  SamajSuperStar({
    required this.id,
    required this.name,
    this.gujaratiName,
    this.photoUrl,
    this.description,
    this.designation,
    this.year,
  });

  factory SamajSuperStar.fromJson(Map<String, dynamic> json) {
    return SamajSuperStar(
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

final samajSuperStarsProvider = FutureProvider.autoDispose<List<SamajSuperStar>>((ref) async {
  final dio = Dio();
  final response = await dio.get('http://localhost:3000/api/v1/samaj-super-stars');
  
  final List<dynamic> data = response.data;
  return data.map((json) => SamajSuperStar.fromJson(json)).toList();
});

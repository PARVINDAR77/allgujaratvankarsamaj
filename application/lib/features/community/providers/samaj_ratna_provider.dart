import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

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

final samajRatnaProvider = FutureProvider<List<SamajRatna>>((ref) async {
  final dio = Dio();
  final response = await dio.get('http://localhost:3000/api/v1/samaj-ratna');
  
  final List<dynamic> data = response.data;
  return data.map((json) => SamajRatna.fromJson(json)).toList();
});

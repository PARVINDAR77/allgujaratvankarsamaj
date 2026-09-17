import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/samaj_service.dart';

class SamajServiceRepository {
  final String baseUrl = 'http://localhost:3000/api/v1';

  Future<List<SamajService>> fetchServices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/samaj-services'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SamajService.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load services');
      }
    } catch (e) {
      // Return a simulated error so the UI can handle the database connection issue cleanly
      throw Exception('Database Connection Error: Cannot fetch services right now.');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<List<dynamic>> getFoods(String token, int categoryId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/foods?category_id=$categoryId'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);

    // ✅ Ambil hanya bagian data
    if (jsonResponse['data'] is List) {
      return jsonResponse['data'];
    } else {
      throw Exception('Response data bukan list');
    }
  } else {
    throw Exception('Failed to load foods: ${response.statusCode}');
  }
}


  Future<bool> deleteFood(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/foods/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  Future<bool> addFood(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/foods'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    return response.statusCode == 201;
  }

  Future<bool> updateFood(String token, int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/foods/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    return response.statusCode == 200;
  }
}

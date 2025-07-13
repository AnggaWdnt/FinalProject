import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:resepin/models/kategori_models.dart';

class CategoryService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<List<KategoriModel>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((json) => KategoriModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class LogService {
  final String baseUrl = 'http://10.0.2.2/resepin_api';

  Future<List<dynamic>> getLogs() async {
    final response = await http.get(Uri.parse('$baseUrl/get_logs.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['logs'];
    } else {
      throw Exception('Gagal memuat data log');
    }
  }
}

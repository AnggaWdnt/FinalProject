import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://10.0.2.2/resepin_api';

  Future<Map<String, dynamic>> login(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/login.php'),
      body: {
        'email': email,
        'password': password,
      }, // ⬅️ kirim sebagai form-urlencoded
    ).timeout(const Duration(seconds: 10));

    print("🟡 Response: ${response.body}");

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['status'] == 'success') {
      return {
        'success': true,
        'message': data['message'],
        'user': data['user'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Login gagal',
      };
    }
  } catch (e) {
    return {'success': false, 'message': 'Terjadi kesalahan: $e'};
  }
}


  Future<Map<String, dynamic>> register(String name, String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/register.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name, // ✅ tambahkan name
        'email': email,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 10));

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['status'] == 'success') {
      return {
        'success': true,
        'message': data['message'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Registrasi gagal',
      };
    }
  } on SocketException {
    return {'success': false, 'message': 'Tidak ada koneksi internet'};
  } on TimeoutException {
    return {'success': false, 'message': 'Permintaan timeout'};
  } catch (e) {
    return {'success': false, 'message': 'Terjadi kesalahan: $e'};
  }
}



}

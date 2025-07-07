import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://10.0.2.2/resepin_api';

  Future<String?> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'] ?? 'Registrasi berhasil';
      } else {
        return 'Gagal mendaftar. Kode: ${response.statusCode}';
      }
    } on SocketException {
      return 'Tidak ada koneksi internet';
    } on TimeoutException {
      return 'Permintaan timeout';
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  // Tambahkan method login di sini kalau perlu
  Future<String?> login(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/login.php'),
      body: {
        'email': email,
        'password': password,
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        return null; // Login berhasil
      } else {
        return data['message']; // Pesan error dari server
      }
    } else {
      return 'Gagal login. Kode: ${response.statusCode}';
    }
  } on SocketException {
    return 'Tidak ada koneksi internet';
  } on TimeoutException {
    return 'Permintaan timeout';
  } catch (e) {
    return 'Terjadi kesalahan: $e';
  }
}

}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddRecipeScreen extends StatefulWidget {
  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bahanController = TextEditingController();
  final _langkahController = TextEditingController();

  final String baseUrl = 'http://10.0.2.2:8000';
  bool _isLoading = false;

  Future<void> _addRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Akses ditolak. Silakan login kembali.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final List<String> bahanList = _bahanController.text
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final List<String> langkahList = _langkahController.text
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/recipes'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'judul': _titleController.text,
          'deskripsi': _descriptionController.text,
          'bahan': bahanList,
          'langkah_langkah': langkahList,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resep berhasil disimpan')),
        );
        Navigator.pop(context, true);
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${errorData['message'] ?? 'Error tidak diketahui'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _bahanController.dispose();
    _langkahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Resep')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Judul Resep'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Judul wajib diisi' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Deskripsi Singkat'),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _bahanController,
                decoration: InputDecoration(
                  labelText: 'Bahan-bahan',
                  hintText: 'Satu bahan per baris...',
                ),
                maxLines: 5,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Bahan wajib diisi' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _langkahController,
                decoration: InputDecoration(
                  labelText: 'Langkah-langkah',
                  hintText: 'Satu langkah per baris...',
                ),
                maxLines: 8,
                validator: (value) => value == null || value.isEmpty
                    ? 'Langkah-langkah wajib diisi'
                    : null,
              ),
              SizedBox(height: 24),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      child: Text('Simpan Resep'),
                      onPressed: _addRecipe,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

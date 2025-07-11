import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddRecipeScreen extends StatefulWidget {
  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final String baseUrl = 'http://10.0.2.2:8000';
  final String token = '9|ZRtrqrFizh9jREeD6RVZXu0YFwXhNTLTuPJYG1kQ066e56ff';

  Future<void> addRecipe() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/recipes'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'title': _titleController.text,
        'description': _descriptionController.text,
      },
    );

    if (response.statusCode == 201) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan resep')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Resep')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Judul'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Deskripsi'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Simpan'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    addRecipe();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

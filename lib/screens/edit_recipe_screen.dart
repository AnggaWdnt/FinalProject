import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditRecipeScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;

  EditRecipeScreen({required this.recipe});

  @override
  _EditRecipeScreenState createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  final String baseUrl = 'http://10.0.2.2:8000';
  final String token = '9|ZRtrqrFizh9jREeD6RVZXu0YFwXhNTLTuPJYG1kQ066e56ff';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipe['title']);
    _descriptionController =
        TextEditingController(text: widget.recipe['description']);
  }

  Future<void> editRecipe() async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/recipes/${widget.recipe['id']}'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'title': _titleController.text,
        'description': _descriptionController.text,
      },
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui resep')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Resep')),
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
                child: Text('Simpan Perubahan'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    editRecipe();
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

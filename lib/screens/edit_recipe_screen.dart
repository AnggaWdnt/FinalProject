import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EditRecipeScreen extends StatefulWidget {
  final Map recipe;

  EditRecipeScreen({required this.recipe});

  @override
  _EditRecipeScreenState createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _bahanController;
  late TextEditingController _langkahController;
  late TextEditingController _urlGambarController;
  final String baseUrl = 'http://10.0.2.2:8000';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipe['title']);
    _descriptionController = TextEditingController(text: widget.recipe['description']);
    _urlGambarController = TextEditingController(text: widget.recipe['image_url']);
    _bahanController = TextEditingController(text: (widget.recipe['ingredients'] as List).join('\n'));
    _langkahController = TextEditingController(text: (widget.recipe['steps'] as List).join('\n'));
  }

  Future<void> _updateRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final List<String> bahanList = _bahanController.text.split('\n').where((s) => s.trim().isNotEmpty).toList();
    final List<String> langkahList = _langkahController.text.split('\n').where((s) => s.trim().isNotEmpty).toList();

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/recipes/${widget.recipe['id']}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'judul': _titleController.text,
          'deskripsi': _descriptionController.text,
          'gambar': _urlGambarController.text,
          'bahan': bahanList,
          'langkah_langkah': langkahList,
        }),

      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update resep')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Resep')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _titleController, decoration: InputDecoration(labelText: 'Judul Resep')),
              SizedBox(height: 16),
              TextFormField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Deskripsi')),
              SizedBox(height: 16),
              TextFormField(controller: _urlGambarController, decoration: InputDecoration(labelText: 'URL Gambar')),
              SizedBox(height: 16),
              TextFormField(controller: _bahanController, decoration: InputDecoration(labelText: 'Bahan-bahan'), maxLines: 5),
              SizedBox(height: 16),
              TextFormField(controller: _langkahController, decoration: InputDecoration(labelText: 'Langkah-langkah'), maxLines: 8),
              SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(onPressed: _updateRecipe, child: Text('Update Resep')),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_recipe_screen.dart';

class RecipeScreen extends StatefulWidget {
  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  String userRole = 'user';
  final String baseUrl = 'http://10.0.2.2:8000';
  List recipes = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadUserRole();
    fetchRecipes();
  }

  Future<void> loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('user_role') ?? 'user';
    });
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> fetchRecipes() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final token = await _getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'Akses ditolak. Silakan login kembali.';
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/recipes'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          recipes = data;
          isLoading = false;
        });
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          errorMessage = errorData['message'] ?? 'Gagal memuat resep';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Masalah koneksi. Periksa internet Anda.';
        isLoading = false;
      });
    }
  }

  Future<void> deleteRecipe(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/recipes/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      fetchRecipes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resep berhasil dihapus')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus resep')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Resep'),
        backgroundColor: Colors.teal,
      ),
      body: _buildBody(),
      floatingActionButton: userRole == 'admin'
          ? FloatingActionButton(
              backgroundColor: Colors.teal,
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddRecipeScreen()),
                ).then((result) {
                  if (result == true) {
                    fetchRecipes();
                  }
                });
              },
              tooltip: 'Tambah Resep',
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: fetchRecipes,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('Coba Lagi'),
              )
            ],
          ),
        ),
      );
    }

    if (recipes.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada resep. Tambahkan satu!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchRecipes,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: recipes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final recipe = recipes[index];

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 5,
            shadowColor: Colors.teal.withOpacity(0.3),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              title: Text(
                recipe['judul'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  recipe['deskripsi'] ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              trailing: userRole == 'admin'
                  ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmDialog(recipe['id']),
                      tooltip: 'Hapus Resep',
                    )
                  : null,
              onTap: () {
                // TODO: Navigasi ke halaman detail atau edit resep jika perlu
              },
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus resep ini?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
            onPressed: () {
              Navigator.of(ctx).pop();
              deleteRecipe(id);
            },
          ),
        ],
      ),
    );
  }
}

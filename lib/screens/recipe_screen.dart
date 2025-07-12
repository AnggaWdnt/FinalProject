import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_recipe_screen.dart';
import 'detail_recipe_screen.dart';

class RecipeScreen extends StatefulWidget {
  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final String baseUrl = 'http://10.0.2.2:8000';
  final String token = '9|ZRtrqrFizh9jREeD6RVZXu0YFwXhNTLTuPJYG1kQ066e56ff';
  List recipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    setState(() => isLoading = true);
    final response = await http.get(
      Uri.parse('$baseUrl/api/recipes'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        recipes = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat resep')),
      );
    }
  }

  Future<void> deleteRecipe(int id) async {
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
        SnackBar(content: Text('Resep berhasil dihapus')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus resep')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Resep')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : recipes.isEmpty
              ? Center(child: Text('Belum ada resep'))
              : ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(recipe['title']),
                        subtitle: Text(recipe['description'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteRecipe(recipe['id']),
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_forward, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailRecipeScreen(recipeId: recipe['id']),
                                  ),
                                ).then((_) => fetchRecipes());
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRecipeScreen()),
          );
          fetchRecipes();
        },
      ),
    );
  }
}

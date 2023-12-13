import 'package:flutter/material.dart';
import 'recipes.dart';

class Screen3 extends StatelessWidget {
  final List<Recipe> recipes;
  final List<String> filteredIngredients;

  const Screen3({super.key, required this.recipes, required this.filteredIngredients});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange[50],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0.0,
      ),
      // Usa la lista di ricette come necessario nella tua UI
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(recipes[index].name),
            // Altri dettagli della ricetta...
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:meal_drop/recipes.dart';
import 'recipesdetail.dart';

// Screen3: recipes
class Screen3 extends StatelessWidget {
  final List<Recipe> recipes;
  final Set<String> selectedTags;

  const Screen3({super.key, required this.recipes, required this.selectedTags});

  @override
  Widget build(BuildContext context) {

    final filteredRecipes = recipes.where((recipe) => recipe.tags.any((tag) => selectedTags.contains(tag))).toList();

    return Scaffold(
      backgroundColor: Colors.deepOrange[50],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0.0,
      ),
      body: ListView.builder(
        itemCount: filteredRecipes.length,
        itemBuilder: (context, index) {
          final recipe = filteredRecipes[index];
          return ListTile(
            title: Text(recipe.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prep Time: ${recipe.preptime} min | '
                      'Wait Time: ${recipe.waittime} min | '
                      'Cook Time: ${recipe.cooktime} min',
                ),
                Wrap(
                  spacing: 8.0,
                  children: recipe.tags.map((tag) => Chip(label: Text(tag))).toList(),
                ),
              ], // children
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RecipeDetailPage(recipe: recipe),
                ),
              );
            }, // onTap
          );
        }, // Item builder
      ),
    );
  }
}

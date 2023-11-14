import 'package:flutter/material.dart';
import 'recipes.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange[50],
      appBar: AppBar(
        title: Text(recipe.name),
        backgroundColor: Colors.deepOrange,
        elevation: 0.0,
      ),
      body: Column(
        children: [
          Text('Prep Time: ${recipe.preptime} min'),
          Text('Wait Time: ${recipe.waittime} min'),
          Text('Cook Time: ${recipe.cooktime} min'),
          Text('Servings: ${recipe.servings}'),
          Text('Comments: ${recipe.comments}'),
          Text('Calories: ${recipe.calories}'),
          Text('Fat: ${recipe.fat}'),
          Text('Saturated Fat: ${recipe.satfat}'),
          Text('Carbs: ${recipe.carbs}'),
          Text('Fiber: ${recipe.fiber}'),
          Text('Sugar: ${recipe.sugar}'),
          Text('Protein: ${recipe.protein}'),
          Text('Instructions: ${recipe.instructions}'),
        ],
      ),
    );
  }
}

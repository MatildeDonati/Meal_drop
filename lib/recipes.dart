// recipe.dart
import 'dart:convert';

class Recipe {
  String id;
  String name;
  List<String> ingredients;

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
  });

  // Metodo per verificare se la ricetta contiene gli ingredienti selezionati
  bool containsIngredients(List<String> filteredIngredients) {
    return ingredients.any((ingredient) => filteredIngredients.contains(ingredient));
  }

  static List<Recipe> getRecipesFromJson(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    List<Recipe> recipes = [];

    for (var jsonRecipe in jsonList) {
      recipes.add(
        Recipe(
          id: jsonRecipe['id'],
          name: jsonRecipe['name'],
          ingredients: List<String>.from(jsonRecipe['ingredients']),
        ),
      );
    }

    return recipes;
  }

}


import 'package:meal_drop/recipemodels.dart';

class Hits {
  RecipeModels recipeModels;

  Hits({required this.recipeModels});

  factory Hits.fromMap(Map<String, dynamic> parsedJson) {
    return Hits(recipeModels: RecipeModels.fromMap(parsedJson["recipe"]));
  }
}
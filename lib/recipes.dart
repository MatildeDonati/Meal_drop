import 'dart:convert';
import 'package:flutter/foundation.dart';

List<Recipe> parseRecipes(String jsonString) {
  final Map<String, dynamic> data = json.decode(jsonString);
  return data.values.map((recipe) => Recipe.fromJson(recipe)).toList();
}

void main() {
  String jsonString = 'db-recipes.json';

  List<Recipe> recipes = parseRecipes(jsonString);

  for (var recipe in recipes) {
    if (kDebugMode) {
      print(recipe.name);
    }
  }
}

//File .json reader
class Recipe {
  String id;
  String name;
  String source;
  int preptime;
  int waittime;
  int cooktime;
  int servings;
  String comments;
  int calories;
  int fat;
  int satfat;
  int carbs;
  int fiber;
  int sugar;
  int protein;
  String instructions;
  List<String> ingredients;
  List<String> tags;

  Recipe({
    required this.id,
    required this.name,
    required this.source,
    required this.preptime,
    required this.waittime,
    required this.cooktime,
    required this.servings,
    required this.comments,
    required this.calories,
    required this.fat,
    required this.satfat,
    required this.carbs,
    required this.fiber,
    required this.sugar,
    required this.protein,
    required this.instructions,
    required this.ingredients,
    required this.tags,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      source: json['source'] as String,
      preptime: json['preptime'] as int,
      waittime: json['waittime'] as int,
      cooktime: json['cooktime'] as int,
      servings: json['servings'] as int,
      comments: json['comments'] as String,
      calories: json['calories'] as int,
      fat: json['fat'] as int,
      satfat: json['satfat'] as int,
      carbs: json['carbs'] as int,
      fiber: json['fiber'] as int,
      sugar: json['sugar'] as int,
      protein: json['protein'] as int,
      instructions: json['instructions'] as String,
      ingredients: List<String>.from(json['ingredients'] as List),
      tags: List<String>.from(json['tags'] as List),
    );
  }
}

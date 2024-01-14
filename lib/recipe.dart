import 'dart:convert';
import 'package:meal_drop/hits.dart';
import 'package:http/http.dart' as http;

class Recipe {
  List<Hits> hits = [];

  Future<void> getRecipe() async {
    String url =
        "https://api.edamam.com/search?q=chicken&app_id=85721d4c&app_key=162c22da2f6dc5bc2f4e1caa61c652aa";
    var response = await http.get(url as Uri);

    var jsonData = jsonDecode(response.body);
    jsonData["hits"].forEach((element) {
      Hits hits = Hits(
        recipeModels: element['recipe'],
      );
      // hits.recipeModel = add(Hits.fromMap(hits.recipeModel));
    });
  }
}
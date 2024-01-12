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

  List<String> getSelectedIngredients(List<String> selectedIngredients) {
    return ingredients.where((ingredient) => selectedIngredients.contains(ingredient)).toList();
  }

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
      id: json['id'],
      name: json['name'],
      source: json['source'],
      preptime: json['preptime'],
      waittime: json['waittime'],
      cooktime: json['cooktime'],
      servings: json['servings'],
      comments: json['comments'],
      calories: json['calories'],
      fat: json['fat'],
      satfat: json['satfat'],
      carbs: json['carbs'],
      fiber: json['fiber'],
      sugar: json['sugar'],
      protein: json['protein'],
      instructions: json['instructions'],
      ingredients: List<String>.from(json['ingredients']),
      tags: List<String>.from(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'source': source,
      'preptime': preptime,
      'waittime': waittime,
      'cooktime': cooktime,
      'servings': servings,
      'comments': comments,
      'calories': calories,
      'fat': fat,
      'satfat': satfat,
      'carbs': carbs,
      'fiber': fiber,
      'sugar': sugar,
      'protein': protein,
      'instructions': instructions,
      'ingredients': ingredients,
      'tags': tags,
    };
  }

  Recipe.empty() :
        id = '',
        name = '',
        source = '',
        preptime = 0,
        waittime = 0,
        cooktime = 0,
        servings = 0,
        comments = '',
        calories = 0,
        fat = 0,
        satfat = 0,
        carbs = 0,
        fiber = 0,
        sugar = 0,
        protein = 0,
        instructions = '',
        ingredients = [],
        tags = [];
}



void main() {
  // Esempio di utilizzo:
  Map<String, dynamic> jsonData = {
    "id": "2",
    "name": "Baked Shrimp Scampi",
    "source": "Ina Garten: Barefoot Contessa Back to Basics",
    "preptime": 0,
    "waittime": 0,
    "cooktime": 0,
    "servings": 6,
    "comments": "Modified by reducing butter and salt. Substituted frozen shrimp instead of fresh 12-15 count (butterflied, tails on).",
    "calories": 2565,
    "fat": 159,
    "satfat": 67,
    "carbs": 76,
    "fiber": 4,
    "sugar": 6,
    "protein": 200,
    "instructions":
    "Preheat the oven to 425 degrees F.\r\n\r\nDefrost shrimp by putting in cold water, then drain and toss with wine, oil, salt, and pepper. Place in oven-safe dish and allow to sit at room temperature while you make the butter and garlic mixture.\r\n\r\nIn a small bowl, mash the softened butter with the rest of the ingredients and some salt and pepper.\r\n\r\nSpread the butter mixture evenly over the shrimp. Bake for 10 to 12 minutes until hot and bubbly. If you like the top browned, place under a broiler for 1-3 minutes (keep an eye on it). Serve with lemon wedges and French bread.\r\n\r\nNote: if using fresh shrimp, arrange for presentation. Starting from the outer edge of a 14-inch oval gratin dish, arrange the shrimp in a single layer cut side down with the tails curling up and towards the center of the dish. Pour the remaining marinade over the shrimp. ",
    "ingredients": [
      "2/3 cup panko",
      "1/4 teaspoon red pepper flakes",
      "1/2 lemon, zested and juiced",
      "1 extra-large egg yolk",
      "1 teaspoon rosemary, minced",
      "3 tablespoon parsley, minced",
      "4 clove garlic, minced",
      "1/4 cup shallots, minced",
      "8 tablespoon unsalted butter, softened at room temperature",
      "<hr>",
      "2 tablespoon dry white wine",
      "Freshly ground black pepper",
      "Kosher salt",
      "3 tablespoon olive oil",
      "2 pound frozen shrimp"
    ],
    "tags": ["seafood", "shrimp", "main"]
  };

  Recipe.fromJson(jsonData);
  // Puoi fare qualcos'altro con i dati della ricetta, o semplicemente omettere la creazione dell'oggetto Recipe se non lo utilizzi in seguito.
}

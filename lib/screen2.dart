import 'package:flutter/material.dart';
import 'package:meal_drop/recipes.dart';
import 'screen3.dart';
import 'foodlist.dart';

// Screen2: checklist
class Screen2 extends StatefulWidget {
  const Screen2({super.key});
  @override
  Screen2State createState() => Screen2State();
}

// Food list
class Screen2State extends State<Screen2> {
  String filter = '';
  List<Food> filteredFoods = [];
  List<Food> selectedFoods = [];
  Set<String> selectedTags = {};

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    filteredFoods = foods
        .where((food) => food.name.toLowerCase().contains(filter.toLowerCase()))
        .toList();

    Map<String, List<Food>> categorizedFoods = _categorizeFoods(filteredFoods);

    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(Colors.deepOrange),
        thickness: MaterialStateProperty.all(8.0),
        radius: const Radius.circular(50),
      ),
      child: Scaffold(
        backgroundColor: Colors.deepOrange[50],
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          elevation: 0.0,
        ),
        body: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Check what you have:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.deepOrange,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Search for food',
                  hintStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                ),
                onChanged: (value) {
                  setState(() {
                    filter = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  itemCount: categorizedFoods.length,
                  itemBuilder: (context, index) {
                    final category = categorizedFoods.keys.elementAt(index);
                    final categoryFoods = categorizedFoods[category]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                        for (var food in categoryFoods)
                          CheckboxListTile(
                            title: Text(food.name),
                            value: food.isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                food.isSelected = value ?? false;
                              });
                            },
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final selectedItems = categorizedFoods.values
                    .expand((foods) => foods)
                    .where((food) => food.isSelected)
                    .toList();

                selectedTags = Set.from(selectedItems.map((food) => food.name));

                final selectedRecipes = selectedItems.map((food) => Recipe(
                  id: '',
                  name: food.name,
                  source: '',
                  preptime: 0,
                  waittime: 0,
                  cooktime: 0,
                  servings: 0,
                  comments: '',
                  calories: 0,
                  fat: 0,
                  satfat: 0,
                  carbs: 0,
                  fiber: 0,
                  sugar: 0,
                  protein: 0,
                  instructions: '',
                  ingredients: [],
                  tags: [food.name],
                )).toList();

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Screen3(
                      recipes: selectedRecipes,
                      selectedTags: selectedTags,
                    ),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrange),
              ),
              child: const Text('Discover the recipes!'),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<Food>> _categorizeFoods(List<Food> foods) {
    Map<String, List<Food>> categorized = {};
    for (var food in foods) {
      if (!categorized.containsKey(food.category)) {
        categorized[food.category] = [];
      }
      categorized[food.category]!.add(food);
    }
    return categorized;
  }
}

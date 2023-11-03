import 'package:flutter/material.dart';
import 'screen3.dart';

// Food class to represent a food with a name and an isSelected status
// indicating whether it has been selected:
class Food {
  final String name;
  bool isSelected;
  final String category;
  Food(this.name, this.isSelected, this.category);
}

// Define a controller
ScrollController _scrollController = ScrollController();

// Screen2: checklist
class Screen2 extends StatefulWidget {
  const Screen2({Key? key}) : super(key: key);
  @override
  Screen2State createState() => Screen2State();
}
// F3ood list
class Screen2State extends State<Screen2> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(Colors.deepOrange),
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
                  // Aggiungi la logica di ricerca qui
                },
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView.builder(
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    if (index == 0 || foods[index].category != foods[index - 1].category) {
                      // Add a Text widget when a new category begins
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              foods[index].category,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ),
                          CheckboxListTile(
                            title: Text(foods[index].name),
                            value: foods[index].isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                foods[index].isSelected = value ?? false;
                              });
                            },
                          ),
                        ],
                      );
                    } else {
                      // Continua con CheckboxListTile per la stessa categoria
                      return CheckboxListTile(
                        title: Text(foods[index].name),
                        value: foods[index].isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            foods[index].isSelected = value ?? false;
                          });
                        },
                      );
                    }
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Screen3(foods: foods),
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
  List<Food> foods = [
    Food('Abiu', false, 'Fruit'),
    Food('Açaí', false, 'Fruit'),
    Food('Acerola', false, 'Fruit'),
    Food('Ackee', false, 'Fruit'),
    Food('African Cherry Orange', false, 'Fruit'),
    Food('American Mayapple', false, 'Fruit'),
  ];
}
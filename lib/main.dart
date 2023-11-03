import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
  home: Home(),
));

// Screen1: Step 1
class Screen1 extends StatelessWidget {
  const Screen1({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange[50],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange, // Change the appBar color
        elevation: 0.0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Select items in your kitchen!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 20), // Space between text and button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Screen2()),
                );
              },
              icon: const Icon(Icons.fastfood_outlined), // Adding an icon in the button
              label: const Text('Start'), // Adding a text in the button
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Home screen:
class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold( // In this section you can add properties
      backgroundColor: Colors.deepOrange[50],
        appBar: AppBar( // Upper bar in the home screen
          title: const Text('Home'), // Text in the upper bar
          centerTitle: true, // Tool to centre the title
          backgroundColor: Colors.deepOrange, // Change the appBar color
          elevation: 0.0,
        ),
        body: const Center(
          child: Text(
             'Welcome!',
             style: TextStyle(
               fontSize: 30,
               fontWeight: FontWeight.bold,
               letterSpacing: 2,
               color: Colors.deepOrange,
             ),
           ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Screen1()),
          );
        },
        backgroundColor: Colors.deepOrange,
        child: const Text('Click!'),
      ),
   );
  }
}

// The home widget allows you to create a Home screen that I can reuse
// wherever I want just by writing the name of the class I created

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
    Food('Apple', false, 'Fruit'),
    Food('Apricot', false, 'Fruit'),
    Food('Aratiles', false, 'Fruit'),
    Food('Araza', false, 'Fruit'),
    Food('Atis (Annona Squamosa)', false, 'Fruit'),
    Food('Avocado', false, 'Fruit'),
    Food('Banana', false, 'Fruit'),
    Food('Bilberry', false, 'Fruit'),
    Food('Black sapote', false, 'Fruit'),
    Food('Blackberry', false, 'Fruit'),
    Food('Blackcurrant', false, 'Fruit'),
    Food('Blueberry', false, 'Fruit'),
    Food('Boysenberry', false, 'Fruit'),
    Food('Breadfruit', false, 'Fruit'),
    Food("Buddha's hand (fingered citron)", false, 'Fruit'),
    Food('Cacao', false, 'Fruit'),
    Food('Cactus pear', false, 'Fruit'),
    Food('Canistel (also called egg fruit)', false, 'Fruit'),
    Food('Catmon', false, 'Fruit'),
    Food('Cempedak', false, 'Fruit'),
    Food('Cherimoya (Custard Apple)', false, 'Fruit'),
    Food('Cherry', false, 'Fruit'),
    Food('Chico fruit', false, 'Fruit'),
    Food('Cloudberry', false, 'Fruit'),
    Food('Coco de mer', false, 'Fruit'),
    Food('Coconut', false, 'Fruit'),
    Food('Crab apple', false, 'Fruit'),
    Food('Cranberry', false, 'Fruit'),
    Food('Currant', false, 'Fruit'),
    Food('Damson', false, 'Fruit'),
    Food('Date', false, 'Fruit'),
    Food('Dragonfruit (or Pitaya)', false, 'Fruit'),
    Food('Durian', false, 'Fruit'),
    Food('Elderberry', false, 'Fruit'),
    Food('Feijoa', false, 'Fruit'),
    Food('Fig', false, 'Fruit'),
    Food('Finger Lime (or Caviar Lime)', false, 'Fruit'),
    Food('Gac Fruit (or Baby Jackfruit)', false, 'Fruit'),
    Food('Goji berry', false, 'Fruit'),
    Food('Gooseberry', false, 'Fruit'),
    Food('Grape', false, 'Fruit'),
    Food('Grapefruit', false, 'Fruit'),
    Food('Grewia asiatica (phalsa or falsa)', false, 'Fruit'),
    Food('Guava', false, 'Fruit'),
    Food('Guyabano', false, 'Fruit'),
    Food('Hala Fruit', false, 'Fruit'),
    Food('Honeyberry', false, 'Fruit'),
    Food('Huckleberry', false, 'Fruit'),
    Food('Jabuticaba (Plinia)', false, 'Fruit'),
    Food('Jackfruit', false, 'Fruit'),
    Food('Jambul', false, 'Fruit'),
    Food('Japanese plum', false, 'Fruit'),
    Food('Jostaberry', false, 'Fruit'),
    Food('Jujube', false, 'Fruit'),
    Food('Juniper berry', false, 'Fruit'),
    Food('Kaffir Lime', false, 'Fruit'),
    Food('Kiwano (horned melon)', false, 'Fruit'),
    Food('Kiwifruit', false, 'Fruit'),
    Food('Kumquat', false, 'Fruit'),
    Food('Lanzones', false, 'Fruit'),
    Food('Lemon', false, 'Fruit'),
    Food('Lime', false, 'Fruit'),
    Food('Loganberry', false, 'Fruit'),
    Food('Longan', false, 'Fruit'),
    Food('Loquat', false, 'Fruit'),
    Food('Lulo', false, 'Fruit'),
    Food('Lychee', false, 'Fruit'),
    Food('Macopa (Wax Apple)', false, 'Fruit'),
    Food('Mamey Apple', false, 'Fruit'),
    Food('Mamey Sapote', false, 'Fruit'),
    Food('Mango', false, 'Fruit'),
    Food('Mangosteen', false, 'Fruit'),
    Food('Marionberry', false, 'Fruit'),
    Food('Medlar', false, 'Fruit'),
    Food('Melon', false, 'Fruit'),
    Food('Miracle fruit', false, 'Fruit'),
    Food('Momordica fruit', false, 'Fruit'),
    Food('Monstera deliciosa', false, 'Fruit'),
    Food('Mulberry', false, 'Fruit'),
    Food('Nance', false, 'Fruit'),
    Food('Nectarine', false, 'Fruit'),
    Food('Orange', false, 'Fruit'),
    Food('Papaya', false, 'Fruit'),
    Food('Passionfruit', false, 'Fruit'),
    Food('Pawpaw', false, 'Fruit'),
    Food('Peach', false, 'Fruit'),
    Food('Pear', false, 'Fruit'),
    Food('Persimmon', false, 'Fruit'),
    Food('Plantain', false, 'Fruit'),
    Food('Plum', false, 'Fruit'),
    Food('Prune (dried plum)', false, 'Fruit'),
    Food('Pineapple', false, 'Fruit'),
    Food('Pineberry', false, 'Fruit'),
    Food('Plumcot (or Pluot)', false, 'Fruit'),
    Food('Pomegranate', false, 'Fruit'),
    Food('Pomelo', false, 'Fruit'),
    Food('Purple mangosteen', false, 'Fruit'),
    Food('Quince', false, 'Fruit'),
    Food('Raspberry', false, 'Fruit'),
    Food('Rambutan (or Mamin Chino)', false, 'Fruit'),
    Food('Redcurrant', false, 'Fruit'),
    Food('Red Medlar', false, 'Fruit'),
    Food('Rose apple', false, 'Fruit'),
    Food('Salal berry', false, 'Fruit'),
    Food('Salak', false, 'Fruit'),
    Food('Santol', false, 'Fruit'),
    Food('Sampaloc', false, 'Fruit'),
    Food('Sapodilla', false, 'Fruit'),
    Food('Sapote', false, 'Fruit'),
    Food('Saquico', false, 'Fruit'),
    Food('Sarguelas (Red Mombin)', false, 'Fruit'),
    Food('Satsuma', false, 'Fruit'),
    Food('Soursop', false, 'Fruit'),
    Food('Star apple', false, 'Fruit'),
    Food('Star fruit', false, 'Fruit'),
    Food('Strawberry', false, 'Fruit'),
    Food('Surinam cherry', false, 'Fruit'),
    Food('Tamarillo', false, 'Fruit'),
    Food('Tamarind', false, 'Fruit'),
    Food('Tangelo', false, 'Fruit'),
    Food('Tayberry', false, 'Fruit'),
    Food('Tambis (Water Apple)', false, 'Fruit'),
    Food('Thimbleberry', false, 'Fruit'),
    Food('Ugli fruit', false, 'Fruit'),
    Food('White currant', false, 'Fruit'),
    Food('White sapote', false, 'Fruit'),
    Food('Ximenia', false, 'Fruit'),
    Food('Yuzu', false, 'Fruit'),

  ];
}

// Screen3: recipes
class Screen3 extends StatelessWidget {
  final List<Food> foods;
  const Screen3({Key? key, required this.foods}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Filters selected items
    final selectedFoods = foods.where((food) => food.isSelected).toList();
    return Scaffold(
      backgroundColor: Colors.deepOrange[50],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0.0,
      ),
      body: Column(
        children: <Widget>[
          const Text('Selected items:'),
          ListView.builder(
            itemCount: selectedFoods.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(selectedFoods[index].name),
              );
            },
          ),
        ],
      ),
    );
  }
}

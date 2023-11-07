import 'package:flutter/material.dart';
import 'screen3.dart';
import 'foodlist.dart';

// Define a controller
ScrollController _scrollController = ScrollController();

// Screen2: checklist
class Screen2 extends StatefulWidget {
  const Screen2({Key? key}) : super(key: key);
  @override
  Screen2State createState() => Screen2State();
}
// Food list
class Screen2State extends State<Screen2> {
  String filter = '';
  List<Food> filteredFoods = [];
  List<Food> selectedFoods = [];

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    filteredFoods = foods
        .where((food) => food.name.toLowerCase().contains(filter.toLowerCase()))
        .toList();
    filteredFoods.sort((a, b) {
      final containsA = a.name.toLowerCase() == filter.trim().toLowerCase();
      final containsB = b.name.toLowerCase() == filter.trim().toLowerCase();
      if (containsA && !containsB) {
        return -1;
      } else if (!containsA && containsB) {
        return 1;
      } else {
        return 0;
      }
    });

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
                  setState(() {
                    filter = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView.builder(
                  itemCount: filteredFoods.length,
                  itemBuilder: (context, index) {
                    final food = filteredFoods[index];
                    if (index == 0 || food.category != filteredFoods[index - 1].category) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              food.category,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ),
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
                    } else {
                      return CheckboxListTile(
                        title: Text(food.name),
                        value: food.isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            food.isSelected = value ?? false;
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
            final selectedItems = filteredFoods.where((food) => food.isSelected).toList();
            Navigator.of(context).push(
            MaterialPageRoute(
            builder: (context) => Screen3(
            foods: selectedItems,
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
  } // Build.context

}
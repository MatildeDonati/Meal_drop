import 'package:flutter/material.dart';
import 'screen3.dart';
import 'foodlistDEMO.dart';


class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  Screen2State createState() => Screen2State();
}

class Screen2State extends State<Screen2> {
  final List<bool> checkedItems = List.generate(14, (index) => false);
  final TextEditingController searchController = TextEditingController();
  List<String> filteredIngredients = [];

  @override
  void initState() {
    super.initState();
    filteredIngredients.addAll(ingredients);
    searchController.addListener(filterIngredients);
  }

  void filterIngredients() {
    setState(() {
      filteredIngredients = ingredients
          .where((ingredient) => ingredient.contains(searchController.text))
          .toList();
    });
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: searchController,
        decoration: const InputDecoration(
          labelText: 'Search for ingredients:',
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 19,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
        cursorColor: Colors.black,
      ),
    );
  }

  Widget buildIngredientsList() {
    return Expanded(
      child: Scrollbar(
        thumbVisibility: true,
        thickness: 8.0,
        radius: const Radius.circular(5.0),
        child: ListView.builder(
          itemCount: filteredIngredients.length,
          itemBuilder: (context, index) {
            return CheckboxListTile(
              title: Text(filteredIngredients[index]),
              value: checkedItems[ingredients.indexOf(filteredIngredients[index])],
              onChanged: (value) {
                setState(() {
                  checkedItems[ingredients.indexOf(filteredIngredients[index])] = value!;
                });
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildDiscoverButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Screen3()),
          );
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrange),
        ),
        child: const Text(
          'Discover the recipes!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange[50],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0.0,
      ),
      body: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Check what you have',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.deepOrange,
                ),
              ),
            ),
          ),
          buildSearchBar(),
          buildIngredientsList(),
          buildDiscoverButton(),
        ],
      ),
    );
  }
}
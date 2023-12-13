import 'package:flutter/material.dart';
import 'screen3.dart';
import 'foodlistDEMO.dart';
import 'recipes.dart';


class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  Screen2State createState() => Screen2State();
}

class Screen2State extends State<Screen2> {

  // Lista per tenere traccia dello stato di spunta
  List<bool> checkedItems = List.generate(14, (index) => false);

  // Controller per la barra di ricerca
  TextEditingController searchController = TextEditingController();

  // Lista filtrata degli elementi in base alla ricerca
  List<String> filteredIngredients = [];

  List<Recipe> recipes = [];

  @override
  void initState() {
    super.initState();

    // Inizializza la lista filtrata con la lista completa degli ingredienti
    filteredIngredients.addAll(ingredients);

    // Aggiungi un listener per intercettare le modifiche alla barra di ricerca
    searchController.addListener(() {
      filterIngredients();
    });

  }

  // Funzione per filtrare gli ingredienti in base alla ricerca
  void filterIngredients() {
    setState(() {
      filteredIngredients = ingredients
          .where((ingredient) =>
          ingredient.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            // Barra di ricerca
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Search for ingredients:',
                  // Cambia il colore del testo
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 20, // Imposta la dimensione del carattere desiderata
                  ),
                  // Cambia il colore del bordo
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                cursorColor: Colors.black, // Questo imposta il colore del cursore
              ),
            ),
            // Lista filtrata degli ingredienti
            Expanded(
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
            // Aggiungi il bottone per navigare a Screen3
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Screen3(recipes: recipes, filteredIngredients: filteredIngredients),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrange),
                ),
                child: const Text('Discover the recipes!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
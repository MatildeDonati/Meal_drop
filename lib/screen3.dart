import 'package:flutter/material.dart';
import 'screen2.dart';

// Screen3: recipes
class Screen3 extends StatelessWidget {
  final List<Food> foods;

  const Screen3({required this.foods, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange[50],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0.0,
      ),
      body: ListView.builder(
        itemCount: foods.length,
        itemBuilder: (context, index) {
          final food = foods[index];
          return ListTile(
            title: Text(food.name),
            // Qui puoi fare qualcosa con gli elementi selezionati
          );
        },
      ),
    );
  }
}


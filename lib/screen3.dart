import 'package:flutter/material.dart';
import 'screen2.dart';

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
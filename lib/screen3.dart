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
      // Add your widget tree for Screen3 here
    );
  }
}

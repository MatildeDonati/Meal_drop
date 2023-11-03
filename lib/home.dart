import 'package:flutter/material.dart';
import 'screen1.dart';

void main() => runApp(const MaterialApp(
  home: Home(),
));

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
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
  home: Home(),
));

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // In this section you can add properties
        appBar: AppBar( // Upper bar in the home screen
          title: const Text('Home'), // Text in the upper bar
          centerTitle: true, // Tool to centre the title
          backgroundColor: Colors.deepOrange, // Change the appBar color
        ),
        body: const Center(
          child: Text(
            'Welcome!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.grey,
              fontFamily: 'OpenSans',
            ),
          ), // Text in the centre of the home screen
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {  },
          backgroundColor: Colors.deepOrange[400],
          child: const Text('Click me!'),
        )
    );
  }
}
//the home widget allows you to create a Home screen that I can reuse
// wherever I want just by writing the name of the class I created

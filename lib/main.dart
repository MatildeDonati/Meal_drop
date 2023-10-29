import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home: Scaffold( // In this section you can add properties
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
          color: Colors.deepOrange,
          fontFamily: 'OpenSans',
        ),
      ), // Text in the centre of the home screen
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {  },
      backgroundColor: Colors.deepOrange,
      child: const Text('Click me!'),
    )
  ),
));
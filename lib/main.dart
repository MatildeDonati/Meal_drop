import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home: Scaffold( // In this section you can add properties
    appBar: AppBar( // Upper bar in the home screen
      title: const Text('Home'), // Text in the upper bar
      centerTitle: true, // Tool to centre the title
    ),
    body: const Center(
      child: Text('Welcome!'), // Text in the centre of the home screen
    ),
    backgroundColor: Colors.deepOrange[400], // Change the background color
  ),
));

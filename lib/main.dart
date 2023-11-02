import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
  home: Home(),
));

// Screen1: Step 1
class Screen1 extends StatelessWidget {
  const Screen1({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange[50],
      appBar: AppBar(
        title: const Text('Step 1'),
        centerTitle: true, // Tool to centre the title
        backgroundColor: Colors.deepOrange, // Change the appBar color
        elevation: 0.0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Select items in your kitchen!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 20), // Space between text and button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Screen2()),
                );
              },
              icon: const Icon(Icons.fastfood_outlined), // Adding an icon in the button
              label: const Text('Start'), // Adding a text in the button
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

// Screen2: Fruit list
class Screen2 extends StatelessWidget {
  const Screen2 ({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange[50],
      appBar: AppBar(
        title: const Text('Fruit list'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        elevation: 0.0,
      ),
      body: const Center(
        child: Text(
          'Check the fruit that you have:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.deepOrange,
          ),
        ),
      ),
    );
  }
}
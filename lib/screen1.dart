import 'package:flutter/material.dart';
import 'screen2.dart';

// Screen1: Step 1
class Screen1 extends StatelessWidget {
  const Screen1({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange[50],
      appBar: AppBar(
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
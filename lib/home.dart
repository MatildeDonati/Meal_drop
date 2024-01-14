import 'package:flutter/material.dart';
import 'screen2.dart';

void main() => runApp(const MaterialApp(
  home: Home(),
));

// Home screen:
class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      Color(0xFFFBE9E7),
                      Color(0xFFFFCCBC)
                    ]
                )
            )
        ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Meal", style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      ),
                      Text("Drop", style: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      )
                    ],
                  ),
                  SizedBox(height: 80),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Welcome!", style: TextStyle(
                    fontSize: 50,
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                ),
                ),
                      ],
                  ),
                ],
              ),
              ),
      ],
    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Screen2()),
          );
        },
        backgroundColor: Colors.deepOrange,
        child: const Text('Click!', style: TextStyle(color: Colors.black),),
      ),

    );

  }
}

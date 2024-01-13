import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class Screen2 extends StatefulWidget {
  const Screen2({Key? key}) : super(key: key);

  @override
  Screen2State createState() => Screen2State();
}

class Screen2State extends State<Screen2> {

  TextEditingController textEditingController = TextEditingController();

  String applicationId = "85721d4c";
  String applicationKey = "162c22da2f6dc5bc2f4e1caa61c652aa";

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Row(
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
                const SizedBox(height: 30,),
                const Text("What will you cook today?", style: TextStyle(
                  fontSize: 20,
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                ),
                const SizedBox(height: 8,),
                const Text("Just enter the ingredient you don't want to waste and we will show the best recipe for you!",
                      style: TextStyle(
                      fontSize: 15,
                      color: Colors.deepOrange,
                ),
                ),
                SizedBox(height:30,),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: <Widget>[
                        Expanded(
                         child: TextField(
                           controller: textEditingController,
                           decoration: InputDecoration(
                              hintText: "Enter Ingredients",
                              hintStyle: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  letterSpacing: 1,
                            ),
                          ),
                           style: TextStyle(
                             fontSize:18
                           ),
                        ),
                       ),
                       SizedBox(width: 16,),
                      InkWell(
                        onTap: () {
                          if(textEditingController.text.isNotEmpty) {

                          }else{

                          }
                        },
                        child: Container(
                          child: const Icon(Icons.search, color: Colors.black,),
                      ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  }
}
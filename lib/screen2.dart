import 'dart:convert';
import 'dart:io';
import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meal_drop/recipemodels.dart';
import 'package:meal_drop/recipeview.dart';
import 'package:url_launcher/url_launcher.dart';

class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  Screen2State createState() => Screen2State();
}

class Screen2State extends State<Screen2> {

  List<RecipeModels> recipes = [];
  late String ingredients;
  bool _loading = false;
  String query = "";
  TextEditingController textEditingController =  TextEditingController();

  @override
  void initState() {
    super.initState();
  }

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
                ],
                  begin: FractionalOffset.topRight,
                  end: FractionalOffset.bottomLeft,
              )
            ),
          ),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: !kIsWeb ? Platform.isIOS? 60: 30 : 30, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Row(
                    mainAxisAlignment: kIsWeb
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
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
                  const SizedBox(height:30,),
                  SizedBox(
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
                               enabledBorder: const UnderlineInputBorder(
                                 borderSide: BorderSide(color: Colors.black),
                               ),
                               focusedBorder: const UnderlineInputBorder(
                                 borderSide: BorderSide(color: Colors.black),
                               ),
                            ),
                             style: const TextStyle(
                               fontSize:18,
                               color: Colors.black,
                             ),
                          ),
                         ),
                         const SizedBox(width: 16,),
                        InkWell(
                          onTap: () async {
                            if(textEditingController.text.isNotEmpty) {
                              setState(() {
                                _loading = true;
                              });
                              recipes = [];  // Clear the list before adding new recipes
                              String url =
                                  "https://api.edamam.com/search?q=${textEditingController.text}&app_id=85721d4c&app_key=162c22da2f6dc5bc2f4e1caa61c652aa";
                              var response = await http.get(Uri.parse(url));

                              if (response.statusCode == 200) {
                                Map<String, dynamic> jsonData =
                                jsonDecode(response.body);
                                jsonData["hits"].forEach((element) {
                                  RecipeModels recipeModels = RecipeModels(
                                    url: '',
                                    source: '',
                                    image: '',
                                    label: '',
                                  );
                                  recipeModels =
                                      RecipeModels.fromMap(element['recipe']);
                                  recipes.add(recipeModels);
                                });
                              } else {

                                print('Failed to load recipes');
                              }

                              setState(() {
                                _loading = false;
                              });

                            } else {
                              // Handle the case when the text is empty
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFBE9E7),
                              Color(0xFFFFCCBC)
                            ],
                            begin: FractionalOffset.topRight,
                            end: FractionalOffset.bottomLeft)),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.search, color: Colors.black,),
                        ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height:10,),
                GridView(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        mainAxisSpacing: 10.0, maxCrossAxisExtent: 200.0),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: const ClampingScrollPhysics(),
                    children: List.generate(recipes.length, (index) {
                      return GridTile(
                          child: RecipeTile(
                            title: recipes[index].label,
                            imgUrl: recipes[index].image,
                            desc: recipes[index].source,
                            url: recipes[index].url,
                          )
                      );
                    }
                    )
                ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

  }
}

class RecipeTile extends StatefulWidget {
  final String title, desc, imgUrl, url;

  const RecipeTile({super.key, required this.title, required this.desc, required this.imgUrl, required this.url});

  @override
  RecipeTileState createState() => RecipeTileState();
}

class RecipeTileState extends State<RecipeTile> {
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (kIsWeb) {
              _launchURL(widget.url);
            } else {

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Recipeview(
                        postUrl: widget.url,
                      )
                  )
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            child: Stack(
              children: <Widget>[
                Image.network(
                  widget.imgUrl,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
                Container(
                  width: 200,
                  alignment: Alignment.bottomLeft,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.white30, Colors.white],
                          begin: FractionalOffset.centerRight,
                          end: FractionalOffset.centerLeft)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.title,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              ),
                        ),
                        Text(
                          widget.desc,
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GradientCard extends StatelessWidget {
  final Color topColor;
  final Color bottomColor;
  final String topColorCode;
  final String bottomColorCode;

  const GradientCard(
      {super.key, required this.topColor,
        required this.bottomColor,
        required this.topColorCode,
        required this.bottomColorCode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: 160,
                width: 180,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [topColor, bottomColor],
                        begin: FractionalOffset.topLeft,
                        end: FractionalOffset.bottomRight)),
              ),
              Container(
                width: 180,
                alignment: Alignment.bottomLeft,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.white30, Colors.white],
                        begin: FractionalOffset.centerRight,
                        end: FractionalOffset.centerLeft)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        topColorCode,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      Text(
                        bottomColorCode,
                        style: TextStyle(fontSize: 16, color: bottomColor),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
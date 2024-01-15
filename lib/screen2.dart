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

  @override
  Screen2State createState() => Screen2State();
}

class Screen2State extends State<Screen2> {

  List<RecipeModels> recipes = List<RecipeModels>();
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
                   SizedBox(height: 8,),
                   Text("Just enter the ingredient you don't want to waste and we will show the best recipe for you!",
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
                                    color: Colors.black.withOpacity(0.5),
                                    letterSpacing: 1,
                              ),
                               enabledBorder: UnderlineInputBorder(
                                 borderSide: BorderSide(color: Colors.white),
                               ),
                               focusedBorder: UnderlineInputBorder(
                                 borderSide: BorderSide(color: Colors.white),
                               ),
                            ),
                             style: TextStyle(
                               fontSize:18,
                               color: Colors.black,
                             ),
                          ),
                         ),
                         SizedBox(width: 16,),
                        InkWell(
                          onTap: () async {
                            if(textEditingController.text.isNotEmpty) {
                                setState(() {
                                    _loading = true;
                                  });
                                recipes = new List();
                                String url =
                                    "https://api.edamam.com/search?q=${textEditingController.text}&app_id=85721d4c&app_key=162c22da2f6dc5bc2f4e1caa61c652aa";
                                var response = await http.get(url as Uri);
                                print(" $response this is response");
                                Map<String, dynamic> jsonData =
                                jsonDecode(response.body);
                                print("this is json Data $jsonData");
                                jsonData["hits"].forEach((element) {
                                  print(element.toString());
                                  RecipeModels recipeModels = RecipeModels(url: '', source: '', image: '', label: '');
                                  recipeModels = RecipeModels.fromMap(element['recipe']);
                                  recipes.add(recipeModels);
                                  print(recipeModels.url);
                                });

                                List<RecipeModels> typedRecipes = recipes.cast<RecipeModels>();

                                setState(() {
                                  _loading = false;
                                });

                            }else{

                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                            colors: [
                              Color(0xFFFBE9E7),
                              Color(0xFFFFCCBC)
                            ],
                            begin: FractionalOffset.topRight,
                            end: FractionalOffset.bottomLeft)),
                            padding: EdgeInsets.all(8),
                            child: Container(
                              child: const Icon(Icons.search, color: Colors.black,),
                        ),
                        ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height:10,),
                Container(
                  child: GridView(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          mainAxisSpacing: 10.0, maxCrossAxisExtent: 200.0),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: ClampingScrollPhysics(),
                      children: List.generate(recipes.length, (index) {
                        return GridTile(
                            child: RecipieTile(
                              title: recipes[index].label,
                              imgUrl: recipes[index].image,
                              desc: recipes[index].source,
                              url: recipes[index].url,
                            )
                        );
                      }
                      )
                  ),
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

class RecipieTile extends StatefulWidget {
  final String title, desc, imgUrl, url;

  RecipieTile({required this.title, required this.desc, required this.imgUrl, required this.url});

  @override
  RecipieTileState createState() => RecipieTileState();
}

class RecipieTileState extends State<RecipieTile> {
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
            margin: EdgeInsets.all(8),
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
                  decoration: BoxDecoration(
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
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              ),
                        ),
                        Text(
                          widget.desc,
                          style: TextStyle(
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

  GradientCard(
      {required this.topColor,
        required this.bottomColor,
        required this.topColorCode,
        required this.bottomColorCode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        children: <Widget>[
          Container(
            child: Stack(
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
                  decoration: BoxDecoration(
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
                          style: TextStyle(fontSize: 16, color: Colors.black54),
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
          ),
        ],
      ),
    );
  }
}
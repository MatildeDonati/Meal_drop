import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Recipeview extends StatefulWidget {

  final String postUrl;
  const Recipeview({super.key, required this.postUrl});

  @override
  RecipeviewState createState() => RecipeviewState();
}

class RecipeviewState extends State<Recipeview> {

  final Completer<WebViewController> controller =
   Completer<WebViewController>();

  late String finalUrl ;

  @override
  void initState() {

    if(widget.postUrl.contains("http://")){
      finalUrl = widget.postUrl.replaceAll("http://", "https://");

    }else{
      finalUrl = widget.postUrl;

    }
    super.initState();
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: Platform.isIOS? 60: 30, right: 24,left: 24,bottom: 16),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFBE9E7),
                    Color(0xFFFFCCBC)
                  ],
                  begin: FractionalOffset.topRight,
                  end: FractionalOffset.bottomLeft,
                ),
              ),
              child:  const Row(
                mainAxisAlignment: kIsWeb
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Meal",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Drop",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.deepOrange,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - 100,
              width: MediaQuery.of(context).size.width,
              child: WebView(
                      initialUrl: widget.postUrl,
                      javascriptMode: JavaScriptMode.unrestricted,
                      onWebViewCreated: (WebViewController webViewController){
                        setState(() {
                        controller.complete(webViewController);
                        });
                      }
              ),
            ),
          ],
        ),
      );
    }
  }


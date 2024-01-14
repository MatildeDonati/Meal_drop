import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Recipeview extends StatefulWidget {
  final String postUrl;
  Recipeview({required this.postUrl});
  @override
  RecipeviewState createState() => RecipeviewState();
}

class RecipeviewState extends State<Recipeview> {

  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  String finalUrl ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    finalUrl = widget.postUrl;
    if(widget.postUrl.contains('http://')){
      finalUrl = widget.postUrl.replaceAll("http://","https://");
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: Platform.isIOS? 60: 30, right: 24,left: 24,bottom: 16),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Color(0xFFFBE9E7),
                          Color(0xFFFFCCBC)
                        ],
                        begin: FractionalOffset.topRight,
                        end: FractionalOffset.bottomLeft)),
                child:  Row(
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
              Container(
                height: MediaQuery.of(context).size.height - (Platform.isIOS ? 104 : 30),
                width: MediaQuery.of(context).size.width,
                child: WebView(
                  onPageFinished: (val){
                    print(val);
                  },
                  javascriptMode: JavascriptMode.unrestricted,
                  initialUrl: finalUrl,
                  onWebViewCreated: (WebViewController webViewController){
                    setState(() {
                      _controller.complete(webViewController);
                    });
                  },
                ),
              ),
            ],
          ),
        )
    );
  }
}
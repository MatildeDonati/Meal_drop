import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Recipeview extends StatefulWidget {
  final String postUrl;

  const Recipeview({required this.postUrl});

  @override
  RecipeviewState createState() => RecipeviewState();
}

class RecipeviewState extends State<Recipeview> {
  final Completer<InAppWebViewController> controller =
  Completer<InAppWebViewController>();

  late String finalUrl;

  bool isError = false;

  @override
  void initState() {
    if (widget.postUrl.contains("http://")) {
      finalUrl = widget.postUrl.replaceAll("http://", "https://");
    } else {
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
            padding: EdgeInsets.only(
              top: Platform.isIOS ? 60 : 30,
              right: 24,
              left: 24,
              bottom: 16,
            ),
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFBE9E7),
                  Color(0xFFFFCCBC),
                ],
                begin: FractionalOffset.topRight,
                end: FractionalOffset.bottomLeft,
              ),
            ),
            child: const Row(
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
          isError
              ? Center(
                child: Text(
                  "Sorry for the inconvenience the page can't be load",
                  style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold,),
                  textAlign: TextAlign.center,
                ),
          )
              : SizedBox(
                height: MediaQuery.of(context).size.height - 100,
                width: MediaQuery.of(context).size.width,
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: Uri.parse(widget.postUrl)),
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      javaScriptEnabled: true,
                    ),
                  ),
                  onWebViewCreated: (InAppWebViewController webViewController) {
                    setState(() {
                      controller.complete(webViewController);
                    });
                  },
                  onLoadError: (InAppWebViewController controller, Uri? url,
                      int code, String message) async {
                    setState(() {
                      isError = true;
                    });
                  },
                ),
          ),
        ],
      ),
    );
  }
}
import 'dart:async';
import 'package:expense_tracker/constants.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:expense_tracker/handlers/http_request_handler.dart';
import 'package:expense_tracker/screens/login.dart';

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final TextEditingController _urlController =
  TextEditingController(text: '');
  late WebViewController controller;
  bool isLoaded = false;
  bool userStatus = false;
  bool isPageLoading = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      isLoaded = true;
      getUserStatus();
    });
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isPageLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              isPageLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://example.com'));
  }

  getUserStatus() async {
    userStatus = await HttpRequestHandler(context).getUserStatus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: WebViewWidget(controller: controller),
            ),
            if (isPageLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            Visibility(
              visible: isLoaded,
              child: Padding(
                padding: const EdgeInsets.only(top: 40.0,left: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width:120.0,
                      child: TextField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onSubmitted: (val) {
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        if(_urlController.text == 'login-page'){
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => const LoginPage()));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Visibility(
          visible: userStatus,
          child: FloatingActionButton(
            onPressed: (){Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const LoginPage()));},
            shape: const CircleBorder(),
            backgroundColor: Constants.primary,
            child: const Icon(Icons.login, color: Colors.white,),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}

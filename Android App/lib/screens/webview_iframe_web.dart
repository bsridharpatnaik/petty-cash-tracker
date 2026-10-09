import 'dart:html' as html;
import 'dart:ui_web' as ui_web; // <--- Changed import
import 'package:flutter/material.dart';

import 'package:expense_tracker/handlers/http_request_handler.dart'; // Assuming this exists
import 'package:expense_tracker/screens/login.dart'; // Assuming this exists

class WebViewIframePage extends StatefulWidget {
  const WebViewIframePage({super.key});

  @override
  State<WebViewIframePage> createState() => _WebViewIframePageState();
}

class _WebViewIframePageState extends State<WebViewIframePage> {
  final TextEditingController _urlController = TextEditingController();
  final String viewId = 'iframe-element';
  bool isLoaded = false;
  bool userStatus = false;

  late html.IFrameElement _iframe;

  @override
  void initState() {
    super.initState();

    _iframe = html.IFrameElement()
      ..src = 'https://example.com' // Initial URL
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow = 'fullscreen' // Consider adding other permissions if needed, like 'autoplay'
      ..id = 'iframe-id';

    // Register view using the recommended import for newer Flutter versions
    // If you are on an older Flutter web version, keep ui.platformViewRegistry
    // For newer versions, it's typically:
    // import 'dart:ui_web' as ui_web;
    // ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) => _iframe);
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) => _iframe);


    // Optional: Listen for iframe load events for debugging
    _iframe.onLoad.listen((event) {
      print('Iframe loaded: ${_iframe.src}');
      // You can try to access content here, but it will be blocked by CORS for cross-origin iframes
    });

    // Delay user status fetch
    Future.delayed(const Duration(seconds: 2), () {
      isLoaded = true;
      getUserStatus();
      setState(() {});
    });
  }

  Future<void> getUserStatus() async {
    final status = await HttpRequestHandler(context).getUserStatus();
    setState(() {
      userStatus = status;
    });
  }

  void handleSearchInput(String val) {
    if (val == 'login-page') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 85), // leaves space for search bar
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              child: const HtmlElementView(viewType: 'iframe-element'),
            ),
            Visibility(
              visible: isLoaded,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onSubmitted: handleSearchInput,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => handleSearchInput(_urlController.text),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Your FloatingActionButton commented out section
        // floatingActionButton: Visibility(
        //   visible: userStatus,
        //   child: FloatingActionButton(
        //     onPressed: () {
        //       Navigator.pushReplacement(
        //         context,
        //         MaterialPageRoute(builder: (context) => const LoginPage()),
        //       );
        //     },
        //     shape: const CircleBorder(),
        //     backgroundColor: Constants.primary, // Assuming Constants.primary exists
        //     child: const Icon(Icons.login, color: Colors.white),
        //   ),
        // ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}
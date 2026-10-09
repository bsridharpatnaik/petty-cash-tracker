import 'package:flutter/material.dart';

class WebViewIframePage extends StatelessWidget {
  const WebViewIframePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('This screen is only available on Flutter Web.'),
      ),
    );
  }
}

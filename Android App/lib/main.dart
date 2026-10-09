import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:expense_tracker/screens/splashscreen.dart';
import 'package:expense_tracker/screens/webview.dart';
import 'package:expense_tracker/screens/webview_iframe.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:expense_tracker/build_config.dart';
import 'package:expense_tracker/handlers/SharedPreferencesHandler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      builder: BotToastInit(),
      navigatorObservers: [
        BotToastNavigatorObserver(), // Existing observer
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Timer(const Duration(seconds: 2), () {
      initApplication();
    });
  }

  // @override
  // void dispose() {
  //   WidgetsBinding.instance.removeObserver(this);
  //   super.dispose();
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {}
    else if (state == AppLifecycleState.paused && !BuildConfig.appIsActive) {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }

  initApplication() async {
    SharedPreferencesHandler sharedPreferencesHandler =
    new SharedPreferencesHandler();
    BuildConfig.webPlatform = BuildConfig.isWeb();
    bool debugMode =
        await sharedPreferencesHandler.getBool(BuildConfig.debugModeKey);
    if (debugMode) {
      BuildConfig.serverUrl = BuildConfig.serverTestUrl;
      Fluttertoast.showToast(
        msg: 'Running in development version.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } else {
      BuildConfig.serverUrl = BuildConfig.serverProdUrl;
    }
    // Navigate to the appropriate WebView
    if (BuildConfig.isWeb()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WebViewIframePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WebViewPage()),
      );
    }
  }

}

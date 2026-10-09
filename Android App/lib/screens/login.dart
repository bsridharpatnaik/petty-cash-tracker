import 'dart:async';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:expense_tracker/constants.dart';
import 'package:expense_tracker/screens/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:expense_tracker/build_config.dart';
import 'package:expense_tracker/handlers/SharedPreferencesHandler.dart';
import 'package:expense_tracker/handlers/http_request_handler.dart';
import 'package:expense_tracker/screens/dashboard/dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late SharedPreferencesHandler sharedPref;
  TextEditingController userNameController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool hidePass = true;
  @override
  Widget build(BuildContext context) {
    sharedPref = new SharedPreferencesHandler();
    int debugBtnClick = 0;
    return WillPopScope(
      onWillPop: () {
        if(!BuildConfig.isWeb()){
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => WebViewPage()));
        }
        return Future.value(false);
      },
      child: Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // SizedBox(height: 15,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.developer_mode,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                debugBtnClick++;
                                if (debugBtnClick < 5) {
                                  return;
                                } else if (debugBtnClick < 10) {
                                  Fluttertoast.showToast(
                                    msg: 'Click more ${10 - debugBtnClick} times to open developer option.',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                  );
                                  return;
                                }
                                AwesomeDialog(
                                  context: context,
                                  headerAnimationLoop: false,
                                  showCloseIcon: true,
                                  closeIcon: Icon(Icons.close),
                                  title: 'Select a version?',
                                  desc: 'App will close after you chose an option.',
                                  dismissOnBackKeyPress: true,
                                  dismissOnTouchOutside: false,
                                  btnCancelText: 'Development',
                                  btnCancelOnPress: () {
                                    Timer(Duration(milliseconds: 600), () async {
                                      await sharedPref.setBool(
                                          BuildConfig.debugModeKey, true);
                                      bool debugMode = await sharedPref
                                          .getBool(BuildConfig.debugModeKey);
                                      print('debug_mode: $debugMode');
                                      exitApplication();
                                    });
                                  },
                                  btnOkText: 'Production',
                                  btnOkOnPress: () {
                                    Timer(Duration(milliseconds: 600), () async {
                                      await sharedPref.setBool(
                                          BuildConfig.debugModeKey, false);
                                      bool debugMode = await sharedPref
                                          .getBool(BuildConfig.debugModeKey);
                                      print('debug_mode: $debugMode');
                                      exitApplication();
                                    });
                                    // dispose();
                                  },
                                ).show();
                              },
                              splashColor: Colors.white,
                              enableFeedback: true,
                            )
                          ],
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 250,
                          child: Image.asset('assets/logo.png'),
                        ),
                        const Text(
                          ' Login',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 30),
                        const Row(
                          children: [
                            Text(
                              ' Username',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,),
                            ),
                          ],
                        ),
                        TextField(
                          controller: userNameController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_rounded),
                            hintText: 'Username',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Text(
                              ' Password',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        TextField(
                          controller: passController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  hidePass = !hidePass;
                                });
                              },
                              child: Icon(hidePass
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                            ),
                            hintText: 'Password',
                            border: const OutlineInputBorder(),
                          ),
                          obscureText: hidePass,
                        ),
                        const SizedBox(height: 25),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.95,
                            height: 50,
                            child: TextButton(
                              onPressed: () {
                                final username = userNameController.text;
                                final password = passController.text;
                                signIn(username, password);
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Constants.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
      ),
    );
  }

  exitApplication() {
    if (BuildConfig.isAndroid()) {
      SystemNavigator.pop();
    } else if (BuildConfig.isIOS()) {
      exit(0);
    }
  }

  signIn(String userName, String password) async {
    Map<String, dynamic> respJson =
        await HttpRequestHandler(context).signInRequest(userName, password);
    if (respJson['status'] == 200) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
        (Route<dynamic> route) =>
            false, // Removes all previous routes from the stack
      );
    } else {
      print("Not Authorised");
    }
  }
}

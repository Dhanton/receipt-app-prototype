import 'dart:async';

import 'package:flutter/material.dart';
import 'package:receiptfrontend/constants/colors.dart';
// import 'package:camera/camera.dart';
import 'package:receiptfrontend/screens/auth/verify_token.dart';
import 'package:receiptfrontend/screens/receipt_list/receipt_screen.dart';
// import 'package:receiptfrontend/pages/login_screen.dart';
// import 'package:receiptfrontend/pages/receipt_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:receiptfrontend/screens/auth/login_screen.dart';
import 'package:receiptfrontend/constants/globals.dart' as globals;

Future<Null> main() async {
  // globals.cameras = await availableCameras();

  var prefs = await SharedPreferences.getInstance();

  bool verified = await verifyToken();

  runApp(new MyApp(has_token: verified));
}

class MyApp extends StatelessWidget {
  final bool has_token;

  MyApp({this.has_token});

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "WhatsApp",
      theme: new ThemeData(
        // primaryColor: new Color(0xff075E54),
        accentColor: BLUE_SHADOW,
        // accentColor: new Color(0xffffffff),
      ),
      debugShowCheckedModeBanner: false,
      home: has_token ? new ReceiptListScreen() : new LoginScreen(),
      // home: new LoginScreen(),
    );
  }
}
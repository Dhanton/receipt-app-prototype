import 'dart:async';
import 'dart:convert';

import 'package:receiptfrontend/constants/colors.dart';
import 'package:receiptfrontend/constants/gradients.dart';
// import 'package:receiptfrontend/screens/auth/auth_gql.dart';
// import 'package:receiptfrontend/screens/auth/model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:receiptfrontend/screens/receipt_list/receipt_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:receiptfrontend/constants/globals.dart' as globals;
import 'package:receiptfrontend/screens/auth/verify_token.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthViews(),
    );
  }
}

class AuthViews extends StatefulWidget {
  // final bool signup;

  // AuthViews({this.signup = false});
  AuthViews();
  _AuthViewsState createState() => _AuthViewsState();
}

class _AuthViewsState extends State<AuthViews> {
  Map<String, String> inputValues = {};
  // String auth_token = "";
  String errorText = "";
  
  // @override
  // void initState() {
    // super.initState();
    // getToken();
  // }

  // Future<void> getToken() async {
    // final token = await _firebaseMessaging.getToken();
    // setState(() {
    //   fcmToken = token;
    // });
  // }

  @override
  Widget build(BuildContext context) => body(context);

  Widget body(context) {
    return ListView(
      children: <Widget>[
        Container(margin: EdgeInsets.only(top: 60)),
        gradientTextComponent(
          BLUE_GRADIENT,
          // "Welcome",
          "Reciby",
        ),
        Container(margin: EdgeInsets.only(top: 35)),
        messageTextComponent(),
        Container(margin: EdgeInsets.only(top: 35)),
        // if (widget.signup) ...nameInputComponent(),
        textFieldComponent(type: "username", hintText: "Username"),
        Container(margin: EdgeInsets.only(top: 20)),
        textFieldComponent(
          type: "password",
          hintText: "Password",
          obscure: true,
        ),
        Container(margin: EdgeInsets.only(top: 10)),
        errorMessageComponent(),
        Container(margin: EdgeInsets.only(top: 120)),
        // mutationComponent(context),
        gradientButtonComponent(),
      ],
    );
  }

  List<Widget> nameInputComponent() {
    return [
      textFieldComponent(type: "name", hintText: "Display Name"),
      Container(margin: EdgeInsets.only(top: 20)),
    ];
  }

  Widget messageTextComponent() {
    return Text(
      'Log in to continue',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
        color: Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget textFieldComponent(
      {String hintText, @required String type, bool obscure = false}) {
    return Container(
      height: 55,
      margin: EdgeInsets.only(left: 30, right: 30),
      padding: EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: LIGHT_GREY_COLOR,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: TextField(
          obscureText: obscure,
          onChanged: (value) => setInputValue(type, value),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText ?? "",
          ),
        ),
      ),
    );
  }

  void setInputValue(String type, String value) {
    setState(() {
      inputValues[type] = value;
    });
    if (errorText != "")
      setState(() {
        errorText = "";
      });
  }

  Widget errorMessageComponent() {
    return Text(
      "$errorText",
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.red),
    );
  }

  // Widget mutationComponent(context) {
  //   final appState = Provider.of<AppState>(context);

  //   return Mutation(
  //     update: (Cache cache, QueryResult result) => cache,
  //     builder: (run, result) => gradientButtonComponent(run, result),
  //     options: MutationOptions(
  //       document: widget.signup ? signupMutation : signinMutation,
  //     ),
  //     onCompleted: (result) async {
  //       final response = AuthModel.fromJson(
  //         result[widget.signup ? 'register' : 'login'],
  //       );

  //       if (response.error == null && response.token != null) {
  //         SharedPreferences prefs = await SharedPreferences.getInstance();
  //         await prefs.setString("uid", response.id);
  //         await prefs.setString("token", response.token);

  //         appState.setToken(response.token);

  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => ChatListScreen(),
  //           ),
  //         );
  //       }
  //       if (response.error != null) {
  //         setState(() {
  //           errorText = response.error.message ?? "";
  //         });
  //       }
  //     },
  //   );
  // }

  Widget gradientButtonComponent() {
    return GestureDetector(
      onTap: () async {
        String username = inputValues["username"] ?? "";
        String pass = inputValues["password"] ?? "";
        if (username != "" && pass != "") {
          bool caught = false;
          http.Response response;

          try {
            response = await http.post(globals.backend_addr + 'auth-token/', 
              headers: {'Content-Type': 'application/json'}, body: jsonEncode(inputValues));

          } catch(_) {
            setState(() {
              errorText = 'Error connecting to Server';
            });

            print('Catch: ' + _.toString());
            caught = true;
          }

          if (!caught) {
            if (response.statusCode == 200) {
              final preferences = await SharedPreferences.getInstance();
              preferences.setString('auth_token', jsonDecode(response.body)['token']);

              bool verified = await verifyToken();

              if (verified) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ReceiptListScreen()));
              } else {
                setState(() {
                  errorText = 'Error verifying with Server';
                });
              }

            } else if (response.statusCode == 400) {
              var json_response = jsonDecode(response.body);
              
              if (json_response.containsKey('non_field_errors') && !json_response['non_field_errors'].isEmpty) {
                setState(() {
                  errorText = json_response['non_field_errors'][0];
                });
              }
            }
          }
        }
      },
      child: Container(
        margin: EdgeInsets.only(left: 30, right: 30),
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: BLUE_GRADIENT,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              blurRadius: 24,
              color: BLUE_SHADOW,
              offset: Offset(0, 16),
            )
          ],
        ),
        // child: Center(
        //   child: result.loading
        //       ? CupertinoActivityIndicator()
        //       : Text(
        //           "CONTINUE",
        //           style: TextStyle(
        //             color: WHITE_COLOR,
        //             fontSize: 18,
        //             fontFamily: 'Roboto',
        //           ),
        //         ),
        // ),
        child: Center(
          child: Text(
                  "CONTINUE",
                  style: TextStyle(
                    color: WHITE_COLOR,
                    fontSize: 18,
                    fontFamily: 'Roboto',
                  ),
                ),
        ),
      ),
    );
  }
}

Widget gradientTextComponent(Gradient gradient, String text,
    {double size = 48,
    FontWeight weight = FontWeight.w300,
    TextAlign align = TextAlign.center}) {
  final rect = Rect.fromLTWH(0.0, 0.0, 200.0, 70.0);
  final Shader linearGradient = gradient.createShader(rect);

  return Text(
    text,
    textAlign: align,
    style: TextStyle(
        fontSize: size,
        fontWeight: weight,
        foreground: Paint()..shader = linearGradient),
  );
}
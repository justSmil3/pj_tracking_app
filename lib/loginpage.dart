import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pj_app/Colors.dart';
import 'package:pj_app/auth_service.dart';
import 'package:pj_app/forgot_password.dart';
import 'package:pj_app/functions.dart';
import 'package:pj_app/mainapp.dart';
import 'package:http/http.dart' as http;
import 'package:pj_app/urls.dart';

var authInfo;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String errortext = "";

  dynamic login(BuildContext context, String username, String password) async {
    authInfo = AuthService();

    final res = await authInfo.login(username, password);
    final data = jsonDecode(res) as Map<String, dynamic>;
    print(data);
    if (data['token'] != null) {
      String token = data['token'];
      http.Response response = await http.Client().get(userCheckUrl,
          headers: {HttpHeaders.authorizationHeader: "Token $token"});
      String result = jsonDecode(response.body);
      if (result == '{"result": "mentor"}')
        Navigator.pushNamed(context, '/mentorLandingPage');
      else if (result == '{"result": "menti"}')
        Navigator.pushNamed(context, '/mentiLandingPage');

      return data;
      // TODO I gotta give the menti user the possibility to log out
    } else if (data["error_msg"]['invalid'] ==
        "Invalid data. Expected a dictionary, but got {datatype}.") {
      errortext = "Falscher Benutzername / Email oder Password";
      setState(() {});
    } else {
      errortext = "Server ist zurzeit nicht erreichbar";
      setState(() {});
    }
  }

  final UsernameController = TextEditingController();
  final PasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    popScopeCallback = () => Future.value(false);
    return WillPopScope(
      onWillPop: popScopeCallback,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                height: 70,
              ),
              Container(
                  width: 125,
                  height: 100,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(100.0)),
                  child: Image.asset(
                    'asset/images/FMR_Logo.png',
                  )),
              Container(
                height: 10,
              ),
              Container(
                  width: 225,
                  height: 100,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(100.0)),
                  child: Image.asset(
                    'asset/images/rflk_logo.png',
                  )),
              Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  errortext,
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
              Padding(
                //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: UsernameController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      //labelText: 'Username',
                      hintText: 'Nutzername'),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: PasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Passwort',
                      hintText: 'Enter secure password'),
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            ForgotPasswordPopup());
                  },
                  child: const Text(
                    'Passwort Vergessen',
                    style: TextStyle(color: Colors.blue, fontSize: 15),
                  ),
                ),
              ]),
              Container(
                height: 50,
                width: 250,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(15)),
                child: TextButton(
                  onPressed: () {
                    login(context, UsernameController.value.text,
                        PasswordController.value.text);
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

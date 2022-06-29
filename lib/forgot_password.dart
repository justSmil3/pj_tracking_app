import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pj_tracking_app/functions.dart';
import 'package:pj_tracking_app/paswordRecoverCodePopup.dart';
import 'dart:math';
import 'package:pj_tracking_app/auth_service.dart';

class ForgotPasswordPopup extends StatefulWidget {
  @override
  _ForgotPasswordPopupState createState() => _ForgotPasswordPopupState();
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

class _ForgotPasswordPopupState extends State<ForgotPasswordPopup> {
  final emailController = TextEditingController();

  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Pasword Vergessen"),
      content: Container(
        height: 250,
        child: Column(children: [
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
                hintText: 'registrierte email eingeben'),
          ),
          Padding(padding: EdgeInsets.all(10)),
          Container(
            height: 30,
            width: 200,
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(15)),
            child: TextButton(
              onPressed: () {
                String code = getRandomString(5);
                forgotPassword(emailController.text, code).then((token) {
                  Navigator.of(context).pop();
                  print(token.values.last);
                  showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          PasswordRecoverCodePopup(
                            code: code,
                            name: token.values.last,
                            token: token.values.first,
                          ));
                });
              },
              child: const Text(
                'Password Wiederherstellen',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

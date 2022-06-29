import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'auth_service.dart';

class PasswordRecoverCodePopup extends StatefulWidget {
  const PasswordRecoverCodePopup(
      {Key? key, required this.code, required this.name, required this.token})
      : super(key: key);

  final String code;
  final String name;
  final String token;

  @override
  _PasswordRecoverCodePopupState createState() =>
      _PasswordRecoverCodePopupState();
}

class _PasswordRecoverCodePopupState extends State<PasswordRecoverCodePopup> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Column(children: [
      Text("Please enter the code send to your email"),
      PinCodeTextField(
        appContext: context,
        length: 5,
        onChanged: (String value) {
          if (value.length == 5) {
            if (value == widget.code) {
              Navigator.of(context).pop();
              showDialog(
                  context: context,
                  builder: (BuildContext context) => ResetPasswordPopup(
                        name: widget.name,
                        token: widget.token,
                      ));
            }
          }
        },
        obscureText: false,
      )
    ]));
  }
}

class ResetPasswordPopup extends StatefulWidget {
  const ResetPasswordPopup({Key? key, required this.name, required this.token})
      : super(key: key);

  final String name;
  final String token;

  @override
  _ResetPasswordPopupState createState() => _ResetPasswordPopupState();
}

class _ResetPasswordPopupState extends State<ResetPasswordPopup> {
  final password_0 = TextEditingController();
  final password_1 = TextEditingController();
  String Errortext = "";
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(children: [
        Text(
          Errortext,
          style: TextStyle(color: Colors.red, fontSize: 14),
        ),
        Container(
          height: 20,
        ),
        TextField(
          controller: password_0,
          obscureText: true,
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Neues Passwort',
              hintText: 'Sicheres Password Eingeben'),
        ),
        Container(
          height: 30,
        ),
        TextField(
          controller: password_1,
          obscureText: true,
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Passwort Widerholen',
              hintText: 'Passwort Wiederholen'),
        ),
        Container(
          height: 30,
        ),
        Container(
          height: 30,
          width: MediaQuery.of(context).size.width * .5,
          decoration: BoxDecoration(
              color: Colors.blue, borderRadius: BorderRadius.circular(15)),
          child: TextButton(
            onPressed: () {
              if (password_0.text.length < 8) {
                Errortext = "Passwort muss mindestens 8 zeichen lang sein";
                setState(() {});
              } else if (password_0.text != password_1.text) {
                Errortext = "Passwort muss übereinstimmen";
                setState(() {});
              } else {
                ResetPassword(password_0.text, widget.name, widget.token);
                Navigator.of(context).pop();
              }
            },
            child: const Text(
              'Passwort Widerherstellen',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ]),
    );
  }
}

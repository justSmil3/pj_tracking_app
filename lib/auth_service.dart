import 'dart:convert';
import 'dart:math';
import 'package:pj_app/urls.dart';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = new FlutterSecureStorage();
String key = "";

String _randomValue() {
  final rand = Random();
  final codeUnits = List.generate(20, (index) {
    return rand.nextInt(26) + 65;
  });

  return String.fromCharCodes(codeUnits);
}

Future getToken({bSendTest = true}) async {
  String token = "";
  await storage.read(key: key).then((value) => token = value!);
  Map<String, dynamic> tmp = json.decode(token);
  token = "Token ${tmp.values.first}";
  String? response;
  // TODO think about a better slution than to send a senseless request here
  // maybe a global response storage
  return http.Client().get(CountedWeightsUrl(0),
      headers: {HttpHeaders.authorizationHeader: token}).then((res) {
    var resp = json.decode(utf8.decode(res.bodyBytes));
    if (resp is List)
      return "Token ${tmp.values.first}";
    else {
      print(resp.runtimeType);
      response = Map<String, dynamic>.from(resp).values.first;

      if (response! == "Invalid token.") {
        return "logout";
      } else {
        return "Token ${tmp.values.first}";
      }
    }
  });
}

class AuthService {
  final baseUrl = ip;

  Future<dynamic> login(String username, String password) async {
    try {
      var res = await http.post(Uri.parse('$baseUrl/login/'), body: {
        "username": username,
        "password": password,
      });

      key = _randomValue();
      storage.write(key: key, value: res.body);
      return res.body;
    } finally {}
  }

  //static setToken(String token, String refreshToken) async {
  //  _AuthData data = _AuthData(token, refreshToken);
  //  return await SESSION.set('tokens', data);
  //}

  //static getToken() async {
  //  return await SESSION.get('tokens');
  //}
}

class _AuthData {
  String token;
  _AuthData(this.token);

  // toJson
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();

    data['token'] = token;
    return data;
  }
}

Future forgotPassword(String username, String code) async {
  final Map<String, dynamic> body = {"name": username, "code": code};

  final Map<String, String> headers = {"Content-Type": "application/json"};

  http.Response response = await http.Client()
      .post(forgotPasswordUrl, headers: headers, body: json.encode(body));

  Map<String, dynamic> tmp = json.decode(response.body);
  String token = "Token ${tmp.values.first}";
  String name = tmp.values.last;

  Map<String, dynamic> returns = {"first": token, "second": name};
  return returns;
}

void ResetPassword(String new_password, String name, String token) {
  final Map<String, dynamic> body = {"name": name, "password": new_password};

  final Map<String, String> headers = {
    "Content-Type": "application/json",
    HttpHeaders.authorizationHeader: token
  };

  http.Client()
      .post(resetPasswordUrl, headers: headers, body: json.encode(body));
}

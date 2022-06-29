import 'package:flutter/material.dart';
import 'package:pj_app/chatpage.dart';
import 'package:pj_app/loginpage.dart';
import 'package:pj_app/main.dart';
import 'package:pj_app/mainapp.dart';
import 'package:pj_app/mentorPages/landing_page.dart';
import 'package:pj_app/mentorPages/menti.dart';
import 'package:pj_app/mentorPages/menti_page.dart';
import 'package:pj_app/trackpage.dart';
//import 'package:pjapp_mentor/menti.dart';
//import 'package:pjapp_mentor/menti_page.dart';
import 'package:http/http.dart' as html;

class RouteGenerator{
  static Route<dynamic> generateRoute(RouteSettings settings){
    final args = settings.arguments;

    switch(settings.name){
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/landingPage':
          return MaterialPageRoute(builder: (_) => const MyApp());
      case '/mentiLandingPage':
        return MaterialPageRoute(builder: (_) => const MyHomePage());
      case '/mentorLandingPage':
        return MaterialPageRoute(builder: (_) => const LandingPage());
      case '/mentorMentiPage':
        if (args is Menti){
          return MaterialPageRoute(builder: (_) => MentiPage(user: args));
        }else return _errorRoute();
      //case'/test':
      //  return MaterialPageRoute(builder: (_) => TrackPage(client: html.Client(), pageController: PageController()));
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute(){
    return MaterialPageRoute(builder: (_){
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: (
            Center(
              child: Text('Error'),
            )
        ),
      );
    });
  }
}
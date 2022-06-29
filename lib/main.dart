import 'package:flutter/material.dart';
import 'package:pj_tracking_app/Colors.dart';
import 'package:pj_tracking_app/loginpage.dart';
import 'package:pj_tracking_app/providers.dart';
import 'package:pj_tracking_app/routes.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<TaskProvider>(create: (_) => TaskProvider()),
          ChangeNotifierProvider<SubtaskProvider>(
              create: (_) => SubtaskProvider()),
          ChangeNotifierProvider<TrackProvider>(create: (_) => TrackProvider()),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: colorCustom,
          ),
          home: const LoginPage(),
          initialRoute: '/',
          onGenerateRoute: RouteGenerator.generateRoute,
        ));
  }
}

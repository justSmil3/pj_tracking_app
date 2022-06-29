import 'package:flutter/material.dart';

const double AppBarHeight = 40.0;
const double BottomNavigationBarHeight = 50.0;

double actualAppBarHeight = 0.0;
double actualNavigationBarHeight = 0.0;

Function() initialPageCallback = () {};
Function(Widget) setAppBar = (Widget tmp) {};

final Map<String, String> dropOptions = {
  "0": "Keine Ausführung",
  "1": "Gemeinsam mit dem Arzt",
  "2": "Unter Beobachtung des Arztes",
  "3": "Eigenständig"
};

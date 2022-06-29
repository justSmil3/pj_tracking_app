import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Color primaryColor = const Color(0xff80deea);
// Color lightPrimaryColor = const Color(0xffb4ffff);
// Color darkPrimaryColor = const Color(0xff4bacb8);
// Color secondaryColor = const Color(0xffe53635);
// Color lightSecondaryColor = const Color(0xffff6d60);
// Color darkSecondaryColor = const Color(0xffab000e);

Color primaryColor = const Color(0xff80deea);
Color lightPrimaryColor = const Color(0xffb4ffff);
Color darkPrimaryColor = const Color(0xff4bacb8);
Color secondaryColor = Colors.grey;
Color lightSecondaryColor = Colors.grey;
Color darkSecondaryColor = Colors.grey;

Map<int, Color> ColorthemeMap = {
  50: Color.fromRGBO(150, 150, 150, .1),
  100: Color.fromRGBO(150, 150, 150, .2),
  200: Color.fromRGBO(150, 150, 150, .3),
  300: Color.fromRGBO(150, 150, 150, .4),
  400: Color.fromRGBO(150, 150, 150, .5),
  500: Color.fromRGBO(150, 150, 150, .6),
  600: Color.fromRGBO(150, 150, 150, .7),
  700: Color.fromRGBO(150, 150, 150, .8),
  800: Color.fromRGBO(150, 150, 150, .9),
  900: Color.fromRGBO(150, 150, 150, 1),
};

// List<Color> secondaryShaddow = [
//   const Color(0xff79ADDC),
//   const Color(0xff5B5B5B),
//   const Color(0xffC9C19F),
//   const Color(0xffEDF7D2),
//   const Color(0xffEDF7B5),
// ];

//41463D
List<Color> secondaryShaddow = [
  const Color(0xff9D8DF1),
  const Color(0xffB8CDF8),
  const Color(0xffA7E0E9),
  const Color(0xff95F2D9),
  const Color(0xff1CFEBA),
];

// List<Color> secondaryShaddow = [
//  const Color(0xff068d9d),
//  const Color(0xff53599a),
//  const Color(0xff6d9dc5),
//  const Color(0xff80ded9),
//  const Color(0xffaeecef),
// ];
MaterialColor colorCustom = MaterialColor(0xffffffff, ColorthemeMap);

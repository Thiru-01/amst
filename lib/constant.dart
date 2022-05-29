import 'package:flutter/material.dart';

const MaterialColor primarySwatch = MaterialColor(
  _bluePrimaryValue,
  <int, Color>{
    50: Color(0xFFfff0e6),
    100: Color(0xFFffe2cc),
    200: Color(0xFFffd3b3),
    300: Color(0xFFffc599),
    400: Color(0xFFffb680),
    500: Color(0xFFffa766),
    600: Color(0xFFff994d),
    700: Color(0xFFff8a33),
    800: Color(0xFFff7c1a),
    900: Color(_bluePrimaryValue),
  },
);
const int _bluePrimaryValue = 0xFFFF6D00;

double height(context) {
  return MediaQuery.of(context).size.height;
}

double width(context) {
  return MediaQuery.of(context).size.width;
}
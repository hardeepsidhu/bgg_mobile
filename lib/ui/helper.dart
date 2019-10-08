import 'package:flutter/material.dart';

class UIHelper {
  static TextStyle textStyle({double size = 16.0, FontWeight weight = FontWeight.normal}) {
    return TextStyle(
      fontSize: size,
      color: Colors.black,
      fontFamily: 'Arvo',
      fontWeight: weight,
    );
  }
}
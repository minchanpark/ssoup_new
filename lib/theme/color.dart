import 'package:flutter/material.dart';

class AppColor {
  static const Color primary = Color(0xFF98C8FF);
  static const Color secondary = Color(0xffBFE4FF);
  static const Color tertiery = Color(0xffBAC8D5);
  static const LinearGradient homeMix = LinearGradient(
    colors: [
      Color.fromRGBO(138, 206, 255, 1),
      Color.fromRGBO(163, 194, 255, 1),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const Color home2 = Color(0xff8ACEFF);
  static const Color home1 = Color(0xffA3C2FF);
  static const Color mainText = Color(0xff131313);
  static const Color subText = Color(0xffADAAAA);
  static const Color button = Color(0xff50A2FF);
  static const Color white = Color(0xffFFFFFF);
}

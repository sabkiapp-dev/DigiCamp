import 'package:flutter/material.dart';

class Palette {
  Palette._();

  // Primary color swatches
  static const Map<int, Color> primaryColorSwatch = {
    50: Color.fromRGBO(20, 78, 90, .1),
    100: Color.fromRGBO(20, 78, 90, .2),
    200: Color.fromRGBO(20, 78, 90, .3),
    300: Color.fromRGBO(20, 78, 90, .4),
    400: Color.fromRGBO(20, 78, 90, .5),
    500: Color.fromRGBO(20, 78, 90, .6),
    600: Color.fromRGBO(20, 78, 90, .7),
    700: Color.fromRGBO(20, 78, 90, .8),
    800: Color.fromRGBO(20, 78, 90, .9),
    900: Color.fromRGBO(20, 78, 90, 1),
  };

  // Primary color
  static const MaterialColor primaryColor =
      MaterialColor(0xFF144E5A, primaryColorSwatch);

  /// White color
  static const Color white = Color(0xFFFFFFFF);

  /// White color
  static const Color black = Color(0xFF000000);

  /// Input hint color
  static const Color inputHintColor = Color(0xFFBBBCBB);

  /// Inactive color
  static const Color inactiveColor = Color(0xFF9A9A9A);

  /// Border color
  static const Color borderColor = Color(0xFFE6E6E6);

  /// Error Border color
  static const Color errorColor = Color(0xFFB00020);

  /// Shadow color
  static const Color shadowColor = Color.fromRGBO(22, 22, 22, .15);

  // Primary color swatches
  static const Map<int, Color> darkPrimaryColorSwatch = {
    50: Color.fromRGBO(41, 50, 61, .1),
    100: Color.fromRGBO(41, 50, 61, .2),
    200: Color.fromRGBO(41, 50, 61, .3),
    300: Color.fromRGBO(41, 50, 61, .4),
    400: Color.fromRGBO(41, 50, 61, .5),
    500: Color.fromRGBO(41, 50, 61, .6),
    600: Color.fromRGBO(41, 50, 61, .7),
    700: Color.fromRGBO(41, 50, 61, .8),
    800: Color.fromRGBO(41, 50, 61, .9),
    900: Color.fromRGBO(41, 50, 61, 1),
  };

  static const MaterialColor darkPrimaryColor =
      MaterialColor(0xFF29323D, darkPrimaryColorSwatch);
  static const Color darkCardColor = Color(0xFF0E0E0F);
  static const Color darkDividerColor = Color(0xFF545454);
  static const Color darkActiveColor = Color(0xFFFFFFFF);
  static const Color darkInactiveColor = Color(0xFF717B84);
}

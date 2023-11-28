import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
    iconTheme: const IconThemeData(
      color: Colors.black,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: Colors.black87
    ),
    primaryColorLight: Colors.black
  );
  static ThemeData darkTheme = ThemeData(
    appBarTheme: const AppBarTheme(
      foregroundColor: Colors.white,
      backgroundColor: Color.fromRGBO(21, 25, 29, 1.0),
      // backgroundColor: Colors.black87,
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.black87,
      indicatorColor: Colors.white
    ),
    primaryColorDark: Colors.white
  );
  static const Color lightNavBottomBG = Colors.white;
  static const Color darkNavBottomBG = Colors.transparent;
  static const Color lightNavBottomFG = Colors.black;
  static const Color darkNavBottomFG = Colors.white;
  static const Color lightIcon = Colors.black;
  static const Color darkIcon = Colors.white;
  static const Color bg = Color.fromRGBO(21, 25, 29, 1.0);
}
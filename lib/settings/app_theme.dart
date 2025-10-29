import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Themes {
  static final _seedColor = Colors.blue;

  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
   textTheme: GoogleFonts.robotoFlexTextTheme(ThemeData(brightness: Brightness.light).textTheme,),
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    textTheme: GoogleFonts.robotoFlexTextTheme(ThemeData(brightness: Brightness.dark).textTheme,),
  );
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// light theme
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: GoogleFonts.openSans().fontFamily,
  textTheme: GoogleFonts.openSansTextTheme().copyWith().apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
  dialogBackgroundColor: Colors.grey[200],
  highlightColor: Colors.blue[100],
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.light,
  ),
  useMaterial3: true,
);

// dark theme
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: GoogleFonts.openSans().fontFamily,
  textTheme: GoogleFonts.openSansTextTheme().copyWith().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
  dialogBackgroundColor: Colors.grey[800],
  highlightColor: Colors.grey[600],
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
);

// text styles
const textStyle28w500 = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w500,
);

const textStyle18w500 = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w500,
);

const textStyle16w500 = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

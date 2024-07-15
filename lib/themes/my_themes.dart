import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

// light theme
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: GoogleFonts.openSans().fontFamily,
  textTheme: GoogleFonts.openSansTextTheme().copyWith().apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
  dialogBackgroundColor: Colors.grey[200],
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.green,
    brightness: Brightness.light,
  ),
  useMaterial3: true,
  cardColor: Colors.white,
).copyWith(
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
    },
  ),
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
    seedColor: Colors.green,
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
  cardColor: Colors.grey[200],
).copyWith(
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
    },
  ),
);

const cardElevation = 4.0;

// text styles
const textStyle28w500 = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w500,
);

const textStyle18w500 = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w500,
);

const textStyle18Bold = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

const textStyle16w600 = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

// pinput theme
final defaultPinTheme = PinTheme(
  width: 56,
  height: 60,
  textStyle: const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  ),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    color: Colors.grey.shade200,
    border: Border.all(
      color: Colors.transparent,
    ),
  ),
);

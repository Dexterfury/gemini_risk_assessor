import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: GoogleFonts.openSans().fontFamily,
    textTheme: GoogleFonts.openSansTextTheme().copyWith().apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
    dialogBackgroundColor: Colors.grey[200],
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
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
  static ThemeData darkTheme = ThemeData(
          brightness: Brightness.dark,
          fontFamily: GoogleFonts.openSans().fontFamily,
          textTheme: GoogleFonts.openSansTextTheme().copyWith().apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
          dialogBackgroundColor: Colors.grey[800],
          highlightColor: Colors.grey[600],
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          cardColor: Colors.blueGrey.shade800)
      .copyWith(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
      },
    ),
  );

  static const cardElevation = 2.0;

// text styles
  static const textStyle28w500 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w500,
  );

  static const textStyle18w500 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static const textStyle18Bold = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const textStyle16w600 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

// pinput theme
  static PinTheme getDefaultPinTheme(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        border: Border.all(
          color: Colors.transparent,
        ),
      ),
    );
  }

  static PinTheme getFocusPinTheme(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return getDefaultPinTheme(context).copyWith(
      height: 68,
      width: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
        border: Border.all(),
      ),
    );
  }

  static PinTheme getErrorPinTheme(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppTheme.getFocusPinTheme(context).copyWith(
      height: 68,
      width: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
        border: Border.all(
          color: Colors.red,
        ),
      ),
    );
  }

  static Color getButtonColor(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return isDarkMode ? Colors.blueGrey : Theme.of(context).primaryColor;
  }

  static Color getSearchBtnTheme(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return isDarkMode ? Colors.grey.shade800 : Colors.white;
  }

  static Color getFabBtnTheme(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return isDarkMode ? Colors.grey.shade800 : Theme.of(context).primaryColor;
  }
}

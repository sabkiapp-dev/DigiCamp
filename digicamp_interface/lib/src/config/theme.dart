import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:digicamp_interface/src/config/font_sizes.dart';
import 'package:digicamp_interface/src/utils/palette.dart';

class ThemeConfig {
  ThemeConfig._();

  /// Light style
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Palette.primaryColor,
          onPrimary: Palette.white,
          secondary: Palette.primaryColor,
          onSecondary: Palette.white,
          error: Palette.errorColor,
          onError: Palette.white,
          background: Palette.white,
          onBackground: Palette.black,
          surface: Palette.white,
          onSurface: Palette.black,
        ),
        inputDecorationTheme: _inputDecorationTheme,
        fontFamily: GoogleFonts.aBeeZee().fontFamily,
        appBarTheme: const AppBarTheme(
          backgroundColor: Palette.primaryColor,
          foregroundColor: Palette.white,
          titleTextStyle: TextStyle(
            fontSize: FontSizes.body1,
            color: Palette.white,
          ),
        ),
        tabBarTheme: const TabBarTheme(
          unselectedLabelColor: Palette.inactiveColor,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Palette.primaryColor,
          selectedItemColor: Palette.white,
          unselectedItemColor: Palette.inactiveColor,
          showSelectedLabels: false,
          showUnselectedLabels: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(15.0),
            backgroundColor: Palette.primaryColor,
            foregroundColor: Palette.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(15.0),
            foregroundColor: Palette.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        textTheme: GoogleFonts.aBeeZeeTextTheme().copyWith(
          labelLarge: const TextStyle(
            fontSize: FontSizes.button,
            fontWeight: FontWeight.normal,
          ),
          bodyLarge: const TextStyle(
            fontSize: FontSizes.body1,
          ),
          bodyMedium: const TextStyle(
            fontSize: FontSizes.body2,
          ),
          displayLarge: const TextStyle(
            fontSize: FontSizes.headline1,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: const TextStyle(
            fontSize: FontSizes.headline2,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: const TextStyle(
            fontSize: FontSizes.headline3,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: const TextStyle(
            fontSize: FontSizes.headline4,
            fontWeight: FontWeight.bold,
          ),
          headlineSmall: const TextStyle(
            fontSize: FontSizes.headline5,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: const TextStyle(
            fontSize: FontSizes.headline6,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: const TextStyle(
            fontSize: FontSizes.subtitle1,
          ),
          titleSmall: const TextStyle(
            fontSize: FontSizes.subtitle2,
          ),
          bodySmall: const TextStyle(
            fontSize: FontSizes.body1,
          ),
        ),
      );

  /// App theme data
  ///
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Palette.darkPrimaryColor,
          onPrimary: Palette.white,
          secondary: Palette.primaryColor,
          onSecondary: Palette.white,
          error: Palette.errorColor,
          onError: Palette.white,
          background: Palette.black,
          onBackground: Palette.white,
          surface: Palette.darkPrimaryColor,
          onSurface: Palette.white,
        ),
        inputDecorationTheme: _darkInputDecorationTheme,
        fontFamily: GoogleFonts.aBeeZee().fontFamily,
        dialogBackgroundColor: Palette.darkPrimaryColor,
        tabBarTheme: const TabBarTheme(
          indicatorColor: Palette.white,
          labelColor: Palette.white,
          unselectedLabelColor: Palette.darkInactiveColor,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Palette.darkPrimaryColor,
          selectedItemColor: Palette.white,
          unselectedItemColor: Palette.darkInactiveColor,
          showSelectedLabels: false,
          showUnselectedLabels: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Palette.white,
            padding: const EdgeInsets.all(15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Palette.white,
            padding: const EdgeInsets.all(15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        radioTheme: const RadioThemeData(
          fillColor: MaterialStatePropertyAll(Palette.white),
        ),
        checkboxTheme: const CheckboxThemeData(
          fillColor: MaterialStatePropertyAll(Palette.white),
          checkColor: MaterialStatePropertyAll(Palette.darkPrimaryColor),
        ),
        textTheme: GoogleFonts.aBeeZeeTextTheme()
            .apply(
              bodyColor: Palette.white,
              displayColor: Palette.white,
            )
            .copyWith(
              labelLarge: const TextStyle(
                fontSize: FontSizes.button,
              ),
              bodyLarge: const TextStyle(
                fontSize: FontSizes.body1,
              ),
              bodyMedium: const TextStyle(
                fontSize: FontSizes.body2,
              ),
              displayLarge: const TextStyle(
                fontSize: FontSizes.headline1,
                fontWeight: FontWeight.bold,
              ),
              displayMedium: const TextStyle(
                fontSize: FontSizes.headline2,
                fontWeight: FontWeight.bold,
              ),
              displaySmall: const TextStyle(
                fontSize: FontSizes.headline3,
                fontWeight: FontWeight.bold,
              ),
              headlineMedium: const TextStyle(
                fontSize: FontSizes.headline4,
                fontWeight: FontWeight.bold,
              ),
              headlineSmall: const TextStyle(
                fontSize: FontSizes.headline5,
                fontWeight: FontWeight.bold,
              ),
              titleLarge: const TextStyle(
                fontSize: FontSizes.headline6,
                fontWeight: FontWeight.bold,
              ),
              titleMedium: const TextStyle(
                fontSize: FontSizes.subtitle1,
              ),
              titleSmall: const TextStyle(
                fontSize: FontSizes.subtitle2,
              ),
              bodySmall: const TextStyle(
                fontSize: FontSizes.body1,
              ),
            ),
      );

  static InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(
          color: Palette.inputHintColor,
        ),
        labelStyle: const TextStyle(
          color: Palette.inputHintColor,
        ),
        filled: true,
        fillColor: Palette.primaryColor.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      );

  static InputDecorationTheme get _darkInputDecorationTheme =>
      InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(
          color: Palette.inputHintColor,
        ),
        labelStyle: const TextStyle(
          color: Palette.inputHintColor,
        ),
        filled: true,
        fillColor: Palette.darkPrimaryColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      );
}

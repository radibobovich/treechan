import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();
  static final ThemeData flutterTheme =
      ThemeData(primarySwatch: Colors.blue, secondaryHeaderColor: Colors.blue);

  static final ThemeData makabaClassic = ThemeData(
    colorScheme: const ColorScheme(
        primary: Color.fromARGB(255, 255, 102, 0),
        onPrimary: Colors.white,
        // I don't know what colors to use
        secondary: Colors.red,
        onSecondary: Colors.blue,
        error: Colors.black,
        onError: Colors.white,
        background: Color.fromARGB(255, 25, 250, 52),
        onBackground: Colors.orange,
        surface: Color.fromARGB(255, 25, 39, 52),
        onSurface: Colors.black,
        brightness: Brightness.light),
    scaffoldBackgroundColor: const Color.fromARGB(255, 238, 238, 238),
    appBarTheme: const AppBarTheme(color: Color.fromARGB(255, 255, 102, 0)),
    secondaryHeaderColor: const Color.fromARGB(255, 255, 102, 0),
    brightness: Brightness.light,
    textTheme: const TextTheme(
        bodySmall: TextStyle(color: Color.fromARGB(255, 56, 68, 77))),
  );

  static final ThemeData makabaNight = ThemeData(
      colorScheme: const ColorScheme(
          primary: Color.fromARGB(255, 195, 103, 42),
          onPrimary: Color.fromARGB(255, 204, 204, 204),
          // I don't know what colors to use
          secondary: Colors.red,
          onSecondary: Colors.blue,
          error: Colors.black,
          onError: Colors.white,
          background: Color.fromARGB(255, 25, 250, 52),
          onBackground: Colors.orange,
          surface: Color.fromARGB(255, 25, 39, 52),
          onSurface: Colors.white,
          brightness: Brightness.dark),
      brightness: Brightness.dark,
      primaryColor: Colors.blueGrey.shade900,
      secondaryHeaderColor: const Color.fromARGB(255, 195, 103, 42),
      appBarTheme: const AppBarTheme(color: Color.fromARGB(255, 25, 39, 52)),
      drawerTheme: const DrawerThemeData(
          backgroundColor: Color.fromARGB(255, 25, 39, 52)),
      cardTheme: const CardTheme(color: Color.fromARGB(255, 25, 39, 52)),
      dialogTheme:
          const DialogTheme(backgroundColor: Color.fromARGB(255, 25, 39, 52)),
      iconTheme: const IconThemeData(color: Color.fromARGB(255, 204, 204, 204)),
      //dividerColor: const Color.fromARGB(255, 56, 68, 77),
      dividerTheme:
          //const DividerThemeData(color: Color.fromARGB(102, 56, 68, 77)),
          const DividerThemeData(color: Color.fromARGB(255, 56, 68, 77)),
      scaffoldBackgroundColor: const Color.fromARGB(255, 21, 32, 43),
      textTheme: const TextTheme(
          titleMedium: TextStyle(color: Color.fromARGB(255, 204, 204, 204)),
          bodyMedium: TextStyle(color: Color.fromARGB(255, 204, 204, 204)),
          bodySmall: TextStyle(color: Color.fromARGB(255, 125, 125, 125))),
      hintColor: const Color.fromARGB(255, 125, 125, 125));
}

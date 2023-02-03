import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();
  static final ThemeData flutterTheme =
      ThemeData(primarySwatch: Colors.blue, secondaryHeaderColor: Colors.blue);
  static final ThemeData classicTheme = ThemeData(primarySwatch: Colors.grey);
  static final ThemeData nightTheme = ThemeData(
      primaryColor: Colors.blueGrey.shade900,
      secondaryHeaderColor: const Color.fromARGB(255, 195, 103, 42),
      appBarTheme: const AppBarTheme(color: Color.fromARGB(255, 25, 39, 52)),
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
          bodyMedium: TextStyle(color: Color.fromARGB(255, 204, 204, 204))));
}

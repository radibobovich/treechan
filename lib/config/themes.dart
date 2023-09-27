import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();
  static final ThemeData flutterTheme =
      ThemeData(primarySwatch: Colors.blue, secondaryHeaderColor: Colors.blue);

  static final ThemeData makabaClassic = ThemeData(
    colorScheme: flutterTheme.colorScheme.copyWith(
        primary: const Color.fromARGB(255, 255, 102, 0),
        secondary: const Color.fromARGB(255, 255, 102, 0)),
    // colorScheme: const ColorScheme(
    //     primary: Color.fromARGB(255, 255, 102, 0),
    //     onPrimary: Colors.white,
    //     secondary: Colors.red,
    //     onSecondary: Colors.white,
    //     error: Colors.red,
    //     onError: Colors.white,
    // background: Color.fromARGB(255, 25, 250, 52),
    //     onBackground: Colors.orange,
    //     surface: Color.fromARGB(255, 25, 39, 52),
    //     onSurface: Colors.black,
    //     brightness: Brightness.light),
    extensions: <ThemeExtension<dynamic>>[
      CustomColors(boldText: const Color.fromARGB(255, 255, 102, 0))
    ],
    scaffoldBackgroundColor: const Color.fromARGB(255, 238, 238, 238),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(color: Color.fromARGB(255, 255, 102, 0)),
    secondaryHeaderColor: const Color.fromARGB(255, 255, 102, 0),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color.fromARGB(255, 255, 102, 0)),
    brightness: Brightness.light,
    textTheme: const TextTheme(
        bodySmall: TextStyle(color: Color.fromARGB(255, 56, 68, 77))),
  );

  static final ThemeData makabaNight = ThemeData(
      colorScheme: flutterTheme.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: const Color.fromARGB(255, 255, 102, 0),
        onSurface: Colors.white,
        secondary: const Color.fromARGB(255, 255, 102, 0),
      ),
      // colorScheme: const ColorScheme(
      //     primary: Color.fromARGB(255, 195, 103, 42),
      //     onPrimary: Color.fromARGB(255, 204, 204, 204),
      // secondary: Colors.red,
      //     onSecondary: Colors.white,
      //     error: Colors.black,
      //     onError: Colors.white,
      // background: Color.fromARGB(255, 25, 250, 52),
      //     onBackground: Colors.orange,
      //     surface: Color.fromARGB(255, 25, 39, 52),
      //     onSurface: Colors.white,
      //     brightness: Brightness.dark),
      extensions: <ThemeExtension<dynamic>>[
        CustomColors(boldText: const Color.fromARGB(255, 195, 103, 42))
      ],
      brightness: Brightness.dark,
      primaryColor: Colors.blueGrey.shade900,
      secondaryHeaderColor: const Color.fromARGB(255, 195, 103, 42),
      appBarTheme: const AppBarTheme(color: Color.fromARGB(255, 25, 39, 52)),
      drawerTheme: const DrawerThemeData(
          backgroundColor: Color.fromARGB(255, 25, 39, 52)),
      cardTheme: const CardTheme(color: Color.fromARGB(255, 25, 39, 52)),
      cardColor: const Color.fromARGB(255, 25, 39, 52),
      dialogTheme:
          const DialogTheme(backgroundColor: Color.fromARGB(255, 25, 39, 52)),
      iconTheme: const IconThemeData(color: Color.fromARGB(255, 204, 204, 204)),
      //dividerColor: const Color.fromARGB(255, 56, 68, 77),
      dividerTheme:
          //const DividerThemeData(color: Color.fromARGB(102, 56, 68, 77)),
          const DividerThemeData(color: Color.fromARGB(255, 56, 68, 77)),
      scaffoldBackgroundColor: const Color.fromARGB(255, 21, 32, 43),
      tabBarTheme: const TabBarTheme(
          indicator: UnderlineTabIndicator(
              borderSide:
                  BorderSide(color: Color.fromARGB(255, 195, 103, 42)))),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.white,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color.fromARGB(255, 195, 103, 42)),
      snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.black,
          contentTextStyle: TextStyle(color: Colors.white)),
      textTheme: const TextTheme(
          titleMedium: TextStyle(color: Color.fromARGB(255, 204, 204, 204)),
          bodyMedium: TextStyle(color: Color.fromARGB(255, 204, 204, 204)),
          bodySmall: TextStyle(color: Color.fromARGB(255, 125, 125, 125))),
      hintColor: const Color.fromARGB(255, 125, 125, 125));

  static final ThemeData dark = ThemeData(
      colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.black, brightness: Brightness.dark)
          .copyWith(
        primary: const Color.fromARGB(255, 255, 102, 0),
        background: const Color(0xFF1F1F1F),
        onSurface: const Color(0xFFE1E1E1),
        secondary: const Color.fromARGB(255, 255, 102, 0),
      ),
      extensions: <ThemeExtension<dynamic>>[
        CustomColors(boldText: const Color.fromARGB(255, 255, 102, 0))
      ],
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      primaryColor: const Color.fromARGB(255, 25, 39, 52),
      secondaryHeaderColor: const Color.fromARGB(255, 255, 102, 0),
      appBarTheme: const AppBarTheme(color: Color(0xFF1F1F1F)),
      drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF1F1F1F)),
      cardTheme: const CardTheme(color: Color(0xFF1E1E1E)),
      dialogTheme: const DialogTheme(backgroundColor: Color(0xFF1F1F1F)),
      cardColor: const Color(0xFF1F1F1F),
      tabBarTheme: const TabBarTheme(
          indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: Color(0xFFE1E1E1)))),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Color.fromARGB(255, 255, 102, 0),
        unselectedItemColor: Color(0xFFE1E1E1),
      ),
      iconTheme: const IconThemeData(color: Color(0xFFE1E1E1)),
      dividerTheme: const DividerThemeData(color: Color(0x99A0A0A0)),
      snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.black,
          contentTextStyle: TextStyle(color: Color(0xFFE1E1E1))),
      textTheme: const TextTheme(
          titleMedium: TextStyle(color: Color(0xFFE1E1E1)),
          bodyMedium: TextStyle(color: Color(0xFFE1E1E1)),
          bodySmall: TextStyle(color: Color(0xFFA0A0A0))));

  static final ThemeData amoled = ThemeData(
      colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.black, brightness: Brightness.dark)
          .copyWith(
        primary: const Color.fromARGB(255, 255, 102, 0),
        background: const Color(0xFF000000),
        onSurface: const Color(0xFFE1E1E1),
        secondary: const Color.fromARGB(255, 255, 102, 0),
      ),
      extensions: <ThemeExtension<dynamic>>[
        CustomColors(boldText: const Color.fromARGB(255, 255, 102, 0))
      ],
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF000000),
      primaryColor: const Color.fromARGB(255, 25, 39, 52),
      secondaryHeaderColor: const Color.fromARGB(255, 255, 102, 0),
      appBarTheme: const AppBarTheme(color: Color(0xFF000000)),
      drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF000000)),
      cardTheme: const CardTheme(color: Color(0xFF141414)),
      cardColor: const Color(0xFF000000),
      dialogTheme: const DialogTheme(backgroundColor: Color(0xFF141414)),
      tabBarTheme: const TabBarTheme(
          indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: Color(0xFFE1E1E1)))),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Color.fromARGB(255, 255, 102, 0),
        unselectedItemColor: Color(0xFFE1E1E1),
      ),
      iconTheme: const IconThemeData(color: Color(0xFFE1E1E1)),
      dividerTheme: const DividerThemeData(color: Color(0x99282828)),
      snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.black,
          contentTextStyle: TextStyle(color: Color(0xFFE1E1E1))),
      hintColor: const Color(0xFFA0A0A0),
      textTheme: const TextTheme(
          titleMedium: TextStyle(color: Color(0xFFE1E1E1)),
          bodyMedium: TextStyle(color: Color(0xFFE1E1E1)),
          bodySmall: TextStyle(color: Color(0xFFA0A0A0))));
}

class CustomColors extends ThemeExtension<CustomColors> {
  final Color? boldText;

  CustomColors({this.boldText});
  @override
  ThemeExtension<CustomColors> copyWith() {
    return this;
  }

  @override
  ThemeExtension<CustomColors> lerp(
      ThemeExtension<CustomColors>? other, double t) {
    return this;
  }
}

ThemeData getTheme(String theme) {
  switch (theme) {
    case 'Makaba Night':
      return AppTheme.makabaNight;
    case 'Makaba Classic':
      return AppTheme.makabaClassic;
    case 'Dark':
      return AppTheme.dark;
    case 'Amoled':
      return AppTheme.amoled;
  }
  return AppTheme.makabaClassic;
}

extension BuildContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);
  CustomColors get colors => Theme.of(this).extension<CustomColors>()!;
}

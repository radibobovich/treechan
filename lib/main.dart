import 'package:flutter/material.dart';
import 'package:treechan/themes.dart';
import 'screens/tab_bar_navigator.dart';
//import 'screens/navigator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //getBoards();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.nightTheme,
      home: const AppNavigator(),
      initialRoute: '/',
    );
  }
}

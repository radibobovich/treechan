import 'package:flutter/material.dart';
import './screens/board_list_screen.dart';
import 'package:treechan/themes.dart';

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
      // ThemeData(
      //     primarySwatch: Colors.blue, secondaryHeaderColor: Colors.blue),
      home: const MyHomePage(title: 'Доски'),
    );
  }
}

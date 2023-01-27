import 'package:flutter/material.dart';
import 'package:treechan/services/board_list_service.dart';
import './screens/board_list_screen.dart';

void main() {
  //getBoards();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Доски'),
    );
  }
}

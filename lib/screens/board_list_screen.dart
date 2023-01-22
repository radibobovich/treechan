import 'package:flutter/material.dart';
import 'board_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class BoardMenuItem {
  final String name;
  final String tag;

  const BoardMenuItem(this.name, this.tag);
}

final boardMenu = List.filled(1, const BoardMenuItem("Бред", "b"));

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView.builder(
            itemCount: 1,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(boardMenu[index].name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BoardScreen(
                          boardName: boardMenu[index].name,
                          boardTag: boardMenu[index].tag),
                    ),
                  );
                },
              );
            })
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}

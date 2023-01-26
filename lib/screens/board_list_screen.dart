import 'package:flutter/material.dart';
import 'board_screen.dart';

class BoardMenuItem {
  final String name;
  final String tag;

  const BoardMenuItem(this.name, this.tag);
}

var boardMenu = List.empty(growable: true);

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    boardMenu.add(const BoardMenuItem("Бред", "b"));
    boardMenu.add(const BoardMenuItem("Психология", 'psy'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView.builder(
            itemCount: boardMenu.length,
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

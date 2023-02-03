import 'package:flutter/material.dart';
import 'package:treechan/models/board_json.dart';
import 'package:treechan/services/board_list_service.dart';
import 'board_screen.dart';
import 'package:grouped_list/grouped_list.dart';

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
  //late Future<SharedPreferences> prefs;
  late Future<List<Board>?> boards;
  @override
  void initState() {
    super.initState();
    //prefs = SharedPreferences.getInstance();
    boards = getBoards();
    //boardMenu.add(const BoardMenuItem("Бред", "b"));
    //boardMenu.add(const BoardMenuItem("Психология", 'psy'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: FutureBuilder<List<Board>?>(
          future: boards,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              snapshot.data!.removeWhere(
                (element) => element.category == "Пользовательские",
              );
              //String boardsJson = snapshot.data!.getString('boards')!;
              //List<Board> boards = boardListFromJson(jsonDecode(boardsJson))!;
              return GroupedListView<dynamic, String>(
                elements: snapshot.data!, //boards
                groupBy: (board) => board.category,
                groupComparator: (category1, category2) =>
                    category2.compareTo(category1),
                itemComparator: (board1, board2) => (board1.id + board1.name)
                    .compareTo(board2.id + board2.name),
                order: GroupedListOrder.ASC,
                groupSeparatorBuilder: (value) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(
                        thickness: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 0, 12),
                        child: Text(
                          value,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).secondaryHeaderColor),
                        ),
                      ),
                    ]),
                itemBuilder: (context, board) {
                  return ListTile(
                    title: Text(board.name),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BoardScreen(
                              boardName: board.name,
                              boardTag: board.id,
                            ),
                          ));
                    },
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        )
        // ListView.builder(
        //     itemCount: boardMenu.length,
        //     itemBuilder: (context, index) {
        //       return ListTile(
        //         title: Text(boardMenu[index].name),
        //         onTap: () {
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (context) => BoardScreen(
        //                   boardName: boardMenu[index].name,
        //                   boardTag: boardMenu[index].tag),
        //             ),
        //           );
        //         },
        //       );
        //     })
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}

import 'package:flutter/material.dart';
import 'package:treechan/models/board_json.dart';
import 'package:treechan/services/board_list_service.dart';
import 'board_screen.dart';
import 'package:grouped_list/grouped_list.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Board>?> boards;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: FutureBuilder<List<Board>?>(
          future: getBoards(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              snapshot.data!.removeWhere(
                (element) => element.category == "Пользовательские",
              );
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
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:treechan/models/board_json.dart';
import 'package:treechan/services/board_list_service.dart';
import 'package:grouped_list/grouped_list.dart';
import 'tab_navigator.dart';

class BoardListScreen extends StatefulWidget {
  const BoardListScreen(
      {super.key,
      required this.title,
      required this.onOpen,
      required this.onGoBack});
  final String title;
  final Function onOpen;
  final Function onGoBack;
  @override
  State<BoardListScreen> createState() => _BoardListScreenState();
}

class _BoardListScreenState extends State<BoardListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late Future<List<Board>?> boards;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                    onTap: () => widget.onOpen(DrawerTab(
                        type: TabTypes.board,
                        name: board.name,
                        tag: board.id,
                        prevTab: DrawerTab(
                            type: TabTypes.boardList,
                            name: "Доски",
                            tag: "boards"))),
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ));
  }
}

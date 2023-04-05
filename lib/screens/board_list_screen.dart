import 'package:flutter/material.dart';
import '../models/json/json.dart';
import '../services/board_list_service.dart';
import 'tab_navigator.dart';

class Category {
  // TODO: move to models
  Category({required this.categoryName, required this.boards});
  final String categoryName;
  final List<Board> boards;
}

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

// TODO: add favorites
class _BoardListScreenState extends State<BoardListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late Future<List<Category>> categories;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: FutureBuilder<List<Category>>(
          future: getCategories(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  if (snapshot.data![index].categoryName !=
                      "Пользовательские") {
                    return CategoryWidget(
                        onOpen: widget.onOpen,
                        category: snapshot.data![index],
                        showDivider: index != 0);
                  }
                  return const SizedBox();
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return const Center(child: CircularProgressIndicator());
          },
        ));
  }
}

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({
    super.key,
    required this.onOpen,
    required this.category,
    required this.showDivider,
  });

  final Function onOpen;
  final Category category;
  final bool showDivider;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDivider) const Divider(thickness: 1),
        ListTile(
          title: Text(category.categoryName,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).secondaryHeaderColor)),
        ),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: category.boards.map((board) {
            return ListTile(
              title: Text(board.name!),
              onTap: () {
                onOpen(DrawerTab(
                    type: TabTypes.board,
                    name: board.name,
                    tag: board.id!,
                    prevTab: DrawerTab(
                        type: TabTypes.boardList,
                        name: "Доски",
                        tag: "boards")));
              },
            );
          }).toList(),
        )
      ],
    );
  }
}

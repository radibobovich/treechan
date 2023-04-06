import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/bloc/board_list_bloc.dart';
import '../models/category.dart';
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
        body: BlocBuilder<BoardListBloc, BoardListState>(
          builder: (context, state) {
            if (state is BoardListLoadedState) {
              return ListView.builder(
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  if (state.categories[index].categoryName !=
                      "Пользовательские") {
                    return CategoryWidget(
                        onOpen: widget.onOpen,
                        category: state.categories[index],
                        showDivider: index != 0);
                  }
                  return const SizedBox();
                },
              );
            } else if (state is BoardListErrorState) {
              return Center(child: Text(state.errorMessage));
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

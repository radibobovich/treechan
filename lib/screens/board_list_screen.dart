import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/screens/tab_navigator.dart';
import '../models/bloc/board_list_bloc.dart';
import '../models/category.dart';
import '../models/json/json.dart';
import '../widgets/board_list/category_widget.dart';

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
  late Future<List<Category>> categories;

  bool allowReorder = false;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.title),
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            actions: [
              BlocBuilder<BoardListBloc, BoardListState>(
                builder: (context, state) {
                  if (state is BoardListLoadedState) {
                    return state.allowReorder
                        ? const IconCompleteReorder()
                        : const IconRefreshBoards();
                  } else {
                    return const IconRefreshBoards();
                  }
                },
              )
            ]),
        body: BlocBuilder<BoardListBloc, BoardListState>(
          builder: (context, state) {
            if (state is BoardListLoadedState) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  FavoriteBoardsList(
                    onOpen: widget.onOpen,
                    favorites: state.favorites,
                  ),
                  CategoriesList(
                    onOpen: widget.onOpen,
                    categories: state.categories,
                  ),
                ],
              );
            } else if (state is BoardListErrorState) {
              return Center(child: Text(state.errorMessage));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ));
  }
}

/// Appears at the top of the screen.
class FavoriteBoardsList extends StatefulWidget {
  const FavoriteBoardsList({
    super.key,
    required this.onOpen,
    required this.favorites,
  });

  final Function onOpen;
  final List<Board> favorites;
  @override
  State<FavoriteBoardsList> createState() => _FavoriteBoardsListState();
}

class _FavoriteBoardsListState extends State<FavoriteBoardsList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.favorites.isEmpty
            ? const SizedBox.shrink()
            : const CategoryHeader(categoryName: "Избранное"),
        ReorderableListView.builder(
          buildDefaultDragHandles:
              BlocProvider.of<BoardListBloc>(context).allowReorder,
          onReorder: onReorder,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.favorites.length,
          itemBuilder: (context, index) {
            Board board = widget.favorites[index];
            return ListTile(
              title: Text(board.name!),
              trailing: BlocProvider.of<BoardListBloc>(context).allowReorder
                  ? Icon(
                      Icons.drag_handle,
                      color: Theme.of(context).iconTheme.color,
                    )
                  : const SizedBox.shrink(),
              onTap: () {
                openBoard(board);
              },
              onLongPress: () {
                showContextMenu(context, board);
              },
              key: UniqueKey(),
            );
          },
        ),
      ],
    );
  }

  openBoard(Board board) {
    widget.onOpen(DrawerTab(
        type: TabTypes.board,
        name: board.name,
        tag: board.id!,
        prevTab:
            DrawerTab(type: TabTypes.boardList, name: "Доски", tag: "boards")));
  }

  /// Calls when user reorder favorite boards.
  void onReorder(int oldIndex, int newIndex) {
    List<Board> favorites = widget.favorites;
    setState(() {
      if (newIndex > oldIndex) {
        Board movingBoard = favorites[oldIndex];
        favorites.removeAt(oldIndex);
        favorites.insert(newIndex - 1, movingBoard);
        movingBoard.position = newIndex - 1;

        for (Board board in favorites.sublist(oldIndex, newIndex - 1)) {
          int index = board.position!;
          board.position = index - 1;
        }
      } else {
        Board movingBoard = favorites[oldIndex];
        favorites.removeAt(oldIndex);
        favorites.insert(newIndex, movingBoard);
        movingBoard.position = newIndex;
        for (Board board in favorites.sublist(newIndex + 1)) {
          int index = board.position!;
          board.position = index + 1;
        }
      }
      // prevent index errors
      for (Board board in favorites) {
        board.position = favorites.indexOf(board);
      }
    });
    BlocProvider.of<BoardListBloc>(context).add(EditFavoritesEvent(
        favorites: favorites, action: FavoriteListAction.saveAll));
  }
}

/// List of categories. Each category contains a list of boards.
class CategoriesList extends StatelessWidget {
  const CategoriesList({
    super.key,
    required this.onOpen,
    required this.categories,
  });

  final Function onOpen;
  final List<Category> categories;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        if (categories[index].categoryName != "Пользовательские") {
          return CategoryWidget(
              onOpen: onOpen,
              category: categories[index],
              showDivider: index != 0 ||
                  (index == 0 &&
                      BlocProvider.of<BoardListBloc>(context)
                          .favorites
                          .isNotEmpty));
        }
        return const SizedBox();
      },
    );
  }
}

class IconCompleteReorder extends StatelessWidget {
  const IconCompleteReorder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.done),
      onPressed: () {
        BlocProvider.of<BoardListBloc>(context)
            .add(EditFavoritesEvent(action: FavoriteListAction.toggleReorder));
      },
    );
  }
}

class IconRefreshBoards extends StatelessWidget {
  const IconRefreshBoards({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () {
        BlocProvider.of<BoardListBloc>(context).add(RefreshBoardListEvent());
      },
    );
  }
}

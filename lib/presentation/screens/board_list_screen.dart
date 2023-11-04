import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/exceptions.dart';
import 'package:treechan/presentation/provider/page_provider.dart';
import 'package:treechan/presentation/widgets/shared/no_connection_placeholder.dart';

import '../../utils/constants/enums.dart';
import '../../domain/models/tab.dart';

import '../bloc/board_list_bloc.dart';
import '../../domain/models/category.dart';

import '../widgets/board_list/board_list_appbar.dart';
import '../widgets/board_list/category_widget.dart';

class BoardListScreen extends StatefulWidget {
  const BoardListScreen({
    super.key,
    required this.title,
  });
  final String title;
  @override
  State<BoardListScreen> createState() => _BoardListScreenState();
}

class _BoardListScreenState extends State<BoardListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late Future<List<Category>> categories;
  final controller = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
        length: 2,
        child: BlocBuilder<BoardListBloc, BoardListState>(
          builder: (context, state) {
            if (state is BoardListSearchState) {
              // if (controller.text == 'INITIALCONTROLLERTEXT') {
              //   controller.text = state.query;
              // }
              return WillPopScope(
                onWillPop: () async {
                  BlocProvider.of<BoardListBloc>(context)
                      .add(LoadBoardListEvent());
                  return Future.value(false);
                },
                child: Scaffold(
                  appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(56),
                    child: SearchAppBar(
                      controller: controller,
                    ),
                  ),
                  body: ListView.builder(
                    itemCount: state.searchResult.length,
                    itemBuilder: (context, index) {
                      final Board board = state.searchResult[index];
                      return BoardTile(board: board);
                    },
                  ),
                ),
              );
            } else {
              return Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(100),
                  child: NormalAppBar(
                    allowReorder:
                        BlocProvider.of<BoardListBloc>(context).allowReorder,
                  ),
                ),
                body: const TabBarView(children: [
                  MainBoards(),
                  UserBoards(),
                ]),
              );
            }
          },
        ));
  }
}

class MainBoards extends StatelessWidget {
  const MainBoards({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardListBloc, BoardListState>(
      builder: (context, state) {
        if (state is BoardListLoadedState) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              FavoriteBoardsList(
                favorites: state.favorites,
              ),
              CategoriesList(
                categories: state.categories,
              ),
            ],
          );
        } else if (state is BoardListErrorState) {
          if (state.exception is NoConnectionException) {
            return const NoConnectionPlaceholder();
          }
          return Center(child: Text(state.message));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class UserBoards extends StatelessWidget {
  const UserBoards({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardListBloc, BoardListState>(
        builder: (context, state) {
      if (state is BoardListLoadedState) {
        final List<Board> userBoards = state.categories
            .firstWhere(
                (category) => category.categoryName == 'Пользовательские')
            .boards;
        return ListView.builder(
          itemCount: userBoards.length,
          itemBuilder: (context, index) {
            final board = userBoards[index];
            return BoardTile(board: board);
          },
        );
      } else if (state is BoardListErrorState) {
        if (state.exception is NoConnectionException) {
          return const NoConnectionPlaceholder();
        }
        return Center(child: Text(state.message));
      }
      return const Center(child: CircularProgressIndicator());
    });
  }
}

class BoardTile extends StatelessWidget {
  const BoardTile({
    super.key,
    required this.board,
  });

  final Board board;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(board.name),
      onTap: () {
        if (BlocProvider.of<BoardListBloc>(context).state
            is BoardListSearchState) {
          FocusManager.instance.primaryFocus?.unfocus();
          BlocProvider.of<BoardListBloc>(context).add(LoadBoardListEvent());
        }
        context.read<PageProvider>().addTab(BoardTab(
            imageboard: board.imageboard,
            name: board.name,
            tag: board.id,
            prevTab: boardListTab));
      },
      onLongPress: () {
        showContextMenu(context, board);
      },
    );
  }
}

/// Appears at the top of the screen.
class FavoriteBoardsList extends StatefulWidget {
  const FavoriteBoardsList({
    super.key,
    required this.favorites,
  });

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
              title: Text(board.name),
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

  openBoard(Board board) async {
    Provider.of<PageProvider>(context, listen: false).addTab(BoardTab(
        imageboard: board.imageboard,
        name: board.name,
        tag: board.id,
        prevTab: boardListTab));
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
    required this.categories,
  });

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

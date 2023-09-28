import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/config/themes.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/presentation/screens/board_list_screen.dart';

import '../../../utils/constants/enums.dart';
import '../../bloc/board_list_bloc.dart';
import '../../../domain/models/category.dart';

/// Used in BoardListScreen to display a list of board categories..
class CategoryWidget extends StatelessWidget {
  const CategoryWidget({
    super.key,
    required this.category,
    required this.showDivider,
  });

  final Category category;
  final bool showDivider;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDivider) const Divider(thickness: 1),
        // Category name
        CategoryHeader(categoryName: category.categoryName),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: category.boards.map((board) {
            return BoardTile(board: board);
          }).toList(),
        )
      ],
    );
  }
}

class CategoryHeader extends StatelessWidget {
  const CategoryHeader({
    super.key,
    required this.categoryName,
  });

  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(categoryName,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.colors.boldText)),
    );
  }
}

/// Shows a context menu when a board is long-pressed.
Future<dynamic> showContextMenu(BuildContext context, Board board) {
  return showDialog(
      context: context,
      builder: (BuildContext bcontext) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(10),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocProvider.of<BoardListBloc>(context).favorites.contains(board)
                  ? Column(
                      children: [
                        ListTile(
                          title: const Text("Убрать из избранного"),
                          onTap: () {
                            BlocProvider.of<BoardListBloc>(context).add(
                                EditFavoritesEvent(
                                    board: board,
                                    action: FavoriteListAction.remove));
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text("Изменить порядок..."),
                          onTap: () {
                            BlocProvider.of<BoardListBloc>(context).add(
                                EditFavoritesEvent(
                                    action: FavoriteListAction.toggleReorder));
                            Navigator.pop(context);
                          },
                          visualDensity: VisualDensity.compact,
                        )
                      ],
                    )
                  : ListTile(
                      title: const Text("Добавить в избранное"),
                      onTap: () {
                        BlocProvider.of<BoardListBloc>(context).add(
                            EditFavoritesEvent(
                                board: board, action: FavoriteListAction.add));
                        Navigator.pop(context);
                      },
                      visualDensity: VisualDensity.compact,
                    ),
            ],
          ),
        );
      });
}

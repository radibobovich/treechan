import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/main.dart';
import 'package:treechan/presentation/bloc/board_bloc.dart';

import '../../../utils/constants/enums.dart';

class PopupMenuBoard extends StatelessWidget {
  const PopupMenuBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      padding: EdgeInsets.zero,
      itemBuilder: (context) {
        if (BlocProvider.of<BoardBloc>(context).boardService.sortType !=
            SortBy.page) {
          // catalog mode: can return to page mode, sort by time or bump and search
          return <PopupMenuEntry<dynamic>>[
            getViewButton(context),
            getSortButton(context),
          ];
        } else {
          // page sort mode: can go to catalog
          return <PopupMenuEntry<dynamic>>[
            getViewButton(context),
          ];
        }
      },
    );
  }

  PopupMenuItem<dynamic> getViewButton(BuildContext context) {
    if (BlocProvider.of<BoardBloc>(context).boardService.sortType ==
        SortBy.page) {
      return PopupMenuItem(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: const Text('Каталог'),
        onTap: () {
          BlocProvider.of<BoardBloc>(context).add(ChangeViewBoardEvent(null));
          // setState(() {});
        },
      );
    } else {
      return PopupMenuItem(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: const Text('Страницы'),
        onTap: () {
          BlocProvider.of<BoardBloc>(context)
              .add(ChangeViewBoardEvent(SortBy.page));
        },
      );
    }
  }

  PopupMenuItem<dynamic> getSortButton(BuildContext context) {
    if (BlocProvider.of<BoardBloc>(context).boardService.sortType ==
        SortBy.time) {
      return PopupMenuItem(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: const Text('Сортировать по бампам'),
        onTap: () {
          prefs.setString('boardSortType', 'bump');
          BlocProvider.of<BoardBloc>(context)
              .add(ChangeViewBoardEvent(SortBy.bump));
        },
      );
    } else {
      return PopupMenuItem(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: const Text('Сортировать по дате'),
        onTap: () {
          prefs.setString('boardSortType', 'time');
          BlocProvider.of<BoardBloc>(context)
              .add(ChangeViewBoardEvent(SortBy.time));
          BlocProvider.of<BoardBloc>(context).scrollToTop();
        },
      );
    }
  }

  // PopupMenuItem<dynamic> getSearchButton(BuildContext context) {
  //   return PopupMenuItem(
  //     padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
  //     child: const Text('Поиск'),
  //     onTap: () {
  //       // BlocProvider.of<BoardBloc>(context).add(ChangeViewBoardEvent(null));
  //       BlocProvider.of<BoardBloc>(context).add(SearchQueryChangedEvent(""));
  //     },
  //   );
  // }
}

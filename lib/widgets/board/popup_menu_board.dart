import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/main.dart';
import 'package:treechan/models/bloc/board_bloc.dart';
import 'package:treechan/services/board_service.dart';

class PopupMenuBoard extends StatefulWidget {
  const PopupMenuBoard({super.key});

  @override
  State<PopupMenuBoard> createState() => _PopupMenuBoardState();
}

class _PopupMenuBoardState extends State<PopupMenuBoard> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      padding: EdgeInsets.zero,
      itemBuilder: (context) {
        if (BlocProvider.of<BoardBloc>(context).boardService.sortType ==
            SortBy.page) {
          return <PopupMenuEntry<dynamic>>[
            getViewButton(context),
          ];
        } else {
          // sorry for this shitcode. it doenst allow to make it shorter
          return <PopupMenuEntry<dynamic>>[
            getViewButton(context),
            getSortButton(context),
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
          BlocProvider.of<BoardBloc>(context)
              .add(ChangeViewBoardEvent(SortBy.bump));
          setState(() {});
        },
      );
    } else {
      return PopupMenuItem(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: const Text('Страницы'),
        onTap: () {
          String prevSortType =
              prefs.getString('boardSortType').toString().split('.').last;
          SortBy type = SortBy.values.firstWhere(
              (element) => element.toString().split('.').last == prevSortType);
          BlocProvider.of<BoardBloc>(context).add(ChangeViewBoardEvent(type));
          setState(() {});
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
          setState(() {});
        },
      );
    } else {
      return PopupMenuItem(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: const Text('Сортировать по дате'),
        onTap: () {
          prefs.setString('boardSortType', 'date');
          BlocProvider.of<BoardBloc>(context)
              .add(ChangeViewBoardEvent(SortBy.time));
          setState(() {});
        },
      );
    }
  }
}

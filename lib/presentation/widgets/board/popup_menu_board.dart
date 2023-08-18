import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/main.dart';
import 'package:treechan/presentation/bloc/board_bloc.dart';
import 'package:treechan/presentation/screens/hidden_threads_screen.dart';

import '../../../domain/models/tab.dart';
import '../../../utils/constants/enums.dart';

class PopupMenuBoard extends StatelessWidget {
  final BoardTab currentTab;
  final Function onOpen;
  const PopupMenuBoard({
    super.key,
    required this.currentTab,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      padding: EdgeInsets.zero,
      itemBuilder: (popupContext) {
        if (BlocProvider.of<BoardBloc>(popupContext).boardRepository.sortType !=
            SortBy.page) {
          // catalog mode: can return to page mode, sort by time or bump and search
          return <PopupMenuEntry<dynamic>>[
            getViewButton(popupContext),
            getSortButton(popupContext),
            getHiddenThreadsButton(context, onOpen),
          ];
        } else {
          // page sort mode: can go to catalog
          return <PopupMenuEntry<dynamic>>[
            getViewButton(popupContext),
            getHiddenThreadsButton(context, onOpen),
          ];
        }
      },
    );
  }

  PopupMenuItem<dynamic> getViewButton(BuildContext context) {
    if (BlocProvider.of<BoardBloc>(context).boardRepository.sortType ==
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
    if (BlocProvider.of<BoardBloc>(context).boardRepository.sortType ==
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

  PopupMenuItem<dynamic> getHiddenThreadsButton(
      BuildContext context, Function onOpen) {
    return PopupMenuItem(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: const Text('Скрытые треды'),
      onTap: () {
        /// Use delay because handleTap() calls Navigator.pop() and interferes
        /// with the push()
        Future.delayed(
            const Duration(milliseconds: 50),
            () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HiddenThreadsScreen(
                      tag: currentTab.tag,
                      currentTab: currentTab,
                      onOpen: onOpen),
                )));
      },
    );
  }
}

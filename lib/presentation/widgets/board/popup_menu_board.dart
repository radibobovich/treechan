import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/main.dart';
import 'package:treechan/presentation/bloc/board_bloc.dart';

import '../../../domain/models/tab.dart';
import '../../../utils/constants/enums.dart';
import '../../provider/page_provider.dart';

/// Called from AppBar button.
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
        final bloc = BlocProvider.of<BoardBloc>(popupContext);
        if (bloc.boardRepository.sortType != SortBy.page) {
          // catalog mode: can return to page mode, sort by time or bump and search
          return <PopupMenuEntry<dynamic>>[
            getViewButton(popupContext, bloc),
            getSortButton(popupContext, bloc),
            getHiddenThreadsButton(popupContext, currentTab),
          ];
        } else {
          // page sort mode: can go to catalog
          return <PopupMenuEntry<dynamic>>[
            getViewButton(popupContext, bloc),
            getHiddenThreadsButton(context, currentTab),
          ];
        }
      },
    );
  }
}

/// Called from BottomNavigationBar button.
void showPopupMenuBoard(
    BuildContext context, BoardBloc bloc, BoardTab currentTab) {
  final int tilesCount = bloc.boardRepository.sortType == SortBy.page ? 2 : 3;
  final RelativeRect rect = RelativeRect.fromLTRB(
      MediaQuery.of(context).size.width - 136, // width of popup menu
      MediaQuery.of(context).size.height - tilesCount * 48 - 60,
      // 48 is the height of one tile, 60 is approx. height of bottom bars
      0,
      0);
  showMenu(
    context: context,
    position: rect,
    items: bloc.boardRepository.sortType != SortBy.page
        ? [
            getViewButton(context, bloc),
            getSortButton(context, bloc),
            getHiddenThreadsButton(context, currentTab),
          ]
        : [
            getViewButton(context, bloc),
            getHiddenThreadsButton(context, currentTab),
          ],
    elevation: 8.0,
  );
}

PopupMenuItem<dynamic> getViewButton(BuildContext context, BoardBloc bloc) {
  if (bloc.boardRepository.sortType == SortBy.page) {
    return PopupMenuItem(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: const Text('Каталог'),
      onTap: () {
        bloc.add(ChangeViewBoardEvent(null));
        // setState(() {});
      },
    );
  } else {
    return PopupMenuItem(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: const Text('Страницы'),
      onTap: () {
        bloc.add(ChangeViewBoardEvent(SortBy.page));
      },
    );
  }
}

PopupMenuItem<dynamic> getSortButton(BuildContext context, BoardBloc bloc) {
  if (bloc.boardRepository.sortType == SortBy.time) {
    return PopupMenuItem(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: const Text('Сортировать по бампам'),
      onTap: () {
        prefs.setString('boardSortType', 'bump');
        bloc.add(ChangeViewBoardEvent(SortBy.bump));
      },
    );
  } else {
    return PopupMenuItem(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: const Text('Сортировать по дате'),
      onTap: () {
        prefs.setString('boardSortType', 'time');
        bloc.add(ChangeViewBoardEvent(SortBy.time));
        bloc.scrollToTop();
      },
    );
  }
}

PopupMenuItem<dynamic> getHiddenThreadsButton(
    BuildContext context, BoardTab currentTab) {
  return PopupMenuItem(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: const Text('Скрытые треды'),
    onTap: () {
      /// Use delay because handleTap() calls Navigator.pop() and interferes
      /// with the push()
      Future.delayed(
          const Duration(milliseconds: 50),
          () => Navigator.pushNamed(context, '/hidden_threads', arguments: {
                'currentTab': currentTab,
                'onOpen': (ThreadTab tab) =>
                    context.read<PageProvider>().addTab(tab)
              }));
    },
  );
}

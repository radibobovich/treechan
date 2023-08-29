import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/tab.dart';
import '../../domain/repositories/board_list_repository.dart';
import '../../domain/repositories/board_repository.dart';
import '../../domain/repositories/thread_repository.dart';

import '../bloc/board_list_bloc.dart' as board_list;
import '../bloc/board_bloc.dart';
import '../bloc/branch_bloc.dart';
import '../bloc/thread_bloc.dart';
import '../screens/board_list_screen.dart';
import '../screens/board_screen.dart';
import '../screens/branch_screen.dart';
import '../screens/thread_screen.dart';
import 'page_provider.dart';

/// Handles creating blocs and screens for tabs.
class BlocHandler {
  BlocHandler({required tabs, required provider}) {
    _tabs = tabs;
    _provider = provider;
  }
  static late final Map<DrawerTab, dynamic> _tabs;
  static late final PageProvider _provider;

  /// Adds a new screen to the _blocs list.
  /// Called when a new tab is opened.
  dynamic createBloc(DrawerTab tab) {
    switch (tab.runtimeType) {
      case BoardListTab:
        return board_list.BoardListBloc(
            key: ValueKey(tab), boardListService: BoardListRepository())
          ..add(board_list.LoadBoardListEvent());
      case BoardTab:
        if ((tab as BoardTab).isCatalog == false) {
          return BoardBloc(
              key: ValueKey(tab),
              tabProvider: _provider,
              boardRepository: BoardRepository(boardTag: tab.tag))
            ..add(LoadBoardEvent());
        } else {
          return BoardBloc(
              key: ValueKey(tab),
              tabProvider: _provider,
              boardRepository: BoardRepository(boardTag: tab.tag))
            ..add(ChangeViewBoardEvent(null, query: tab.query));
        }
      case ThreadTab:
        return ThreadBloc(
            key: ValueKey(tab),
            threadRepository: ThreadRepository(
                boardTag: (tab as ThreadTab).tag, threadId: tab.id),
            tab: tab,
            provider: _provider)
          ..add(LoadThreadEvent());
      case BranchTab:
        return BranchBloc(
            // find a thread related to the branch
            threadBloc: _tabs.entries
                .firstWhere((entry) =>
                    entry.value is ThreadBloc &&
                    entry.key == (tab as BranchTab).getParentThreadTab())
                .value,
            currentTab: tab as BranchTab,
            // prevTab: tab.prevTab as IdMixin,
            key: ValueKey(tab),
            provider: _provider)
          ..add(LoadBranchEvent());
    }
  }

  /// Returns BoardListScreen for TabBarView children.
  BlocProvider<board_list.BoardListBloc> getBoardListScreen(BoardListTab tab) {
    return BlocProvider.value(
      key: GlobalObjectKey(tab),
      value: _tabs[tab],
      child: const BoardListScreen(title: "Доски"),
    );
  }

  /// Returns BoardScreen for TabBarView children.
  BlocProvider<BoardBloc> getBoardScreen(BoardTab tab) {
    return BlocProvider.value(
      key: GlobalObjectKey(tab),
      value: _tabs[tab],
      child: BoardScreen(
        key: ValueKey(tab),
        currentTab: tab,
      ),
    );
  }

  /// Returns ThreadScreen for TabBarView children.
  BlocProvider<ThreadBloc> getThreadScreen(ThreadTab tab) {
    return BlocProvider.value(
      key: GlobalObjectKey(tab),
      value: _tabs[tab],
      child: ThreadScreen(
        currentTab: tab,
        prevTab: tab.prevTab,
      ),
    );
  }

  BlocProvider<BranchBloc> getBranchScreen(BranchTab tab) {
    return BlocProvider.value(
      key: GlobalObjectKey(tab),
      value: _tabs[tab],
      child: BranchScreen(
        currentTab: tab,
      ),
    );
  }
}

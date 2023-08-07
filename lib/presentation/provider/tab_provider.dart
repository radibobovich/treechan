import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/domain/models/catalog.dart';
import 'package:treechan/presentation/screens/tab_navigator.dart';

import '../../data/history_database.dart';
import '../../domain/models/tab.dart';
import '../../domain/services/board_list_service.dart';
import '../../domain/services/board_service.dart';
import '../../domain/services/thread_service.dart';
import '../../utils/constants/enums.dart';
import '../bloc/board_bloc.dart';
import '../bloc/board_list_bloc.dart';
import '../bloc/branch_bloc.dart';
import '../bloc/thread_bloc.dart';
import '../screens/board_list_screen.dart';
import '../screens/board_screen.dart';
import '../screens/branch_screen.dart';
import '../screens/thread_screen.dart';

class TabProvider with ChangeNotifier {
  final StreamController<Catalog> _catalog =
      StreamController<Catalog>.broadcast();
  Stream<Catalog> get catalogStream => _catalog.stream;

  /// Contains all opened drawer tabs.
  final Map<DrawerTab, dynamic> _tabs = {};
  Map<DrawerTab, dynamic> get tabs => _tabs;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  int dummy = 0;
  late TabController tabController;
  late TabNavigatorState state;
  void initController(TabNavigatorState gotState) {
    state = gotState;
    tabController = TabController(length: 0, vsync: state);
  }

  void _refreshController() {
    tabController = TabController(length: tabs.length, vsync: state);
  }

  void animateTo(int index) {
    _currentIndex = index;
    tabController.animateTo(index);
    notifyListeners();
  }

  bool isActive(DrawerTab tab) {
    return true;
    // return _tabs.keys.toList().indexOf(tab) == currentIndex;
  }

  void addTab(DrawerTab tab) async {
    if (!_tabs.containsKey(tab)) {
      _tabs[tab] = _createBloc(tab);
      int currentIndex = tabController.index;
      _refreshController();
      // avoid blinking first page during opening new tab
      tabController.index = currentIndex;
    }
    notifyListeners();
    await Future.delayed(
        const Duration(milliseconds: 20)); // enables transition animation
    animateTo(_tabs.keys.toList().indexOf(tab));
    HistoryDatabase().add(tab);
  }

  void removeTab(DrawerTab tab) {
    int currentIndex = _currentIndex;
    int removingTabIndex = _tabs.keys.toList().indexOf(tab);
    _tabs[tab].close();
    tabs.remove(tab);
    _refreshController();
    if (currentIndex == removingTabIndex) {
      // if you close the current tab
      try {
        // if you have a previous tab that still exists, go to it.
        // if it doesn't exist, you will get an assertion error (indexOf returns -1)
        // so you go to the board list.
        // if you don't have previous tab, you go to the board list.
        animateTo(_tabs.keys.toList().indexOf(tab.prevTab!));

        return;
      } on AssertionError {
        // if prevTab was closed before this tab
        animateTo(_tabs.keys.toList().indexOf(boardListTab));
        return;
      }
    }
    // else if you close a tab that is not the current tab
    if (currentIndex > removingTabIndex) {
      // if current tab is after the removed tab, go to the previous tab
      // because the current tab id will decrease by 1
      animateTo(currentIndex - 1);
      return;
    }
    // else if current tab is before the removed tab, just restore currentIndex in controller
    // because the tabController resets its index to 0 after recreating.
    animateTo(currentIndex);
    notifyListeners();
  }

  void goBack() {
    DrawerTab currentTab = tabs.keys.elementAt(currentIndex);
    int prevTabId = tabs.keys.toList().indexOf(currentTab.prevTab!);
    if (prevTabId == -1) {
      if (_currentIndex > 0) {
        animateTo(currentIndex - 1);
      }
    } else {
      animateTo(prevTabId);
    }
  }

  /// Sets name of the tab if it was created with null name.
  void setName(DrawerTab tab, String name) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tab.name = name;
      HistoryDatabase().add(tab);
    });
  }

  void openCatalog({required String boardTag, required String searchTag}) {
    _catalog.add(Catalog(boardTag: boardTag, searchTag: searchTag));
    final int index = _tabs.keys
        .toList()
        .indexWhere((tab) => tab is BoardTab && tab.tag == boardTag);
    if (index != -1) {
      animateTo(index);
    } else {
      addTab(BoardTab(
        tag: boardTag,
        prevTab: _tabs[_currentIndex],
        isCatalog: true,
        searchTag: searchTag,
      ));
    }
  }

  /// Adds a new screen to the _blocs list.
  /// Called when a new tab is opened.
  dynamic _createBloc(DrawerTab tab) {
    switch (tab.runtimeType) {
      case BoardListTab:
        return BoardListBloc(
            key: ValueKey(tab), boardListService: BoardListService())
          ..add(LoadBoardListEvent());
      case BoardTab:
        if ((tab as BoardTab).isCatalog == false) {
          return BoardBloc(
              key: ValueKey(tab),
              tabProvider: this,
              boardService: BoardService(boardTag: tab.tag))
            ..add(LoadBoardEvent());
        } else {
          return BoardBloc(
              key: ValueKey(tab),
              tabProvider: this,
              boardService: BoardService(boardTag: tab.tag))
            ..add(ChangeViewBoardEvent(null, searchTag: tab.searchTag));
        }
      case ThreadTab:
        return ThreadBloc(
            key: ValueKey(tab),
            threadService: ThreadService(
                boardTag: tab.tag, threadId: (tab as ThreadTab).id),
            tab: tab,
            provider: this)
          ..add(LoadThreadEvent());
      case BranchTab:
        return BranchBloc(
            // find a thread related to the branch
            threadBloc: _tabs.entries
                .firstWhere((entry) =>
                    entry.value is ThreadBloc && entry.key == tab.prevTab)
                .value,
            postId: (tab as BranchTab).id,
            prevTab: tab.prevTab!,
            key: ValueKey(tab))
          ..add(LoadBranchEvent());
    }
  }

  /// Called when a thread has been refreshed.
  void refreshRelatedBranches(DrawerTab threadTab, int lastIndex) {
    for (var bloc in _tabs.values) {
      if (bloc.runtimeType == BranchBloc && bloc.prevTab == threadTab) {
        (bloc as BranchBloc).add(
            RefreshBranchEvent(RefreshSource.thread, lastIndex: lastIndex));
      }
    }
  }

  /// Returns BoardListScreen for TabBarView children.
  BlocProvider<BoardListBloc> getBoardListScreen(DrawerTab tab) {
    return BlocProvider.value(
      key: GlobalObjectKey(tab),
      value: _tabs[tab],
      child: const BoardListScreen(title: "Доски"),
    );
  }

  /// Returns BoardScreen for TabBarView children.
  BlocProvider<BoardBloc> getBoardScreen(DrawerTab tab) {
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
  BlocProvider<ThreadBloc> getThreadScreen(DrawerTab tab) {
    return BlocProvider.value(
      key: GlobalObjectKey(tab),
      value: _tabs[tab],
      child: ThreadScreen(
        currentTab: tab,
        prevTab: tab.prevTab!,
      ),
    );
  }

  BlocProvider<BranchBloc> getBranchScreen(DrawerTab tab) {
    return BlocProvider.value(
      key: GlobalObjectKey(tab),
      value: _tabs[tab],
      child: BranchScreen(
        currentTab: tab,
      ),
    );
  }

  @override
  void dispose() {
    _catalog.close();
    super.dispose();
  }
}

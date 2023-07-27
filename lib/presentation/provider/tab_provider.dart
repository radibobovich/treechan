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
  final List<DrawerTab> _tabs = [];
  List<DrawerTab> get tabs => _tabs;

  /// Contains all opened screens.
  final List<dynamic> _blocs = [];
  List<dynamic> get blocs => _blocs;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  late TabController tabController;
  late TabNavigatorState state;
  void initController(TabNavigatorState gotState) {
    state = gotState;
    tabController = TabController(length: 0, vsync: state);
  }

  void refreshController() {
    tabController = TabController(length: tabs.length, vsync: state);
  }

  void animateTo(int index) {
    _currentIndex = index;
    tabController.animateTo(index);
    notifyListeners();
  }

  void addTab(DrawerTab tab) async {
    assert(tab.prevTab != null || tab.type == TabTypes.boardList);
    if (!_tabs.contains(tab)) {
      _tabs.add(tab);
      addBloc(tab);
      int currentIndex = tabController.index;
      refreshController();
      // avoid blinking first page during opening new tab
      tabController.index = currentIndex;
    }
    notifyListeners();
    await Future.delayed(
        const Duration(milliseconds: 20)); // enables transition animation
    animateTo(_tabs.indexOf(tab));
    HistoryDatabase().add(tab.toHistoryTab());
  }

  void removeTab(DrawerTab tab) {
    int currentIndex = _currentIndex;
    int removingTabIndex = tabs.indexOf(tab);

    tabs.remove(tab);
    _blocs.removeWhere((bloc) {
      if (bloc.key == ValueKey(tab)) {
        bloc.close();
        return true;
      }
      return false;
    });
    refreshController();
    if (currentIndex == removingTabIndex) {
      // if you close the current tab
      try {
        // if you have a previous tab that still exists, go to it.
        // if it doesn't exist, you will get an assertion error (indexOf returns -1)
        // so you go to the board list.
        // if you don't have previous tab, you go to the board list.
        animateTo(tabs.indexOf(tab.prevTab ?? boardListTab));

        return;
      } on AssertionError {
        // if prevTab was closed before this tab
        animateTo(tabs.indexOf(boardListTab));
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
    DrawerTab currentTab = tabs[currentIndex];
    if (currentTab.prevTab == null) {
      animateTo(tabs.indexOf(boardListTab));
      return;
    }
    int prevTabId = tabs.indexOf(currentTab.prevTab!);
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
      HistoryDatabase().add(tab.toHistoryTab());
    });
  }

  void openCatalog({required String boardTag, required String searchTag}) {
    _catalog.add(Catalog(boardTag: boardTag, searchTag: searchTag));
    final int index = _tabs
        .indexWhere((tab) => tab.type == TabTypes.board && tab.tag == boardTag);
    if (index != -1) {
      animateTo(index);
    } else {
      addTab(DrawerTab(
        type: TabTypes.board,
        tag: boardTag,
        prevTab: _tabs[_currentIndex],
        isCatalog: true,
        searchTag: searchTag,
      ));
    }
  }

  /// Adds a new screen to the _blocs list.
  /// Called when a new tab is opened.
  void addBloc(DrawerTab tab) {
    switch (tab.type) {
      case TabTypes.boardList:
        _blocs.add(BoardListBloc(
            key: ValueKey(tab), boardListService: BoardListService())
          ..add(LoadBoardListEvent()));
        break;
      case TabTypes.board:
        tab.isCatalog == null
            ? _blocs.add(BoardBloc(
                key: ValueKey(tab),
                tabProvider: this,
                boardService: BoardService(boardTag: tab.tag))
              ..add(LoadBoardEvent()))
            : _blocs.add(BoardBloc(
                key: ValueKey(tab),
                tabProvider: this,
                boardService: BoardService(boardTag: tab.tag))
              ..add(ChangeViewBoardEvent(null, searchTag: tab.searchTag)));
        break;
      case TabTypes.thread:
        _blocs.add(ThreadBloc(
            key: ValueKey(tab),
            threadService: ThreadService(boardTag: tab.tag, threadId: tab.id!),
            tab: tab,
            provider: this)
          ..add(LoadThreadEvent()));
        break;
      case TabTypes.branch:
        _blocs.add(BranchBloc(
            // find a thread related to the branch
            threadBloc: _blocs.firstWhere(
                (bloc) => bloc is ThreadBloc && bloc.tab == tab.prevTab),
            postId: tab.id!,
            prevTab: tab.prevTab!,
            key: ValueKey(tab))
          ..add(LoadBranchEvent()));
    }
  }

  /// Picks a bloc requested by BlocProvider with desired type.
  T _getSpecificBloc<T>(DrawerTab tab) {
    List<Type> allowedTypes = [
      BoardListBloc,
      BoardBloc,
      ThreadBloc,
      BranchBloc
    ];
    if (!allowedTypes.contains(T)) {
      throw Exception('Wrong bloc type.');
    }
    return _blocs.firstWhere(
        (bloc) => bloc.runtimeType == T && bloc.key == ValueKey(tab));
  }

  /// Called when a thread has been refreshed.
  void refreshRelatedBranches(DrawerTab threadTab, int lastIndex) {
    for (var bloc in _blocs) {
      if (bloc.runtimeType == BranchBloc && bloc.prevTab == threadTab) {
        (bloc as BranchBloc).add(
            RefreshBranchEvent(RefreshSource.thread, lastIndex: lastIndex));
      }
    }
  }

  /// Returns BoardListScreen for TabBarView children.
  BlocProvider<BoardListBloc> getBoardListScreen(DrawerTab tab) {
    return BlocProvider.value(
      key: ValueKey(tab),
      value: _getSpecificBloc<BoardListBloc>(tab),
      child: const BoardListScreen(title: "Доски"),
    );
  }

  /// Returns BoardScreen for TabBarView children.
  BlocProvider<BoardBloc> getBoardScreen(DrawerTab tab) {
    return BlocProvider.value(
      key: ValueKey(tab),
      value: _getSpecificBloc<BoardBloc>(tab),
      child: BoardScreen(
        currentTab: tab,
      ),
    );
  }

  /// Returns ThreadScreen for TabBarView children.
  BlocProvider<ThreadBloc> getThreadScreen(DrawerTab tab) {
    return BlocProvider.value(
      key: ValueKey(tab),
      value: _getSpecificBloc<ThreadBloc>(tab),
      child: ThreadScreen(
        currentTab: tab,
        prevTab: tab.prevTab ?? boardListTab,
      ),
    );
  }

  BlocProvider<BranchBloc> getBranchScreen(DrawerTab tab) {
    return BlocProvider.value(
      key: ValueKey(tab),
      value: _getSpecificBloc<BranchBloc>(tab),
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

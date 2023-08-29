import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/presentation/provider/bloc_handler.dart';
import 'package:treechan/presentation/provider/page_provider.dart';

import '../../data/history_database.dart';
import '../../domain/models/catalog.dart';
import '../../domain/models/tab.dart';

import '../../utils/constants/enums.dart';
import '../bloc/board_bloc.dart';
import '../bloc/board_list_bloc.dart' as board_list;
import '../bloc/branch_bloc.dart';
import '../bloc/thread_bloc.dart';

import '../screens/page_navigator.dart';

class TabManager {
  /// Contains all opened drawer tabs in pair with their blocs.
  final Map<DrawerTab, dynamic> _tabs = {};
  Map<DrawerTab, dynamic> get tabs => _tabs;

  int _currentTabIndex = 0;
  int get currentIndex => _currentTabIndex;
  DrawerTab get currentTab => _tabs.entries.toList()[_currentTabIndex].key;

  dynamic get currentBloc => _tabs[currentTab];

  late TabController tabController;
  late final PageNavigatorState state;
  late final Function() notifyListeners;
  late final PageProvider provider;
  late final BlocHandler blocHandler;
  void init(PageNavigatorState gotState, Function() notifyCallback,
      PageProvider provider) {
    state = gotState;
    tabController = TabController(length: 0, vsync: state);
    notifyListeners = notifyCallback;
    this.provider = provider;
    blocHandler = BlocHandler(tabs: _tabs, provider: provider);
  }

  BlocProvider<board_list.BoardListBloc> getBoardListScreen(BoardListTab tab) =>
      blocHandler.getBoardListScreen(tab);
  BlocProvider<BoardBloc> getBoardScreen(BoardTab tab) =>
      blocHandler.getBoardScreen(tab);
  BlocProvider<ThreadBloc> getThreadScreen(ThreadTab tab) =>
      blocHandler.getThreadScreen(tab);
  BlocProvider<BranchBloc> getBranchScreen(BranchTab tab) =>
      blocHandler.getBranchScreen(tab);

  void animateTo(int index) {
    _currentTabIndex = index;
    tabController.animateTo(index);
    notifyListeners();
  }

  void _refreshController() {
    tabController = TabController(length: tabs.length, vsync: state);
  }

  void addTab(DrawerTab tab) async {
    if (!_tabs.containsKey(tab)) {
      _tabs[tab] = blocHandler.createBloc(tab);
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

  void removeTab(DrawerTab tab) async {
    int currentIndex = _currentTabIndex;
    int removingTabIndex = _tabs.keys.toList().indexOf(tab);
    tabs.remove(tab);
    _refreshController();
    if (currentIndex == removingTabIndex) {
      // if you close the current tab
      try {
        // if you have a previous tab that still exists, go to it.
        // if it doesn't exist, you will get an assertion error (indexOf returns -1)
        // so you go to the board list.
        // if you don't have previous tab, you go to the board list.
        animateTo(_tabs.keys.toList().indexOf((tab as TagMixin).prevTab));

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
    if (currentTab is BoardListTab) {
      return;
    }

    /// Prevent pop if pressed back button while in search mode
    final currentBloc = tabs[currentTab];
    if (currentBloc is BoardBloc && currentBloc.state is BoardSearchState) {
      currentBloc.add(LoadBoardEvent());
      return;
    }
    int prevTabId =
        tabs.keys.toList().indexOf((currentTab as TagMixin).prevTab);
    if (prevTabId == -1) {
      if (_currentTabIndex > 0) {
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

  void openCatalog({required String boardTag, required String query}) {
    provider.catalog.add(Catalog(boardTag: boardTag, searchTag: query));
    final int index = _tabs.keys
        .toList()
        .indexWhere((tab) => tab is BoardTab && tab.tag == boardTag);
    if (index != -1) {
      animateTo(index);
    } else {
      addTab(BoardTab(
        tag: boardTag,
        prevTab: _tabs.keys.toList()[_currentTabIndex],
        isCatalog: true,
        query: query,
      ));
    }
  }

  IdMixin findTab({required String tag, int? threadId, int? branchId}) {
    assert(threadId != null || branchId != null,
        'you must specify threadId or branchId');
    if (threadId != null) {
      return _tabs.keys.firstWhere(
          (tab) => tab is ThreadTab && tab.tag == tag && tab.id == threadId,
          orElse: () => ThreadTab(
              name: null,
              tag: 'error',
              prevTab: boardListTab,
              id: -1)) as IdMixin;
    } else {
      return _tabs.keys.firstWhere(
          (tab) => tab is BranchTab && tab.tag == tag && tab.id == branchId,
          orElse: () => BranchTab(
              name: null,
              tag: 'error',
              prevTab: boardListTab,
              id: -1)) as IdMixin;
    }
  }

  void refreshTab({DrawerTab? tab, RefreshSource? source}) {
    final currentBloc = _tabs[tab ?? currentTab];

    if (currentBloc is board_list.BoardListBloc) {
      currentBloc.add(board_list.RefreshBoardListEvent());
    } else if (currentBloc is BoardBloc) {
      currentBloc.add(RefreshBoardEvent());
    } else if (currentBloc is ThreadBloc) {
      currentBloc
          .add(RefreshThreadEvent(source: source ?? RefreshSource.thread));
    } else if (currentBloc is BranchBloc) {
      currentBloc.add(RefreshBranchEvent(source ?? RefreshSource.branch));
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
}

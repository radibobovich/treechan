import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:treechan/data/local/history_database.dart';
import 'package:treechan/di/injection.dart';
import 'package:treechan/domain/repositories/manager/thread_repository_manager.dart';
import 'package:treechan/domain/services/scroll_service.dart';
import 'package:treechan/presentation/provider/bloc_handler.dart';
import 'package:treechan/presentation/provider/page_provider.dart';

import '../../domain/models/catalog.dart';
import '../../domain/models/tab.dart';

import '../../domain/repositories/manager/branch_repository_manager.dart';
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
    appLifeCycleStreamController.stream.listen((event) {
      if (event == FGBGType.foreground) {
        isAppInForeground = true;
      } else {
        isAppInForeground = false;
      }
    });
  }

  bool isAppInForeground = true;
  StreamController<FGBGType> appLifeCycleStreamController =
      StreamController<FGBGType>.broadcast();

  BlocProvider<board_list.BoardListBloc> getBoardListScreen(BoardListTab tab) =>
      blocHandler.getBoardListScreen(tab);
  BlocProvider<BoardBloc> getBoardScreen(BoardTab tab) =>
      blocHandler.getBoardScreen(tab);
  BlocProvider<ThreadBloc> getThreadScreen(ThreadTab tab) =>
      blocHandler.getThreadScreen(tab);
  BlocProvider<BranchBloc> getBranchScreen(BranchTab tab) =>
      blocHandler.getBranchScreen(tab);

  void animateTo(int index) {
    if (provider.currentPageIndex != 2) provider.setCurrentPageIndex(2);
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
    getIt<IHistoryDatabase>().add(tab);
  }

  void removeTab(DrawerTab tab) async {
    int currentIndex = _currentTabIndex;
    int removingTabIndex = _tabs.keys.toList().indexOf(tab);
    tabs[tab].close();
    tabs.remove(tab);

    /// If tab is not tracked, remove it from repository manager
    if (tab is IdMixin &&
        !await provider.trackerRepository.isTracked(tab as IdMixin)) {
      if (tab is ThreadTab) {
        /// Dont remove thread repo if there are related branches
        if (!_tabs.keys
            .any((tab) => tab is BranchTab && tab.threadId == tab.id)) {
          ThreadRepositoryManager().remove(tab.tag, tab.id);
        }
      }
      if (tab is BranchTab) BranchRepositoryManager().remove(tab.tag, tab.id);
    }
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
      provider.currentPageIndex = 2;
      notifyListeners();
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
      getIt<IHistoryDatabase>().add(tab);
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

  /// Returns [ThreadTab] or [BranchTab] with specified tag and id.
  ///
  /// Returns tab with id = -1 if tab was not found.
  ///
  /// Do not use this method to search for board tabs.
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
              name: '',
              tag: 'error',
              prevTab: boardListTab,
              threadId: -1,
              id: -1)) as IdMixin;
    }
  }

  /// Called from bottom navigation bar or from tracker.
  bool refreshTab({DrawerTab? tab, RefreshSource? source}) {
    tab ??= currentTab;
    final bloc = _tabs[tab];
    // final currentTabBloc = _tabs[currentTab];
    if (bloc is board_list.BoardListBloc) {
      bloc.add(board_list.RefreshBoardListEvent());
    } else if (bloc is BoardBloc) {
      bloc.add(ReloadBoardEvent());
    } else if (bloc is ThreadBloc) {
      /// we don't want to auto refresh tab if it is currently opened
      /// (bad UX)
      if (source == RefreshSource.tracker &&
          tab == currentTab &&
          isAppInForeground) return false;
      bloc.add(RefreshThreadEvent(source: source ?? RefreshSource.thread));
    } else if (bloc is BranchBloc) {
      /// Prevent refresh of currently opened tab from tracker

      if (isAppInForeground) {
        if (source == RefreshSource.tracker) {
          if (tab == currentTab) {
            return false;
          }
        }
      }
      bloc.add(RefreshBranchEvent(source ?? RefreshSource.branch));
    }
    return true;
  }

  /// Called when a thread has been refreshed.
  void refreshRelatedBranches(ThreadTab threadTab, int lastIndex) {
    for (var bloc in _tabs.values) {
      if (bloc is BranchBloc &&
          (bloc.tab as BranchTab).threadId == threadTab.id) {
        bloc.add(
            RefreshBranchEvent(RefreshSource.thread, lastIndex: lastIndex));
      }
    }
  }

  ScrollService? getThreadScrollService(
      {required String boardTag, required int threadId}) {
    final tab = findTab(tag: boardTag, threadId: threadId);
    if (tab.id == -1) {
      return null;
    }
    if (tab is ThreadTab) {
      return (tabs[tab] as ThreadBloc).scrollService;
    } else {
      throw Exception('tab is not ThreadTab');
    }
  }
}

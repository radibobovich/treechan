import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/domain/models/catalog.dart';
import 'package:treechan/presentation/screens/page_navigator.dart';

import '../../data/history_database.dart';
import '../../domain/models/tab.dart';
import '../../domain/services/board_list_service.dart';
import '../../domain/services/board_service.dart';
import '../../domain/services/thread_service.dart';
import '../../utils/constants/enums.dart';
import '../bloc/board_bloc.dart';
import '../bloc/board_list_bloc.dart' as board_list;
import '../bloc/branch_bloc.dart';
import '../bloc/thread_bloc.dart';
import '../screens/board_list_screen.dart';
import '../screens/board_screen.dart';
import '../screens/branch_screen.dart';
import '../screens/thread_screen.dart';

/// Manages everything related to tabs and pages.
class PageProvider with ChangeNotifier {
  /// The stream is listened by new [BoardBloc] to check if you need to switch
  /// the board screen to a catalog mode.
  final StreamController<Catalog> _catalog =
      StreamController<Catalog>.broadcast();
  Stream<Catalog> get catalogStream => _catalog.stream;

  late final List<Widget> _pages = [
    const Placeholder(),
    const Placeholder(),
    BrowserScreen(provider: this),
  ];
  Widget get currentPage => getCurrentPage();

  int _currentPageIndex = 2;
  int get currentPageIndex => _currentPageIndex;

  DrawerTab get currentTab => _tabs.entries.toList()[_currentTabIndex].key;

  /// Contains all opened drawer tabs.
  final Map<DrawerTab, dynamic> _tabs = {};
  Map<DrawerTab, dynamic> get tabs => _tabs;

  int _currentTabIndex = 0;
  int get currentIndex => _currentTabIndex;
  int dummy = 0;
  late TabController tabController;
  late final PageNavigatorState state;
  void init(PageNavigatorState gotState) {
    state = gotState;
    tabController = TabController(length: 0, vsync: state);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        currentPageIndex = 2;
      },
    );
  }

  void _refreshController() {
    tabController = TabController(length: tabs.length, vsync: state);
  }

  void animateTo(int index) {
    _currentTabIndex = index;
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
    _catalog.add(Catalog(boardTag: boardTag, searchTag: query));
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

  void openSearch() {}

  /// Adds a new screen to the _blocs list.
  /// Called when a new tab is opened.
  dynamic _createBloc(DrawerTab tab) {
    switch (tab.runtimeType) {
      case BoardListTab:
        return board_list.BoardListBloc(
            key: ValueKey(tab), boardListService: BoardListService())
          ..add(board_list.LoadBoardListEvent());
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
            ..add(ChangeViewBoardEvent(null, query: tab.query));
        }
      case ThreadTab:
        return ThreadBloc(
            key: ValueKey(tab),
            threadService: ThreadService(
                boardTag: (tab as ThreadTab).tag, threadId: tab.id),
            tab: tab,
            provider: this)
          ..add(LoadThreadEvent());
      case BranchTab:
        return BranchBloc(
            // find a thread related to the branch
            threadBloc: _tabs.entries
                .firstWhere((entry) =>
                    entry.value is ThreadBloc &&
                    entry.key == (tab as BranchTab).prevTab)
                .value,
            postId: (tab as BranchTab).id,
            prevTab: tab.prevTab as IdMixin,
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

  set currentPageIndex(int index) {
    if (index == 3) {
      refreshTab();
      return;
    } else if (index == 4) {
      openActions();
      return;
    }

    /// close search when leaving search page
    if (_currentPageIndex == 0) {
      final bloc = _tabs[currentTab];
      if (bloc is board_list.BoardListBloc) {
        bloc.add(board_list.LoadBoardListEvent());
      } else if (bloc is BoardBloc) {
        bloc.add(LoadBoardEvent());
      } else {
        // coming soon
      }
    }

    /// Refresh and action buttons have no indication
    if (index == 3 || index == 4) return;
    _currentPageIndex = index;
    notifyListeners();
  }

  Widget getCurrentPage() {
    if (_currentPageIndex == 0) {
      final currentBloc = _tabs[currentTab];

      if (currentBloc is board_list.BoardListBloc) {
        currentBloc.add(board_list.SearchQueryChangedEvent(''));
      } else if (currentBloc is BoardBloc) {
        currentBloc.add(SearchQueryChangedEvent(''));
      } else {
        // search for thread and branch
      }
      return _pages[2];
    } else {
      return _pages[_currentPageIndex];
    }
  }

  void refreshTab() {
    final currentBloc = _tabs[currentTab];

    if (currentBloc is board_list.BoardListBloc) {
      currentBloc.add(board_list.RefreshBoardListEvent());
    } else if (currentBloc is BoardBloc) {
      currentBloc.add(ChangeViewBoardEvent(null, query: ''));
    } else if (currentBloc is ThreadBloc) {
      currentBloc.add(RefreshThreadEvent());
    } else if (currentBloc is BranchBloc) {
      currentBloc.add(RefreshBranchEvent(RefreshSource.branch));
    }
  }

  void openActions() {
    // coming soon
  }

  @override
  void dispose() {
    _catalog.close();
    super.dispose();
  }
}

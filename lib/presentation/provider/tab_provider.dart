import 'dart:async';

import 'package:flutter/material.dart';
import 'package:treechan/domain/models/catalog.dart';
import 'package:treechan/presentation/screens/tab_navigator.dart';

import '../../data/history_database.dart';
import '../../domain/models/tab.dart';
import '../../utils/constants/enums.dart';

class TabProvider with ChangeNotifier {
  final StreamController<Catalog> _catalog =
      StreamController<Catalog>.broadcast();
  Stream<Catalog> get catalogStream => _catalog.stream;

  // TabController tabController =
  //     TabController(length: 0, vsync: navState as TickerProvider);
  final List<DrawerTab> _tabs = [];
  List<DrawerTab> get tabs => _tabs;
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
    if (!_tabs.contains(tab)) {
      _tabs.add(tab);
      refreshController();
    }
    notifyListeners();
    await Future.delayed(
        const Duration(milliseconds: 20)); // enables transition animation
    animateTo(_tabs.indexOf(tab));
  }

  void removeTab(DrawerTab tab) {
    // int currentIndex = tabController.index;
    int currentIndex = _currentIndex;
    int removingTabIndex = tabs.indexOf(tab);

    tabs.remove(tab);
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

  @override
  void dispose() {
    _catalog.close();
    super.dispose();
  }
}

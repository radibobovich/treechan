import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/models/tab.dart';

class TabBloc extends Bloc<TabEvent, TabState> {
  final List<DrawerTab> _tabs = [];
  List<DrawerTab> get tabs => _tabs;
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  TabBloc() : super(TabInitialState()) {
    on<OpenCatalogEvent>((event, emit) async {
      emit(OpenCatalogState(
          boardTag: event.boardTag, searchTag: event.searchTag));
      emit(TabInitialState());
    });
    on<TabUpdateEvent>((event, emit) async {
      emit(TabInitialState());
    });
  }
  void openCatalog({required String boardTag, required String searchTag}) {
    add(OpenCatalogEvent(boardTag: boardTag, searchTag: searchTag));
  }

  void animateTo(int index) {
    _currentIndex = index;
  }

  void addTab(DrawerTab tab) {
    if (!_tabs.contains(tab)) {
      _tabs.add(tab);
      // tabController = TabController(length: _tabs.length, vsync: state);
      // WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      // notifyListeners();
      // recreate();

      // WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
    // tabController.animateTo(_tabs.indexOf(tab));
    animateTo(_tabs.indexOf(tab));
  }

  void removeTab(DrawerTab tab) {
    // int currentIndex = tabController.index;
    int currentIndex = _currentIndex;
    int removingTabIndex = tabs.indexOf(tab);

    tabs.remove(tab);

    // tabController = TabController(length: tabs.length, vsync: state);
    // recreate();

    if (currentIndex == removingTabIndex) {
      // if you close the current tab
      try {
        // if you have a previous tab that still exists, go to it.
        // if it doesn't exist, you will get an assertion error (indexOf returns -1)
        // so you go to the board list.
        // if you don't have previous tab, you go to the board list.
        // tabController.animateTo(tabs.indexOf(tab.prevTab ?? boardListTab));
        animateTo(tabs.indexOf(tab.prevTab ?? boardListTab));

        return;
      } on AssertionError {
        // if prevTab was closed before this tab
        // tabController.animateTo(tabs.indexOf(boardListTab));
        animateTo(tabs.indexOf(boardListTab));
        return;
      }
    }
    // else if you close a tab that is not the current tab
    if (currentIndex > removingTabIndex) {
      // if current tab is after the removed tab, go to the previous tab
      // because the current tab id will decrease by 1
      // tabController.animateTo(currentIndex - 1);
      animateTo(currentIndex - 1);
      return;
    }
    // else if current tab is before the removed tab, just restore currentIndex in controller
    // because the tabController resets its index to 0 after recreating.
    // tabController.animateTo(currentIndex);
    animateTo(currentIndex);
  }

  void goBack(DrawerTab currentTab) {
    if (currentTab.prevTab == null) {
      // tabController.animateTo(tabs.indexOf(boardListTab));
      animateTo(tabs.indexOf(boardListTab));
      return;
    }
    int prevTabId = tabs.indexOf(currentTab.prevTab!);
    if (prevTabId == -1) {
      if (_currentIndex > 0) {
        // tabController.animateTo(tabController.index - 1);
        animateTo(currentIndex - 1);
      }
    } else {
      // tabController.animateTo(prevTabId);
      animateTo(prevTabId);
    }
  }
}

abstract class TabEvent {}

class OpenCatalogEvent extends TabEvent {
  OpenCatalogEvent({required this.boardTag, required this.searchTag});
  final String boardTag;
  final String searchTag;
}

class TabUpdateEvent extends TabEvent {
  TabUpdateEvent();
}

abstract class TabState {}

class OpenCatalogState extends TabState {
  OpenCatalogState({required this.boardTag, required this.searchTag});
  final String boardTag;
  final String searchTag;
}

class TabInitialState extends TabState {}

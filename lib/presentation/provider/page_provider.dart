import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/domain/models/catalog.dart';
import 'package:treechan/domain/repositories/tracker_repository.dart';
import 'package:treechan/presentation/bloc/tracker_cubit.dart';
import 'package:treechan/presentation/screens/page_navigator.dart';
import 'package:treechan/presentation/widgets/board/popup_menu_board.dart';
import 'package:treechan/presentation/widgets/thread/popup_menu_thread.dart';
import 'package:treechan/presentation/widgets/tracker/popup_menu_tracker.dart';

import '../../domain/models/tab.dart';
import '../bloc/board_bloc.dart';
import '../bloc/board_list_bloc.dart' as board_list;
import '../bloc/branch_bloc.dart';
import '../bloc/thread_base.dart';
import '../screens/tracker_screen.dart';
import 'tab_manager.dart';

/// Manages everything related to tabs and pages.
class PageProvider with ChangeNotifier {
  PageProvider({required this.tabManager});

  final TabManager tabManager;

  void addTab(DrawerTab tab) => tabManager.addTab(tab);
  void removeTab(DrawerTab tab) => tabManager.removeTab(tab);
  void goBack() => tabManager.goBack();
  void setName(DrawerTab tab, String name) => tabManager.setName(tab, name);
  void openCatalog({required String boardTag, required String query}) =>
      tabManager.openCatalog(boardTag: boardTag, query: query);

  /// The stream is listened by new [BoardBloc] to check if you need to switch
  /// the board screen to a catalog mode.
  final StreamController<Catalog> catalog =
      StreamController<Catalog>.broadcast();
  Stream<Catalog> get catalogStream => catalog.stream;

  late final TrackerRepository trackerRepository =
      TrackerRepository(initTabManager: tabManager);

  late final List<Widget> pages = [
    const Placeholder(),
    const Placeholder(),
    BrowserScreen(provider: this),
  ];

  int currentPageIndex = 2;
  // int get currentPageIndex => _currentPageIndex;
  // Widget get currentPage => getCurrentPage();

  late TabController pageController;
  void init(PageNavigatorState gotState) {
    tabManager.init(gotState, _notifyListeners, this);
    pageController =
        TabController(length: pages.length, vsync: gotState, initialIndex: 2);
    _initTrackerCubit();
  }

  late final TrackerCubit trackerCubit;
  void _initTrackerCubit() {
    trackerCubit = TrackerCubit(trackerRepository: trackerRepository)
      ..loadTracker();
    pages[1] =
        BlocProvider.value(value: trackerCubit, child: const TrackerScreen());
  }

  void _notifyListeners() {
    notifyListeners();
  }

  void openSearch() {
    final currentBloc = tabManager.currentBloc;

    if (currentBloc is board_list.BoardListBloc) {
      currentBloc.add(board_list.SearchQueryChangedEvent(''));
    } else if (currentBloc is BoardBloc) {
      currentBloc.add(SearchQueryChangedEvent(''));
    } else {
      // search for thread and branch
    }
  }

  /// 0 - search, 1 - tracker, 2 - browser, 3 - refresh, 4 - actions
  void setCurrentPageIndex(int index, {BuildContext? context}) {
    /// When open search from [BrowserScreen]
    if (currentPageIndex == 2 && index == 0) {
      currentPageIndex = index;
      notifyListeners();
      openSearch();
      return;
    }

    /// When open search from [TrackerScreen]
    if (currentPageIndex == 1 && index == 0) {
      return;
    }

    /// When press refresh from [TrackerScreen]
    if (currentPageIndex == 1 && index == 3) {
      trackerCubit.refreshAll();
      return;
    }

    if (currentPageIndex == 1 && index == 4) {
      assert(context != null,
          'context is null, cannot open actions from tracker screen');
      showPopupMenuTracker(context!);
      return;
    }

    /// When press refresh or actions from [BrowserScreen]
    if (currentPageIndex == 2) {
      if (index == 3) {
        tabManager.refreshTab();
        return;
      } else if (index == 4) {
        assert(context != null, 'context is null');
        if (context == null) return;
        openActions(context);
        return;
      }
    }

    /// close search when leaving search page
    if (currentPageIndex == 0) {
      if (index == 0) return;
      final bloc = tabManager.currentBloc;
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

    currentPageIndex = index;
    pageController.animateTo(index);
    notifyListeners();
  }

  void openActions(BuildContext context) {
    final currentTab = tabManager.currentTab;
    final currentBloc = tabManager.currentBloc;
    if (currentTab is BoardTab) {
      openBoardActions(currentBloc as BoardBloc, context);
    } else if (currentTab is IdMixin) {
      openThreadActions(currentBloc as ThreadBase, context);
    }
  }

  void openBoardActions(BoardBloc bloc, BuildContext context) {
    showPopupMenuBoard(context, bloc, tabManager.currentTab as BoardTab);
  }

  void openThreadActions(ThreadBase bloc, BuildContext context) {
    showPopupMenuThread(context, bloc, this);
  }

  /// Adds thread or branch for tracking updates.
  void subscribe() async {
    final currentTab = tabManager.currentTab;
    final ThreadBase bloc = tabManager.currentBloc;
    if (currentTab is ThreadTab) {
      final tab = currentTab;
      await trackerRepository.addThreadByTab(
          tab: tab, posts: bloc.threadRepository.postsCount);
    } else if (currentTab is BranchTab) {
      final tab = currentTab;
      await trackerRepository.addBranchByTab(
          tab: tab,
          posts: (bloc as BranchBloc).branchRepository.postsCount,
          threadId: tab.id);
    }
    trackerCubit.loadTracker();
  }

  void unsubscribe() {
    final currentTab = tabManager.currentTab;
    if (currentTab is ThreadTab) {
      trackerRepository.removeThreadByTab(currentTab);
    } else if (currentTab is BranchTab) {
      trackerRepository.removeBranchByTab(currentTab);
    }
  }

  GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  void showSnackBar(String message) {
    messengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  void dispose() {
    catalog.close();
    super.dispose();
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:treechan/data/local/history_database.dart';
import 'package:treechan/data/thread/thread_loader.dart';
import 'package:treechan/di/injection.dart';
import 'package:treechan/domain/imageboards/imageboard_specific.dart';
import 'package:treechan/domain/models/repository_stream.dart';
import 'package:treechan/domain/repositories/manager/thread_repository_manager.dart';
import 'package:treechan/domain/repositories/repository.dart';
import 'package:treechan/domain/repositories/thread_repository.dart';
import 'package:treechan/domain/services/scroll_service.dart';
import 'package:treechan/presentation/bloc/board_list_bloc.dart';
import 'package:treechan/presentation/provider/bloc_handler.dart';
import 'package:treechan/presentation/provider/page_provider.dart';
import 'package:treechan/utils/constants/dev.dart';
import 'package:treechan/utils/custom_hidable_visibility.dart';

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

  /// Listened by bottom nav bar [Hidable] to control visibility of the bar
  /// during the tab scroll.
  ///
  /// Gets reassigned to the [currentBloc] scroll conttroller
  ScrollController tabScrollControllerReference = ScrollController();

  /// Attaches tab controller for [PageNavigator],
  /// initializes repository managers and listens to app background/foreground
  /// changes. Also listens to archive thread redirects.
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

    ThreadRepositoryManager().initMessenger(repositoryMessenger);
    BranchRepositoryManager().initMessenger(repositoryMessenger);
    repositoryMessenger.stream.listen((message) {
      if (message is RepositoryRedirectRequest) {
        _handleArchiveRedirect(
          repository: message.repository,
          baseUrl: message.baseUrl,
          path: message.redirectPath,
        );
      }
    });
  }

  bool isAppInForeground = true;
  StreamController<FGBGType> appLifeCycleStreamController =
      StreamController<FGBGType>.broadcast();

  final StreamController<RepositoryMessage> repositoryMessenger =
      StreamController<RepositoryMessage>.broadcast();

  BlocProvider<board_list.BoardListBloc> getBoardListScreen(BoardListTab tab) =>
      blocHandler.getBoardListScreen(tab);
  BlocProvider<BoardBloc> getBoardScreen(BoardTab tab) =>
      blocHandler.getBoardScreen(tab);
  BlocProvider<ThreadBloc> getThreadScreen(ThreadTab tab) =>
      blocHandler.getThreadScreen(tab);
  BlocProvider<BranchBloc> getBranchScreen(BranchTab tab) =>
      blocHandler.getBranchScreen(tab);

  double systemNavBarOpacity = 1;

  /// Animates to a tab with index specified.
  void animateTo(int index) {
    if (provider.currentPageIndex != 2) provider.setCurrentPageIndex(2);
    _currentTabIndex = index;
    tabController.animateTo(index);
    if (currentBloc is! BoardListBloc) {
      tabScrollControllerReference = currentBloc.scrollController;
      tabScrollControllerReference.addListener(() {
        systemNavBarOpacity = customHidableVisibility(
            tabScrollControllerReference.position, systemNavBarOpacity);
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            systemNavigationBarColor:
                Colors.black.withOpacity(systemNavBarOpacity.clamp(0.002, 1)),
          ),
        );
      });
    } else {
      tabScrollControllerReference = ScrollController();
    }
    notifyListeners();
  }

  /// Reassigns [tabController] with new tabs length.
  void _refreshController() {
    tabController = TabController(length: tabs.length, vsync: state);
  }

  ThreadTab? _findAlreadyOpenedArchiveThread(DrawerTab tab) {
    if (tab is! ThreadTab) return null;
    final possiblyOpenedTab = findTab(
        imageboard: archivesMap[tab.imageboard]!,
        tag: tab.tag,
        threadId: tab.id);
    if (possiblyOpenedTab.id != -1) return possiblyOpenedTab as ThreadTab;
    // if ((possiblyOpenedTab as ThreadTab).archiveDate != null) return true;
    return null;
  }

  /// Adds new tab or animates to it if already opened.
  void addTab(DrawerTab tab) async {
    ThreadTab? alreadyOpenedArchiveThread =
        _findAlreadyOpenedArchiveThread(tab);
    if (alreadyOpenedArchiveThread != null) {
      tab = alreadyOpenedArchiveThread;
    }
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

    // if (alreadyOpenedArchiveThread != null) {}
    animateTo(_tabs.keys.toList().indexOf(tab));
    getIt<IHistoryDatabase>().add(tab);
  }

  /// Closes tab and removes its repository if not tracked.
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
          ThreadRepositoryManager().remove(tab.imageboard, tab.tag, tab.id);
        }
      }
      if (tab is BranchTab) {
        BranchRepositoryManager().remove(tab.imageboard, tab.tag, tab.id);
      }
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

  /// Returns to a previous tab using [DrawerTab] prevTab property.
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

  /// Handles the case when user opens link leading to a board catalog.
  void openCatalog(
      {required Imageboard imageboard,
      required String boardTag,
      required String query}) {
    provider.catalog.add(Catalog(boardTag: boardTag, searchTag: query));
    final int index = _tabs.keys
        .toList()
        .indexWhere((tab) => tab is BoardTab && tab.tag == boardTag);
    if (index != -1) {
      animateTo(index);
    } else {
      addTab(BoardTab(
        imageboard: imageboard,
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
  IdMixin findTab(
      {required Imageboard imageboard,
      required String tag,
      int? threadId,
      int? branchId}) {
    assert(threadId != null || branchId != null,
        'you must specify threadId or branchId');
    if (threadId != null) {
      return _tabs.keys.firstWhere(
          (tab) => tab is ThreadTab && tab.tag == tag && tab.id == threadId,
          orElse: () => ThreadTab(
              imageboard: Imageboard.unknown,
              name: null,
              tag: 'error',
              prevTab: boardListTab,
              id: -1)) as IdMixin;
    } else {
      return _tabs.keys.firstWhere(
          (tab) => tab is BranchTab && tab.tag == tag && tab.id == branchId,
          orElse: () => BranchTab(
              imageboard: Imageboard.unknown,
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
      {required Imageboard imageboard,
      required String boardTag,
      required int threadId}) {
    final tab =
        findTab(imageboard: imageboard, tag: boardTag, threadId: threadId);
    if (tab.id == -1) {
      return null;
    }
    if (tab is ThreadTab) {
      return (tabs[tab] as ThreadBloc).scrollService;
    } else {
      throw Exception('tab is not ThreadTab');
    }
  }

  /// Changes tab to its archive version and calls its repository load method.
  void _handleArchiveRedirect({
    required Repository repository,
    required String baseUrl,
    required String path,
  }) {
    assert(repository is ThreadRepository, '''
Redirects from branches can not be handled because loading is handled by related
thread repository, so that is probably a mistake.''');
    final String url = baseUrl + path;
    final ThreadTab archiveTab =
        ImageboardSpecific.tryOpenUnknownTabFromLink(url, currentTab);

    final ThreadTab updatableTab = findTab(
        imageboard: repository.imageboard,
        tag: repository.boardTag,
        threadId: repository.id) as ThreadTab;

    final bloc = tabs[updatableTab];

    tabs.remove(updatableTab);

    updatableTab.imageboard = archiveTab.imageboard;
    updatableTab.archiveDate = archiveTab.archiveDate;

    (repository as ThreadRepository).threadLoader = getIt<IThreadRemoteLoader>(
        param1: archiveTab.imageboard, param2: debugThreadPath);
    repository.archiveDate = archiveTab.archiveDate;

    tabs[updatableTab] = bloc;

    bloc.add(LoadThreadEvent());
  }
}

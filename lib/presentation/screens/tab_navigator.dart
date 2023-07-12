import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../utils/constants/enums.dart';

import '../screens/thread_screen.dart';
import '../screens/board_screen.dart';
import 'board_list_screen.dart';

import '../widgets/drawer/drawer.dart';
import '../../domain/models/tab.dart';

import '../provider/tab_provider.dart';
import '../bloc/board_bloc.dart';
import '../bloc/board_list_bloc.dart';
import '../bloc/thread_bloc.dart';

import '../../domain/services/board_list_service.dart';
import '../../domain/services/thread_service.dart';
import '../../domain/services/board_service.dart';

/// Root widget of the app.
/// Controls tabs and creates a drawer with tabs.
class TabNavigator extends StatefulWidget {
  const TabNavigator({super.key});
  @override
  State<TabNavigator> createState() => TabNavigatorState();
}

class TabNavigatorState extends State<TabNavigator>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    final provider = context.read<TabProvider>();
    provider.initController(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.addTab(boardListTab);
      debugThread(provider);
    });
  }

  void debugThread(TabProvider provider) {
    if (kDebugMode && const String.fromEnvironment('thread') == 'true') {
      debugPrint('debugging thread');
      DrawerTab debugThreadTab = DrawerTab(
          type: TabTypes.thread,
          name: "debug",
          tag: "b",
          prevTab: boardListTab,
          id: 282647314);
      provider.addTab(debugThreadTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TabProvider>(context, listen: true);

    /// Overrides Android back button to go back to the previous tab.
    return WillPopScope(
      onWillPop: () async {
        int currentIndex = provider.currentIndex;
        if (currentIndex > 0) {
          provider.goBack();
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: ScaffoldMessenger(
        child: Scaffold(
          key: _scaffoldKey,
          body: Screen(provider: provider),
          drawer: AppDrawer(provider: provider, scaffoldKey: _scaffoldKey),
        ),
      ),
    );
  }
}

/// The widget showing current tab.
class Screen extends StatelessWidget {
  const Screen({
    super.key,
    required this.provider,
  });

  final TabProvider provider;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      physics: const NeverScrollableScrollPhysics(),
      controller: context.watch<TabProvider>().tabController,
      children: provider.tabs.map((tab) {
        switch (tab.type) {
          case TabTypes.boardList:
            return getBoardListScreen(tab);
          case TabTypes.board:
            return getBoardScreen(tab);
          case TabTypes.thread:
            return getThreadScreen(tab);
        }
      }).toList(),
    );
  }

  BlocProvider<BoardListBloc> getBoardListScreen(DrawerTab tab) {
    return BlocProvider(
      key: ValueKey(tab),
      create: (context) => BoardListBloc(boardListService: BoardListService())
        ..add(LoadBoardListEvent()),
      child: const BoardListScreen(title: "Доски"),
    );
  }

  BlocProvider<BoardBloc> getBoardScreen(DrawerTab tab) {
    return BlocProvider(
      key: ValueKey(tab),
      create: tab.isCatalog == null
          ? (context) => BoardBloc(
              tabProvider: context.read<TabProvider>(),
              boardService: BoardService(boardTag: tab.tag))
            ..add(LoadBoardEvent())
          : (context) => BoardBloc(
              tabProvider: context.read<TabProvider>(),
              boardService: BoardService(boardTag: tab.tag))
            ..add(ChangeViewBoardEvent(null, searchTag: tab.searchTag)),
      child: BoardScreen(
        currentTab: tab,
      ),
    );
  }

  BlocProvider<ThreadBloc> getThreadScreen(DrawerTab tab) {
    return BlocProvider(
      key: ValueKey(tab),
      create: (blocContext) => ThreadBloc(
        threadService: ThreadService(boardTag: tab.tag, threadId: tab.id!),
      )..add(LoadThreadEvent()),
      child: ThreadScreen(
        currentTab: tab,
        prevTab: tab.prevTab ?? boardListTab,
      ),
    );
  }
}

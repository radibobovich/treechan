import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:treechan/screens/thread_screen.dart';
import 'package:treechan/services/board_service.dart';
import '../widgets/search_bar_widget.dart';
import '../models/bloc/board_bloc.dart';
import '../models/bloc/board_list_bloc.dart';
import '../models/bloc/thread_bloc.dart';
import '../services/board_list_service.dart';
import '../services/thread_service.dart';
import '../screens/board_screen.dart';
import 'board_list_screen.dart';

enum TabTypes { boardList, board, thread }

class DrawerTab {
  TabTypes type;
  int? id;
  String? name;
  String tag;
  DrawerTab? prevTab;
  DrawerTab(
      {required this.type,
      this.id,
      required this.tag,
      this.name,
      this.prevTab});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DrawerTab &&
        type == other.type &&
        id == other.id &&
        tag == other.tag;
  }

  @override
  int get hashCode =>
      type.hashCode ^ id.hashCode ^ name.hashCode ^ tag.hashCode;
}

/// An initial tab for the drawer. Referenced in goBack of boards.
DrawerTab boardListTab =
    DrawerTab(type: TabTypes.boardList, name: "Доски", tag: "boards");

class TabNavigator extends StatefulWidget {
  const TabNavigator({super.key});
  @override
  State<TabNavigator> createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? tabController;
  final List<DrawerTab> tabs = List.empty(growable: true);
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabs.length, vsync: this);
    addTab(boardListTab);
    if (const String.fromEnvironment('thread') == 'true') {
      debugPrint('debugging thread');
      DrawerTab debugThreadTab = DrawerTab(
          type: TabTypes.thread,
          name: "debug",
          tag: "b",
          prevTab: boardListTab,
          id: 282647314);
      addTab(debugThreadTab);
    }
  }

  @override
  void dispose() {
    tabController!.dispose();
    super.dispose();
  }

  /// Adds new tab to the drawer and opens it.
  void addTab(DrawerTab tab) {
    if (!tabs.contains(tab)) {
      setState(() {
        tabs.add(tab);
        tabController = TabController(length: tabs.length, vsync: this);
      });
    }
    tabController!.animateTo(tabs.indexOf(tab));
  }

  void setName(DrawerTab tab, String name) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        tab.name = name;
      });
    });
  }

  /// Closes tab and removes it from the drawer.
  void removeTab(DrawerTab tab) {
    setState(() {
      tabs.remove(tab);
    });
    tabController = TabController(length: tabs.length, vsync: this);
  }

  /// Goes back to the previous tab when user presses back button.
  void goBack(DrawerTab currentTab) {
    if (currentTab.prevTab == null) return;
    int prevTabId = tabs.indexOf(currentTab.prevTab!);
    if (prevTabId == -1) {
      if (tabController!.index > 0) {
        tabController!.animateTo(tabController!.index - 1);
      }
    } else {
      tabController!.animateTo(prevTabId);
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Overrides Android back button to go back to the previous tab.
    return WillPopScope(
      onWillPop: () async {
        int currentIndex = tabController!.index;
        if (currentIndex > 0) {
          goBack(tabs[currentIndex]);
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: ScaffoldMessenger(
        child: Scaffold(
          key: _scaffoldKey,
          body: Builder(builder: (sontext) {
            return TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: tabController,
              children: tabs.map((tab) {
                switch (tab.type) {
                  case TabTypes.boardList:
                    return BlocProvider(
                      create: (context) =>
                          BoardListBloc(boardListService: BoardListService())
                            ..add(LoadBoardListEvent()),
                      child: BoardListScreen(
                          key: ValueKey(tab),
                          title: "Доски",
                          onOpen: (DrawerTab newTab) {
                            addTab(newTab);
                          },
                          onGoBack: (DrawerTab currentTab) =>
                              goBack(currentTab)),
                    );
                  case TabTypes.board:
                    return BlocProvider(
                      create: (context) => BoardBloc(
                          boardService: BoardService(
                              boardTag: tab.tag, sortType: SortBy.page))
                        ..add(LoadBoardEvent()),
                      child: BoardScreen(
                          key: ValueKey(tab),
                          currentTab: tab,
                          onOpen: (DrawerTab newTab) => addTab(newTab),
                          onGoBack: (DrawerTab currentTab) =>
                              goBack(currentTab),
                          onSetName: (String name) {
                            setName(tab, name);
                          }),
                    );
                  case TabTypes.thread:
                    return BlocProvider(
                      create: (blocContext) => ThreadBloc(
                        threadService:
                            ThreadService(boardTag: tab.tag, threadId: tab.id!),
                      )..add(LoadThreadEvent()),
                      child: ThreadScreen(
                          key: ValueKey(tab),
                          currentTab: tab,
                          prevTab: tab.prevTab!,
                          onOpen: (DrawerTab newTab) => addTab(newTab),
                          onGoBack: (DrawerTab currentTab) =>
                              goBack(currentTab),
                          onSetName: (String name) {
                            setName(tab, name);
                          }),
                    );
                }
              }).toList(),
            );
          }),
          drawer: Drawer(
            child: Column(
              children: [
                SearchBar(
                  onOpen: (DrawerTab newTab) => addTab(newTab),
                  onCloseDrawer: () => _scaffoldKey.currentState!.closeDrawer(),
                ),
                const Divider(
                  thickness: 1,
                ),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView.builder(
                      itemCount: tabs.length,
                      itemBuilder: (bcontext, index) {
                        DrawerTab item = tabs[index];
                        return ListTile(
                          selected: tabController!.index == index,
                          textColor:
                              Theme.of(context).textTheme.titleMedium!.color,
                          selectedColor: Theme.of(context).secondaryHeaderColor,
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  (item.type == TabTypes.board
                                          ? "/${item.tag}/ - "
                                          : "") +
                                      (item.name ??
                                          (item.type == TabTypes.board
                                              ? "Доска"
                                              : "Тред")),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              item.type != TabTypes.boardList
                                  ? IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        int currentPosition =
                                            tabController!.index;

                                        if (tabs.indexOf(item) <=
                                            currentPosition) {
                                          removeTab(item);
                                          tabController!
                                              .animateTo(currentPosition - 1);
                                        } else {
                                          removeTab(item);
                                          tabController!
                                              .animateTo(currentPosition);
                                        }
                                      },
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .color,
                                    )
                                  : const SizedBox.shrink()
                            ],
                          ),
                          onTap: () {
                            tabController!.animateTo(index);
                            _scaffoldKey.currentState!.closeDrawer();
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

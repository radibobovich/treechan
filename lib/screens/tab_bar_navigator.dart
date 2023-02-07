import 'package:flutter/material.dart';
import 'package:treechan/screens/thread_screen.dart';
import 'board_screen.dart';
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

DrawerTab boardListTab =
    DrawerTab(type: TabTypes.boardList, name: "Доски", tag: "boards");

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});
  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? _tabController;
  final List<DrawerTab> _tabs = List.empty(growable: true);
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _addItem(boardListTab);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  int? findBoardItem(String tag) {
    for (int i = 0; i < _tabs.length; i++) {
      if (_tabs[i].type == TabTypes.board && _tabs[i].tag == tag) {
        return i;
      }
    }
    return null;
  }

  void _addItem(DrawerTab tab) {
    if (!_tabs.contains(tab)) {
      setState(() {
        // if (prevItem != null) {
        //   // add new item after prevItem which triggered its opening
        //   _items.insert(_items.indexOf(prevItem) + 1, item);
        // } else if (item.type == ItemTypes.thread) {
        //   // add new item after the board from which it was opened
        //   int? relatedBoardItemId = findBoardItem(item.tag);
        //   // relatedBoardItemId is null when there is no related board in the list
        //   if (relatedBoardItemId != null &&
        //       relatedBoardItemId < _items.length - 1) {
        //     _items.insert(relatedBoardItemId + 1, item);
        //   } else {
        //     _items.add(item);
        //   }
        // } else if (item.type == ItemTypes.board && _items.length > 1) {
        //   _items.insert(1, item);
        // } else {
        //   _items.add(item);
        // }
        _tabs.add(tab);

        _tabController = TabController(length: _tabs.length, vsync: this);
      });
    }
    _tabController!.animateTo(_tabs.indexOf(tab));
  }

  void _removeItem(DrawerTab tab) {
    setState(() {
      _tabs.remove(tab);
    });
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  void _goBack(DrawerTab currentTab) {
    if (currentTab.prevTab == null) return;
    int prevTabId = _tabs.indexOf(currentTab.prevTab!);
    if (prevTabId == -1) {
      if (_tabController!.index > 0) {
        _tabController!.animateTo(_tabController!.index - 1);
      }
    } else {
      _tabController!.animateTo(prevTabId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        int currentIndex = _tabController!.index;
        if (currentIndex > 0) {
          _goBack(_tabs[currentIndex]);
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: Builder(builder: (sontext) {
          return TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: _tabs.map((tab) {
              switch (tab.type) {
                case TabTypes.boardList:
                  return BoardListScreen(
                      key: ValueKey(tab),
                      title: "Доски",
                      onOpen: (DrawerTab newTab) {
                        _addItem(newTab);
                      },
                      onGoBack: (DrawerTab currentTab) => _goBack(currentTab));
                case TabTypes.board:
                  return BoardScreen(
                      key: ValueKey(tab),
                      boardName: tab.name!,
                      boardTag: tab.tag,
                      onOpen: (DrawerTab newTab) => _addItem(newTab),
                      onGoBack: (DrawerTab currentTab) => _goBack(currentTab));
                case TabTypes.thread:
                  return ThreadScreen(
                      key: ValueKey(tab),
                      threadId: tab.id!,
                      tag: tab.tag,
                      prevTab: tab.prevTab!,
                      onOpen: (DrawerTab newTab) => _addItem(newTab),
                      onGoBack: (DrawerTab currentTab) => _goBack(currentTab));
              }
            }).toList(),
          );
        }),
        drawer: Drawer(
          child: ListView.builder(
            itemCount: _tabs.length,
            itemBuilder: (bcontext, index) {
              DrawerTab item = _tabs[index];
              return ListTile(
                selected: _tabController!.index == index,
                textColor: Theme.of(context).textTheme.titleMedium!.color,
                selectedColor: Theme.of(context).secondaryHeaderColor,
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        (item.type == TabTypes.board
                                ? "/${item.tag}/ - "
                                : "") +
                            (item.name ?? "Тред"),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    item.type != TabTypes.boardList
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              int currentPosition = _tabController!.index;

                              if (_tabs.indexOf(item) <= currentPosition) {
                                _removeItem(item);
                                _tabController!.animateTo(currentPosition - 1);
                              } else {
                                _removeItem(item);
                                _tabController!.animateTo(currentPosition);
                              }
                            },
                            color:
                                Theme.of(context).textTheme.titleMedium!.color,
                          )
                        : const SizedBox.shrink()
                  ],
                ),
                onTap: () {
                  _tabController!.animateTo(index);
                  _scaffoldKey.currentState!.closeDrawer();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

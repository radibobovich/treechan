import 'package:flutter/material.dart';
import 'package:treechan/models/board_json.dart';
import 'package:treechan/screens/thread_screen.dart';
import 'board_screen.dart';
import 'board_list_screen.dart';

//final List<GlobalKey> runningTabs = List.empty(growable: true);
// TODO: add a way to close tabs: bool get wantKeepAlive => runningTabs.where...
enum ItemTypes { boardList, board, thread }

class Item {
  ItemTypes type;
  int? id;
  String? name;
  String tag;

  Item({required this.type, this.id, required this.tag, this.name});
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});
  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? _tabController;
  final List<Item> _items = List.empty(growable: true);
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _items.length, vsync: this);
    _addItem(Item(type: ItemTypes.boardList, name: "Доски", tag: "boards"));
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  bool compareItems(Item item1, Item item2) {
    if (item1.type == item2.type &&
        item1.id == item2.id &&
        item1.tag == item2.tag) {
      return true;
    } else {
      return false;
    }
  }

  int? findBoardItem(String tag) {
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].type == ItemTypes.board && _items[i].tag == tag) {
        return i;
      }
    }
    return null;
  }

  void _addItem(Item item, {Item? prevItem}) {
    if (_items.where((element) => compareItems(element, item)).isEmpty) {
      setState(() {
        if (prevItem != null) {
          // add new item after prevItem which triggered its opening
          _items.insert(
              _items.indexWhere((element) => compareItems(element, prevItem)) +
                  1,
              item);
        } else if (item.type == ItemTypes.thread) {
          // add new item after the board from which it was opened
          int? relatedBoardItemId = findBoardItem(item.tag);
          // relatedBoardItemId is null when there is no related board in the list
          if (relatedBoardItemId != null &&
              relatedBoardItemId < _items.length - 1) {
            _items.insert(relatedBoardItemId + 1, item);
          } else {
            _items.add(item);
          }
        } else if (item.type == ItemTypes.board && _items.length > 1) {
          _items.insert(1, item);
        } else {
          // TODO: remove because potentially never used
          _items.add(item);
        }

        //_items.add(item);
        _tabController = TabController(length: _items.length, vsync: this);
      });
    }
    _tabController!
        .animateTo(_items.indexWhere((element) => compareItems(element, item)));
    //_scaffoldKey.currentState!.closeEndDrawer();
  }

  void _setSubject(Item item) async {
    // using addPostFrameCallback to avoid "setState() or markNeedsBuild() called during build" error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _items[_items.indexWhere((element) => compareItems(element, item))]
            .name = item.name;
      });
    });
  }

  void _removeItem(Item item) {
    setState(() {
      _items.remove(item);
    });
    // TODO: kill State when removing item
    _tabController = TabController(length: _items.length, vsync: this);
  }

  void _goBack() {
    if (_tabController!.index > 0) {
      _tabController!.animateTo(_tabController!.index - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        int currentIndex = _tabController!.index;
        if (currentIndex > 0) {
          _tabController!.animateTo(currentIndex - 1);
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
            children: _items.map((item) {
              switch (item.type) {
                case ItemTypes.boardList:
                  return BoardListScreen(
                      key: ValueKey(item),
                      title: "Доски",
                      onOpen: (Item item) {
                        _addItem(item);
                        //_scaffoldKey.currentState!.closeDrawer();
                      },
                      onGoBack: () => _goBack());
                case ItemTypes.board:
                  return BoardScreen(
                      boardName: item.name!,
                      boardTag: item.tag,
                      onOpen: (Item item) => _addItem(item),
                      onGoBack: () => _goBack());
                case ItemTypes.thread:
                  return ThreadScreen(
                      threadId: item.id!,
                      tag: item.tag,
                      onOpen: (Item item, {Item? prevItem}) => _addItem(item),
                      onGoBack: () => _goBack(),
                      onSetSubject: (Item item) => _setSubject(item));
              }
            }).toList(),
          );
        }),
        // How to prevent drawer width overflow?
        drawer: Drawer(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (bcontext, index) {
              Item item = _items[index];
              return ListTile(
                selected: _tabController!.index == index,
                textColor: Theme.of(context).textTheme.titleMedium!.color,
                selectedColor: Theme.of(context).secondaryHeaderColor,
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        (item.type == ItemTypes.board
                                ? "/${item.tag}/ - "
                                : "") +
                            (item.name ?? "Тред"),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    //const Spacer(),
                    item.type != ItemTypes.boardList
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _removeItem(item);
                              _scaffoldKey.currentState!.closeDrawer();
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

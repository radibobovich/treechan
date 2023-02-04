import 'package:flutter/material.dart';
import 'package:treechan/models/board_json.dart';
import 'package:treechan/screens/thread_screen.dart';
import 'board_screen.dart';
import 'board_list_screen.dart';

enum ItemTypes { boardList, board, thread }

class Item {
  ItemTypes type;
  int? id;
  String name;
  String tag;

  Item({required this.type, this.id, required this.tag, required this.name});
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});
  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator>
    with TickerProviderStateMixin {
  TabController? _tabController;
  List<Item> _items = [];
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

  void _addItem(Item thread) {
    setState(() {
      _items.add(thread);
      _tabController = TabController(length: _items.length, vsync: this);
      _tabController!.animateTo(_items.length - 1);
    });
  }

  void _removeItem(Item thread) {
    setState(() {
      _items.remove(thread);
    });
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
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: _items.map((item) {
            switch (item.type) {
              case ItemTypes.boardList:
                return BoardListScreen(
                    title: "Доски",
                    onOpen: (Item item) => _addItem(item),
                    onGoBack: () => _goBack());
              case ItemTypes.board:
                return BoardScreen(
                    boardName: item.name,
                    boardTag: item.tag,
                    onOpen: (Item item) => _addItem(item),
                    onGoBack: () => _goBack());
              case ItemTypes.thread:
                return ThreadScreen(
                    threadId: item.id!,
                    tag: item.tag,
                    onGoBack: () => _goBack());
            }
          }).toList(),
        ),
        drawer: Drawer(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_items[index].name),
                onTap: () {
                  //_tabController!.animateTo(_items.indexOf(_items[index]));
                  _tabController!.animateTo(index);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

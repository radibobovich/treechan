// import 'package:flutter/material.dart';
// import 'package:treechan/models/board_json.dart';
// import 'package:treechan/screens/thread_screen.dart';
// import 'board_screen.dart';
// import 'board_list_screen.dart';

// enum ItemTypes { boardList, board, thread }

// class Item {
//   ItemTypes type;
//   int? id;
//   String name;
//   String tag;

//   Item({required this.type, this.id, required this.tag, required this.name});
// }

// class AppNavigator extends StatefulWidget {
//   const AppNavigator({super.key});
//   @override
//   State<AppNavigator> createState() => AppNavigatorState();
// }

// class AppNavigatorState extends State<AppNavigator>
//     with TickerProviderStateMixin {
//   List<Item> _items = [];
//   @override
//   void initState() {
//     super.initState();
//     //_addItem(Item(type: ItemTypes.boardList, name: "Доски", tag: "boards"));
//   }

//   void _addItem(Item item) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       setState(() {
//         _items.add(item);
//       });
//     });
//   }

//   void _removeItem(Item item) {
//     setState(() {
//       _items.remove(item);
//     });
//   }

//   void openPage(Item item) {
//     _navigatorKey.currentState?.pushNamed("", arguments: item);
//   }

//   void _goBack() {}

//   //final Map<String, Widget> routes = {};
//   //final Map<String, Widget> pages = {};
//   //final Map<Item, Key> pages = {};

//   final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
//   final PageStorageBucket bucket = PageStorageBucket();
//   //final Map<Item, Widget> pages = {};
//   final Map<Item, Widget> pages = {};
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         key: _scaffoldKey,
//         body: Navigator(
//             key: _navigatorKey,
//             onGenerateRoute: (settings) {
//               Item item = (settings.arguments ??
//                       Item(type: ItemTypes.boardList, tag: "", name: "Доски"))
//                   as Item;

//               //Widget? page = pages[item];
//               Widget? page = PageStorage.of(context)
//                   .readState(context, identifier: ValueKey(item));
//               // if page with that key not exist yet, then create it
//               if (page == null) {
//                 if (item.type == ItemTypes.boardList) {
//                   page = BoardListScreen(
//                       key: ValueKey(item.hashCode +
//                           DateTime.now().millisecondsSinceEpoch),
//                       title: "Доски",
//                       onOpen: (Item item) {
//                         _addItem(item);
//                         _scaffoldKey.currentState!.openEndDrawer();
//                         openPage(item);
//                       },
//                       onGoBack: () => _goBack());
//                   //pages[item] = page;
//                 } else if (item.type == ItemTypes.thread) {
//                   page = ThreadScreen(
//                       threadId: item.id!,
//                       tag: item.tag,
//                       onGoBack: () => _goBack());
//                   //pages[item] = page;
//                 } else if (item.type == ItemTypes.board) {
//                   page = BoardScreen(
//                       boardName: item.name,
//                       boardTag: item.tag,
//                       onOpen: (Item item) {
//                         _addItem(item);
//                         //_scaffoldKey.currentState!.openEndDrawer();
//                         openPage(item);
//                       },
//                       onGoBack: () => _goBack());
//                   //pages[item] = page;
//                 }
//                 _addItem(item);
//                 PageStorage.of(context)
//                     .writeState(context, page, identifier: ValueKey(item));
//               }

//               _scaffoldKey.currentState!.openEndDrawer();

//               return MaterialPageRoute(builder: (_) {
//                 //return pages[item]!;
//                 return page!;
//                 //return pages[item]!;
//               });
//             }),
//         drawer: Drawer(
//             child: ListView.builder(
//           itemCount: _items.length,
//           itemBuilder: (context, index) {
//             Item item = _items[index];
//             return ListTile(
//                 title: Text(item.name), onTap: () => openPage(item));
//           },
//         )));
//   }
// }

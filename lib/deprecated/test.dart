import 'package:flutter/material.dart';

class TestList extends StatefulWidget {
  const TestList({super.key});

  @override
  State<TestList> createState() => _TestListState();
}

class _TestListState extends State<TestList> {
  List<int> list = List.generate(100, (index) => index);
  List<GlobalKey> keyList = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test List"),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  list.add(125);
                });
              },
              // Scrollable.ensureVisible(
              //     keyList[72].currentContext!,
              //     duration: const Duration(milliseconds: 200),
              //     curve: Curves.easeOut),
              icon: const Icon(Icons.search))
        ],
      ),
      body: StatefulBuilder(
        builder: (context, setState) {
          return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                GlobalKey itemKey = GlobalKey();
                if (!keyList.contains(itemKey)) {
                  keyList.add(itemKey);
                }
                return ListTile(
                  key: itemKey,
                  title: Text(list[index].toString() + itemKey.toString()),
                );
              });
        },
      ),
    );
  }
}

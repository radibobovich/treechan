import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/history_database.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.onOpen});

  final Function onOpen;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  get wantKeepAlive => true;

  late Future<List<DrawerTabHistory>> history;
  List<DrawerTabHistory> selected = [];
  final formatter = DateFormat('HH:mm dd.MM.yy ');
  @override
  void initState() {
    super.initState();
    history = HistoryDatabase().getHistory();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: selected.isEmpty
            ? const Text('История')
            : Text('Выбрано: ${selected.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              if (selected.isNotEmpty) {
                await HistoryDatabase().removeMultiple(selected);
                setState(() {
                  selected = [];
                  history = HistoryDatabase().getHistory();
                });
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<DrawerTabHistory>>(
        future: history,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final DrawerTabHistory item = snapshot.data![index];
                return ListTile(
                  title: Text(item.name!,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text("/${item.tag}/${item.id}"),
                  trailing: Text(formatter.format(item.timestamp)),
                  leading: isSelected(item) ? const Icon(Icons.check) : null,
                  selected: isSelected(item),
                  onTap: selected.isEmpty
                      ? () {
                          Navigator.pop(context);
                          widget.onOpen(item.toDrawerTab());
                        }
                      : () => onItemSelect(item),
                  onLongPress: () => onItemSelect(item),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void onItemSelect(DrawerTabHistory item) {
    setState(() {
      if (selected.contains(item)) {
        selected.remove(item);
      } else {
        selected.add(item);
      }
    });
  }

  bool isSelected(DrawerTabHistory item) {
    return selected.contains(item);
  }
}

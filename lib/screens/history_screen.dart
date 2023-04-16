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

  late Future<List<HistoryTab>> history;
  List<HistoryTab> items = [];
  List<HistoryTab> selected = [];
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
        leading: selected.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.select_all),
                onPressed: () {
                  setState(() {
                    if (selected.length == items.length) {
                      selected = [];
                    } else {
                      selected = [];
                      selected.addAll(items);
                    }
                  });
                },
              )
            : null,
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
              } else if (items.isNotEmpty) {
                showHistoryClearDialog(context);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<HistoryTab>>(
        future: history,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final HistoryTab item = items[index];
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

  Future<dynamic> showHistoryClearDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Очистить историю?'),
              actions: [
                TextButton(
                    onPressed: () async {
                      await HistoryDatabase().clear();
                      setState(() {
                        history = HistoryDatabase().getHistory();
                      });
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    child: const Text('Очистить')),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена')),
              ],
            ));
  }

  void onItemSelect(HistoryTab item) {
    setState(() {
      if (selected.contains(item)) {
        selected.remove(item);
      } else {
        selected.add(item);
      }
    });
  }

  bool isSelected(HistoryTab item) {
    return selected.contains(item);
  }
}

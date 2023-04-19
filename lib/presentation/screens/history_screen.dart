import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/history_bloc.dart';
import '../../domain/models/tab.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.onOpen});

  final Function onOpen;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        return Scaffold(
          appBar: const PreferredSize(
              preferredSize: Size.fromHeight(56), child: HistoryAppBar()),
          body: HistoryListView(onOpen: onOpen),
        );
      },
    );
  }
}

class HistoryAppBar extends StatelessWidget {
  const HistoryAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state is HistoryLoadedState) {
          return AppBar(
            title: const Text("История"),
            actions: [
              IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    BlocProvider.of<HistoryBloc>(context)
                        .add(SearchQueryChangedEvent(""));
                  }),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showHistoryClearDialog(
                      context: context, clearHistory: state.clearHistory);
                },
              )
            ],
          );
        } else if (state is HistorySelectedState) {
          return AppBar(
            title: Text("Выбрано: ${state.selected.length}"),
            actions: [
              IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    BlocProvider.of<HistoryBloc>(context)
                        .add(SearchQueryChangedEvent(""));
                  }),
              IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    BlocProvider.of<HistoryBloc>(context)
                        .add(RemoveSelectedEvent());
                  })
            ],
          );
        } else if (state is HistorySearchState) {
          return AppBar(
            title: const SearchField(),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  BlocProvider.of<HistoryBloc>(context).add(LoadHistoryEvent());
                }),
          );
        } else if (state is HistorySearchSelectedState) {
          return AppBar(
              title: const SearchField(),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  BlocProvider.of<HistoryBloc>(context).add(LoadHistoryEvent());
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // state.removeSelected();
                    BlocProvider.of<HistoryBloc>(context)
                        .add(RemoveSelectedEvent());
                  },
                )
              ]);
        } else {
          return AppBar(title: const Text("История"));
        }
      },
    );
  }

  showHistoryClearDialog({
    required BuildContext context,
    required Function clearHistory,
  }) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Очистить историю?'),
              actions: [
                TextButton(
                    onPressed: () {
                      BlocProvider.of<HistoryBloc>(context)
                          .add(RemoveSelectedEvent(removeAll: true));
                      clearHistory();
                      Navigator.pop(context);
                    },
                    child: const Text('Очистить')),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена')),
              ],
            ));
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: true,
      decoration: const InputDecoration(hintText: 'Поиск'),
      onChanged: (query) {
        BlocProvider.of<HistoryBloc>(context)
            .add(SearchQueryChangedEvent(query));
      },
    );
  }
}

class HistoryListView extends StatefulWidget {
  const HistoryListView({super.key, required this.onOpen});

  final Function onOpen;

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  final formatter = DateFormat('HH:mm dd.MM.yy ');
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state is HistoryLoadedState) {
          return ListView.builder(
            itemCount: state.history.length,
            itemBuilder: (context, index) {
              final HistoryTab item = state.history[index];
              return ListTileIdle(
                  item: item, formatter: formatter, onOpen: widget.onOpen);
            },
          );
        } else if (state is HistorySelectedState) {
          return ListView.builder(
            itemCount: state.history.length,
            itemBuilder: (context, index) {
              final HistoryTab item = state.history[index];
              return ListTileSelectable(
                item: item,
                formatter: formatter,
              );
            },
          );
        } else if (state is HistorySearchState) {
          return ListView.builder(
              itemCount: state.searchResult.length,
              itemBuilder: (context, index) {
                final HistoryTab item = state.searchResult[index];
                return ListTileIdle(
                    item: item, formatter: formatter, onOpen: widget.onOpen);
              });
        } else if (state is HistorySearchSelectedState) {
          return ListView.builder(
            itemCount: state.searchResult.length,
            itemBuilder: (context, index) {
              final HistoryTab item = state.searchResult[index];
              return ListTileSelectable(
                item: item,
                formatter: formatter,
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

// Used in normal and search mode.
class ListTileIdle extends StatelessWidget {
  const ListTileIdle({
    super.key,
    required this.item,
    required this.formatter,
    required this.onOpen,
  });

  final HistoryTab item;
  final DateFormat formatter;
  final Function onOpen;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.name!, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text("/${item.tag}/${item.id}"),
      trailing: Text(formatter.format(item.timestamp)),
      onTap: () {
        Navigator.pop(context);
        onOpen(item);
      },
      onLongPress: () {
        BlocProvider.of<HistoryBloc>(context).add(SelectionChangedEvent(item));
      },
    );
  }
}

// Used in selec and search select mode.
class ListTileSelectable extends StatelessWidget {
  const ListTileSelectable({
    super.key,
    required this.item,
    required this.formatter,
  });

  final HistoryTab item;
  final DateFormat formatter;

  @override
  Widget build(BuildContext context) {
    bool isSelected =
        BlocProvider.of<HistoryBloc>(context).selected.contains(item);
    return ListTile(
        title: Text(item.name!, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text("/${item.tag}/${item.id}"),
        leading: isSelected ? const Icon(Icons.check) : null,
        trailing: Text(formatter.format(item.timestamp)),
        selected: isSelected,
        onTap: () {
          BlocProvider.of<HistoryBloc>(context)
              .add(SelectionChangedEvent(item));
        });
  }
}

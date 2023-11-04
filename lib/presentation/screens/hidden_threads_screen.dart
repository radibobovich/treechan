import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:treechan/data/local/hidden_threads_database.dart';
import 'package:treechan/domain/models/tab.dart';

class HiddenThreadsScreen extends StatefulWidget {
  final String? tag;
  final BoardTab currentTab;
  final Function onOpen;
  const HiddenThreadsScreen({
    super.key,
    this.tag,
    required this.currentTab,
    required this.onOpen,
  });

  @override
  State<HiddenThreadsScreen> createState() => _HiddenThreadsScreenState();
}

class _HiddenThreadsScreenState extends State<HiddenThreadsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Скрытые треды - /${widget.tag ?? widget.currentTab.tag}/'),
        actions: [
          IconButton(
              onPressed: () {
                HiddenThreadsDatabase()
                    .removeBoardTable(widget.tag ?? widget.currentTab.tag);
                setState(() {});
              },
              icon: const Icon(Icons.delete))
        ],
      ),
      body: FutureBuilder<List<HiddenThread>>(
        future: HiddenThreadsDatabase()
            .getHiddenThreads(widget.tag ?? widget.currentTab.tag),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final HiddenThread thread = snapshot.data![index];
                return Dismissible(
                    key: ValueKey(thread),
                    onDismissed: (direction) {
                      HiddenThreadsDatabase().removeThread(
                          widget.tag ?? widget.currentTab.tag, thread.id);
                    },
                    child: ThreadTile(
                      thread: thread,
                      tag: widget.tag ?? widget.currentTab.tag,
                      currentTab: widget.currentTab,
                      onOpen: widget.onOpen,
                    ));
              },
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class ThreadTile extends StatelessWidget {
  const ThreadTile({
    super.key,
    required this.thread,
    required this.tag,
    required this.currentTab,
    required this.onOpen,
  });

  final HiddenThread thread;
  final String tag;
  final BoardTab currentTab;
  final Function onOpen;
  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(
          thread.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(thread.id.toString()),
        trailing: Text(DateFormat('HH:mm dd.MM.yy ')
            .format(DateTime.fromMillisecondsSinceEpoch(thread.timestamp))),
        onTap: () {
          Navigator.pop(context);
          onOpen(ThreadTab(
              imageboard: currentTab.imageboard,
              tag: tag,
              prevTab: currentTab,
              id: thread.id,
              name: null));
        });
  }
}

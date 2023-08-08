import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:treechan/domain/models/tab.dart';

import '../../data/hidden_threads_database.dart';

class HiddenThreadsScreen extends StatelessWidget {
  final String tag;
  final BoardTab currentTab;
  final Function onOpen;
  const HiddenThreadsScreen({
    super.key,
    required this.tag,
    required this.currentTab,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Скрытые треды - /$tag/'),
        actions: [
          IconButton(
              onPressed: () {
                HiddenThreadsDatabase().removeBoardTable(tag);
              },
              icon: const Icon(Icons.delete))
        ],
      ),
      body: FutureBuilder<List<HiddenThread>>(
        future: HiddenThreadsDatabase().getHiddenThreads(tag),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final HiddenThread thread = snapshot.data![index];
                return Dismissible(
                    key: ValueKey(thread),
                    onDismissed: (direction) {
                      HiddenThreadsDatabase().removeThread(tag, thread.id);
                    },
                    child: ThreadTile(
                      thread: thread,
                      tag: tag,
                      currentTab: currentTab,
                      onOpen: onOpen,
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
            tag: tag,
            prevTab: currentTab,
            id: thread.id,
          ));
        });
  }
}
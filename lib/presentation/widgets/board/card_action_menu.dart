import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/domain/models/tab.dart';
import 'package:treechan/presentation/widgets/board/thread_card.dart';

class CardActionMenu extends StatelessWidget {
  final BoardTab currentTab;
  final Thread thread;
  const CardActionMenu(
      {super.key, required this.currentTab, required this.thread});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final prefs = snapshot.data!;
          return SizedBox(
            width: double.minPositive,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                prefs.getBool('classicThreadView') ?? false == true
                    ? ListTile(
                        title: const Text('Открыть в виде дерева'),
                        visualDensity: const VisualDensity(vertical: -3),
                        onTap: () {
                          openThread(context, thread, currentTab, false);
                          Navigator.pop(context);
                        },
                      )
                    : ListTile(
                        title: const Text('Открыть в классическом виде'),
                        visualDensity: const VisualDensity(vertical: -3),
                        onTap: () {
                          openThread(context, thread, currentTab, true);
                          Navigator.pop(context);
                        },
                      )
              ],
            ),
          );
        });
  }
}

Future<dynamic> showCardActionMenu(
    BuildContext context, BoardTab currentTab, Thread thread) {
  return showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
          contentPadding: const EdgeInsets.all(10),
          content: CardActionMenu(currentTab: currentTab, thread: thread));
    },
  );
}

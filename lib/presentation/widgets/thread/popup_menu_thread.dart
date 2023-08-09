import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share/share.dart';
import 'package:treechan/presentation/bloc/thread_bloc.dart';
import 'package:treechan/presentation/screens/hidden_posts_screen.dart';

class PopupMenuThread extends StatefulWidget {
  const PopupMenuThread({super.key});

  @override
  State<PopupMenuThread> createState() => _PopupMenuThreadState();
}

class _PopupMenuThreadState extends State<PopupMenuThread> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        icon: const Icon(Icons.more_vert),
        padding: EdgeInsets.zero,
        itemBuilder: (BuildContext context) {
          return <PopupMenuEntry>[
            PopupMenuItem(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: const Text('Поделиться'),
              onTap: () {
                final threadInfo =
                    BlocProvider.of<ThreadBloc>(context).threadInfo;
                if (threadInfo != null) {
                  Share.share(
                      'https://2ch.hk/${threadInfo.board!.id}/res/${threadInfo.opPostId}.html');
                }
              },
            ),
            PopupMenuItem(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: const Text('Скрытые посты'),
              onTap: () {
                final threadInfo =
                    BlocProvider.of<ThreadBloc>(context).threadInfo;
                Future.delayed(
                    const Duration(milliseconds: 50),
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HiddenPostsScreen(
                              tag: threadInfo!.board!.id!,
                              threadId: threadInfo.opPostId!),
                        )));
              },
            )
          ];
        });
  }
}

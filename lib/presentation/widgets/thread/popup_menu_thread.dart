import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share/share.dart';
import 'package:treechan/presentation/bloc/thread_bloc.dart';
import 'package:treechan/presentation/provider/page_provider.dart';

import '../../../domain/models/tab.dart';
import '../../bloc/thread_base.dart';

/// Called from AppBar button.
class PopupMenuThread extends StatelessWidget {
  const PopupMenuThread({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        icon: const Icon(Icons.more_vert),
        padding: EdgeInsets.zero,
        itemBuilder: (BuildContext context) {
          return <PopupMenuEntry>[
            _getShareMenuButton(BlocProvider.of<ThreadBloc>(context)),
            _getHiddenPostsMenuItem(
                context, BlocProvider.of<ThreadBloc>(context)),
          ];
        });
  }
}

/// Called from BottomNavigationBar button.
void showPopupMenuThread(
    BuildContext context, ThreadBase bloc, PageProvider provider) async {
  final RelativeRect rect = RelativeRect.fromLTRB(
      MediaQuery.of(context).size.width - 136, // width of popup menu
      MediaQuery.of(context).size.height - 5 * 48 - 60,
      // 48 is the height of one tile, 60 is approx. height of bottom bars
      0,
      0);
  showMenu(
    context: context,
    position: rect,
    items: [
      _getShareMenuButton(bloc),
      // ignore: use_build_context_synchronously
      _getHiddenPostsMenuItem(context, bloc),
      await _getTrackMenuButton(provider),
      _getScrollToTopMenuButton(bloc),
      _getScrollToBottomMenuButton(bloc),
    ],
    elevation: 8.0,
  );
}

Future<PopupMenuItem<dynamic>> _getTrackMenuButton(
    PageProvider provider) async {
  final bool isTracked = await provider.trackerRepository
      .isTracked(provider.tabManager.currentTab as IdMixin);

  if (isTracked) {
    return PopupMenuItem(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: const Text('Не отслеживать'),
        onTap: () {
          provider.unsubscribe();
        });
  } else {
    return PopupMenuItem(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: const Text('Отслеживать'),
        onTap: () {
          provider.subscribe();
        });
  }
}

PopupMenuItem<dynamic> _getShareMenuButton(ThreadBase bloc) {
  return PopupMenuItem(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: const Text('Поделиться'),
    onTap: () {
      final threadInfo = bloc.threadInfo;
      Share.share(
          'https://2ch.hk/${threadInfo.boardTag}/res/${threadInfo.opPostId}.html');
    },
  );
}

PopupMenuItem<dynamic> _getHiddenPostsMenuItem(
    BuildContext context, ThreadBase bloc) {
  return PopupMenuItem(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: const Text('Скрытые посты'),
    onTap: () {
      final threadInfo = bloc.threadInfo;
      Future.delayed(
          const Duration(milliseconds: 50),
          () => Navigator.pushNamed(context, '/hidden_posts', arguments: {
                'tag': threadInfo.boardTag,
                'threadId': threadInfo.opPostId
              }));
    },
  );
}

PopupMenuItem<dynamic> _getScrollToTopMenuButton(ThreadBase bloc) {
  return PopupMenuItem(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: const Text('В начало'),
    onTap: () {
      bloc.scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    },
  );
}

PopupMenuItem<dynamic> _getScrollToBottomMenuButton(ThreadBase bloc) {
  return PopupMenuItem(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: const Text('В конец'),
    onTap: () async {
      await bloc.scrollController.animateTo(
        bloc.scrollController.position.maxScrollExtent * 2,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
      bloc.scrollController.animateTo(
        bloc.scrollController.offset + 200,
        duration: const Duration(milliseconds: 20),
        curve: Curves.easeOut,
      );
    },
  );
}

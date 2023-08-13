import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:should_rebuild/should_rebuild.dart' as rebuild;
import 'package:treechan/data/hidden_threads_database.dart';
import 'package:treechan/exceptions.dart';

import '../../domain/models/json/json.dart';
import '../bloc/board_bloc.dart';

import '../provider/page_provider.dart';
import '../../domain/models/tab.dart';
import '../widgets/board/board_appbar.dart';
import '../widgets/board/thread_card.dart';
import '../widgets/shared/no_connection_placeholder.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({
    super.key,
    required this.currentTab,
  });
  final BoardTab currentTab;
  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool needsRebuild = false;

  EasyRefreshController controller =
      EasyRefreshController(controlFinishLoad: true);
  @override
  void dispose() {
    super.dispose();
  }

// List of threads
  @override
  Widget build(BuildContext context) {
    super.build(context);

    /// Avoid unnecessary rebuilds caused by [notifyListeners()]
    /// Using [needsRebuild] flag if needs to rebuild
    return rebuild.ShouldRebuild(
      shouldRebuild: (oldWidget, newWidget) {
        final bool shouldRebuild = needsRebuild;
        needsRebuild = false;
        return shouldRebuild;
      },
      child: BlocBuilder<BoardBloc, BoardState>(
        builder: (context, state) {
          if (state is BoardLoadedState) {
            if (widget.currentTab.name == null) {
              Provider.of<PageProvider>(context, listen: false)
                  .setName(widget.currentTab, state.boardName);
              widget.currentTab.name = state.boardName;
            }
            if (state.completeRefresh) {
              controller.finishLoad();
            } else {}
            return Scaffold(
              appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(56),
                  child: NormalAppBar(
                    currentTab: widget.currentTab,
                  )),
              body: EasyRefresh(
                header: _getClassicRefreshHeader(),
                footer: _getClassicRefreshFooter(),
                controller: controller,
                onRefresh: () {
                  BlocProvider.of<BoardBloc>(context).add(ReloadBoardEvent());
                },
                onLoad: () {
                  BlocProvider.of<BoardBloc>(context).add(RefreshBoardEvent());
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                  child: ListView.builder(
                    controller:
                        BlocProvider.of<BoardBloc>(context).scrollController,
                    itemCount: state.threads!.length,
                    itemBuilder: (context, index) {
                      final Thread thread = state.threads![index];
                      thread.hidden = BlocProvider.of<BoardBloc>(context)
                          .hiddenThreads
                          .contains(thread.posts.first.id);
                      return Dismissible(
                        key: ValueKey(thread.posts.first.id),
                        confirmDismiss: (direction) async {
                          needsRebuild = true;
                          hideOrRevealThread(thread, context);
                          return false;
                        },
                        child: ThreadCard(
                          // key: ValueKey(thread.posts.first.id),
                          thread: thread,
                          currentTab: widget.currentTab,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          } else if (state is BoardSearchState) {
            return Scaffold(
              appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(56),
                  child: SearchAppBar(
                    state: state,
                  )),
              body: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                child: ListView.builder(
                  controller:
                      BlocProvider.of<BoardBloc>(context).scrollController,
                  itemCount: state.searchResult.length,
                  itemBuilder: (context, index) {
                    final Thread thread = state.searchResult[index];
                    return ThreadCard(
                      key: ValueKey(thread.posts.first.id),
                      thread: thread,
                      currentTab: widget.currentTab,
                    );
                  },
                ),
              ),
            );
          } else if (state is BoardErrorState) {
            if (state.exception is NoConnectionException) {
              return Scaffold(
                  appBar: PreferredSize(
                      preferredSize: const Size.fromHeight(56),
                      child: NormalAppBar(
                        currentTab: widget.currentTab,
                      )),
                  body: const NoConnectionPlaceholder());
            }
            return Center(child: Text(state.message.toString()));
          } else {
            return Scaffold(
                appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(56),
                    child: NormalAppBar(
                      currentTab: widget.currentTab,
                    )),
                body: const Center(child: CircularProgressIndicator()));
          }
        },
      ),
    );
  }

  void hideOrRevealThread(Thread thread, BuildContext context) {
    return setState(() {
      if (thread.hidden) {
        HiddenThreadsDatabase()
            .removeThread(widget.currentTab.tag, thread.posts.first.id);
        context.read<BoardBloc>().hiddenThreads.remove(thread.posts.first.id);
      } else {
        HiddenThreadsDatabase().addThread(widget.currentTab.tag,
            thread.posts.first.id, thread.posts.first.subject);
        context.read<BoardBloc>().hiddenThreads.add(thread.posts.first.id);
      }

      thread.hidden = !thread.hidden;
    });
  }

  ClassicFooter _getClassicRefreshFooter() {
    return const ClassicFooter(
      dragText: 'Потяните для загрузки',
      armedText: 'Готово к загрузке',
      readyText: 'Загрузка...',
      processingText: 'Загрузка...',
      processedText: 'Загружено',
      noMoreText: 'Все прочитано',
      failedText: 'Ошибка',
      messageText: 'Последнее обновление - %T',
    );
  }

  ClassicHeader _getClassicRefreshHeader() {
    return const ClassicHeader(
      dragText: 'Потяните для загрузки',
      armedText: 'Готово к загрузке',
      readyText: 'Загрузка...',
      processingText: 'Загрузка...',
      processedText: 'Загружено',
      noMoreText: 'Все прочитано',
      failedText: 'Ошибка',
      messageText: 'Последнее обновление - %T',
    );
  }
}

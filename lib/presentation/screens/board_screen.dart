import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:should_rebuild/should_rebuild.dart' as rebuild;
import 'package:treechan/data/local/hidden_threads_database.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/presentation/widgets/board/thread_card_classic.dart';
import 'package:treechan/utils/constants/enums.dart';

import '../bloc/board_bloc.dart';

import '../provider/page_provider.dart';
import '../../domain/models/tab.dart';
import '../widgets/board/board_appbar.dart';
import '../widgets/board/thread_card.dart';
import '../widgets/shared/no_connection_placeholder.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key, required this.currentTab});
  final BoardTab currentTab;
  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool needsRebuild = false;
  void _markNeedsRebuild() => needsRebuild = true;

  EasyRefreshController controller =
      EasyRefreshController(controlFinishLoad: true);

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
            return BoardLoaded(
              currentTab: widget.currentTab,
              controller: controller,
              state: state,
              hideOrRevealThread: hideOrRevealThread,
              markNeedsRebuild: () => _markNeedsRebuild(),
            );
          } else if (state is BoardSearchState) {
            return BoardSearch(currentTab: widget.currentTab, state: state);
          } else if (state is BoardErrorState) {
            if (state.exception is DioException &&
                (state.exception as DioException).type ==
                    DioExceptionType.connectionError) {
              return NoConnection(currentTab: widget.currentTab);
            }
            return UnknownBoardError(
                currentTab: widget.currentTab, state: state);
          } else {
            return BoardLoading(currentTab: widget.currentTab);
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
}

class BoardLoading extends StatelessWidget {
  const BoardLoading({super.key, required this.currentTab});

  final BoardTab currentTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: NormalAppBar(
            currentTab: currentTab,
          )),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class BoardLoaded extends StatelessWidget {
  const BoardLoaded({
    super.key,
    required this.currentTab,
    required this.controller,
    required this.state,
    required this.hideOrRevealThread,
    required this.markNeedsRebuild,
  });
  final BoardTab currentTab;
  final EasyRefreshController controller;
  final BoardLoadedState state;
  final Function hideOrRevealThread;
  final Function markNeedsRebuild;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(children: [
        EasyRefresh(
          header: _getClassicRefreshHeader(),
          footer: _getClassicRefreshFooter(),
          controller: controller,
          onRefresh: () {
            context.read<BoardBloc>().add(ReloadBoardEvent());
          },
          onLoad: () {
            context.read<BoardBloc>().add(RefreshBoardEvent());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomScrollView(
                controller: context.read<BoardBloc>().scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox.fromSize(size: const Size.fromHeight(90)),
                  ),
                  const HeaderLocator.sliver(),
                  SliverList.builder(
                    // padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    itemCount: state.threads!.length,
                    itemBuilder: (context, index) {
                      final Thread thread = state.threads![index];
                      thread.hidden = BlocProvider.of<BoardBloc>(context)
                              .hiddenThreads
                              .contains(thread.posts.first.id)
                          ? true
                          : thread.hidden;
                      return Dismissible(
                        key: ValueKey(thread.posts.first.id),
                        confirmDismiss: (direction) async {
                          markNeedsRebuild();
                          hideOrRevealThread(thread, context);
                          return false;
                        },
                        child: state.boardView == BoardView.treechan
                            ? ThreadCard(
                                // key: ValueKey(thread.posts.first.id),
                                thread: thread,
                                currentTab: currentTab,
                              )
                            : ThreadCardClassic(
                                thread: thread, currentTab: currentTab),
                      );
                    },
                  ),
                ]),
          ),
        ),
        NormalAppBar(
          currentTab: currentTab,
        )
      ]),
    );
  }
}

class BoardSearch extends StatelessWidget {
  const BoardSearch({
    super.key,
    required this.currentTab,
    required this.state,
  });

  final BoardTab currentTab;
  final BoardSearchState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: SearchAppBar(
            state: state,
          )),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: ListView.builder(
          controller: context.read<BoardBloc>().scrollController,
          itemCount: state.searchResult.length,
          itemBuilder: (context, index) {
            final Thread thread = state.searchResult[index];

            return state.boardView == BoardView.treechan
                ? ThreadCard(
                    key: ValueKey(thread.posts.first.id),
                    thread: thread,
                    currentTab: currentTab,
                  )
                : ThreadCardClassic(
                    key: ValueKey(thread.posts.first.id),
                    thread: thread,
                    currentTab: currentTab);
          },
        ),
      ),
    );
  }
}

class NoConnection extends StatelessWidget {
  const NoConnection({
    super.key,
    required this.currentTab,
  });

  final BoardTab currentTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: NormalAppBar(
              currentTab: currentTab,
            )),
        body: const NoConnectionPlaceholder());
  }
}

class UnknownBoardError extends StatelessWidget {
  const UnknownBoardError({
    super.key,
    required this.currentTab,
    required this.state,
  });
  final BoardTab currentTab;
  final BoardErrorState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: NormalAppBar(
            currentTab: currentTab,
          )),
      body: Center(
          child: Text(
        state.message.toString(),
        textAlign: TextAlign.center,
      )),
    );
  }
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
    position: IndicatorPosition.locator,
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

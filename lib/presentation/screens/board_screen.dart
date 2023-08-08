import 'dart:io';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:should_rebuild/should_rebuild.dart' as rebuild;
import 'package:treechan/data/hidden_threads_database.dart';
import 'package:treechan/exceptions.dart';
import 'package:treechan/presentation/widgets/board/popup_menu_board.dart';

import '../../domain/models/json/json.dart';
import '../../utils/constants/enums.dart';
import '../bloc/board_bloc.dart';

import '../provider/tab_provider.dart';
import '../../domain/models/tab.dart';
import '../widgets/board/thread_card.dart';
import '../widgets/shared/go_back_widget.dart';
import '../widgets/shared/no_connection_placeholder.dart';

class BoardAppBar extends StatefulWidget {
  const BoardAppBar({super.key, required this.currentTab});

  final BoardTab currentTab;

  @override
  State<BoardAppBar> createState() => _BoardAppBarState();
}

class _BoardAppBarState extends State<BoardAppBar> {
  final controller = TextEditingController(text: "INITIALCONTROLLERTEXT");
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardBloc, BoardState>(
      builder: (context, state) {
        if (state is BoardLoadedState) {
          controller.text = "INITIALCONTROLLERTEXT";
          return AppBar(
            title: Text(
              widget.currentTab.name ?? "Загрузка...",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            leading: _getLeading(context),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  if (BlocProvider.of<BoardBloc>(context)
                          .boardService
                          .sortType ==
                      SortBy.page) {
                    BlocProvider.of<BoardBloc>(context)
                        .add(ChangeViewBoardEvent(null, searchTag: ""));
                  } else {
                    BlocProvider.of<BoardBloc>(context)
                        .add(SearchQueryChangedEvent(""));
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  // widget.onMarkNeedsRebuild();
                  BlocProvider.of<BoardBloc>(context).add(ReloadBoardEvent());
                },
              ),
              PopupMenuBoard(
                  currentTab: widget.currentTab,
                  onOpen: (ThreadTab tab) =>
                      Provider.of<TabProvider>(context, listen: false)
                          .addTab(tab))
            ],
          );
        } else if (state is BoardSearchState) {
          // text controller
          if (controller.text == 'INITIALCONTROLLERTEXT') {
            controller.text = state.query;
          }
          return AppBar(
            title: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              autofocus: true,
              decoration: const InputDecoration(
                  hintText: ' Поиск',
                  hintStyle: TextStyle(color: Colors.white70),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white))),
              onChanged: (query) {
                BlocProvider.of<BoardBloc>(context)
                    .add(SearchQueryChangedEvent(query));
              },
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                BlocProvider.of<BoardBloc>(context).add(LoadBoardEvent());
              },
            ),
          );
        } else {
          return AppBar(
              title: const Text("Загрузка..."), leading: _getLeading(context));
        }
      },
    );
  }

  StatelessWidget _getLeading(BuildContext context) {
    return !Platform.isWindows
        ? GoBackButton(currentTab: widget.currentTab)
        : IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
  }
}

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
  @override
  void dispose() {
    super.dispose();
  }

// List of threads
  @override
  Widget build(BuildContext context) {
    super.build(context);
    EasyRefreshController controller =
        EasyRefreshController(controlFinishLoad: true);

    /// Avoid unnecessary rebuilds caused by [notifyListeners()]
    /// Using [needsRebuild] flag if needs to rebuild
    return rebuild.ShouldRebuild(
      shouldRebuild: (oldWidget, newWidget) {
        bool shouldRebuild = needsRebuild;
        needsRebuild = false;
        return shouldRebuild;
      },
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: BoardAppBar(
              currentTab: widget.currentTab,
            )),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
            child: BlocBuilder<BoardBloc, BoardState>(
              builder: (context, state) {
                if (state is BoardLoadedState) {
                  if (widget.currentTab.name == null) {
                    Provider.of<TabProvider>(context, listen: false)
                        .setName(widget.currentTab, state.boardName);
                    widget.currentTab.name = state.boardName;
                  }
                  if (state.completeRefresh) {
                    controller.finishLoad();
                  } else {}
                  return EasyRefresh(
                    header: const ClassicHeader(
                      dragText: 'Потяните для загрузки',
                      armedText: 'Готово к загрузке',
                      readyText: 'Загрузка...',
                      processingText: 'Загрузка...',
                      processedText: 'Загружено',
                      noMoreText: 'Все прочитано',
                      failedText: 'Ошибка',
                      messageText: 'Последнее обновление - %T',
                    ),
                    footer: const ClassicFooter(
                      dragText: 'Потяните для загрузки',
                      armedText: 'Готово к загрузке',
                      readyText: 'Загрузка...',
                      processingText: 'Загрузка...',
                      processedText: 'Загружено',
                      noMoreText: 'Все прочитано',
                      failedText: 'Ошибка',
                      messageText: 'Последнее обновление - %T',
                    ),
                    controller: controller,
                    onRefresh: () {
                      BlocProvider.of<BoardBloc>(context)
                          .add(ReloadBoardEvent());
                    },
                    onLoad: () {
                      BlocProvider.of<BoardBloc>(context)
                          .add(RefreshBoardEvent());
                    },
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
                            setState(() {
                              HiddenThreadsDatabase().addThread(
                                  widget.currentTab.tag,
                                  thread.posts.first.id,
                                  thread.posts.first.subject);
                              BlocProvider.of<BoardBloc>(context)
                                  .hiddenThreads
                                  .add(thread.posts.first.id);
                              state.threads![index].hidden = true;
                            });
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
                  );
                } else if (state is BoardSearchState) {
                  return ListView.builder(
                    itemCount: state.searchResult.length,
                    itemBuilder: (context, index) {
                      final Thread thread = state.searchResult[index];
                      return ThreadCard(
                        key: ValueKey(thread.posts.first.id),
                        thread: thread,
                        currentTab: widget.currentTab,
                      );
                    },
                  );
                } else if (state is BoardErrorState) {
                  if (state.exception is NoConnectionException) {
                    return const NoConnectionPlaceholder();
                  }
                  return Center(child: Text(state.message));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            )),
      ),
    );
  }
}

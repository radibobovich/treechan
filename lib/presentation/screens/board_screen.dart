import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:treechan/presentation/widgets/board/popup_menu_board.dart';

import '../../utils/constants/enums.dart';
import '../bloc/board_bloc.dart';

import '../provider/tab_provider.dart';
import '../../domain/models/tab.dart';
import '../widgets/board/refresh_custom_footer.dart';
import '../widgets/board/thread_card.dart';
import '../widgets/shared/go_back_widget.dart';

class BoardAppBar extends StatefulWidget {
  const BoardAppBar({super.key, required this.currentTab});

  final DrawerTab currentTab;

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
            leading: !Platform.isWindows
                ? GoBackButton(currentTab: widget.currentTab)
                : IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
            actions: [
              BlocProvider.of<BoardBloc>(context).boardService.sortType !=
                      SortBy.page
                  ? IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        BlocProvider.of<BoardBloc>(context)
                            .add(SearchQueryChangedEvent(""));
                      },
                    )
                  : const SizedBox.shrink(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  BlocProvider.of<BoardBloc>(context)
                      .add(RefreshBoardEvent(refreshFromScratch: true));
                },
              ),
              const PopupMenuBoard()
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
          return AppBar(title: const Text("Загрузка..."));
        }
      },
    );
  }
}

class BoardScreen extends StatefulWidget {
  const BoardScreen({
    super.key,
    required this.currentTab,
  });
  final DrawerTab currentTab;
  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }

// List of threads
  @override
  Widget build(BuildContext context) {
    super.build(context);
    RefreshController controller = RefreshController();
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: BoardAppBar(currentTab: widget.currentTab)),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
          child: BlocBuilder<BoardBloc, BoardState>(
            builder: (context, state) {
              if (state is BoardLoadedState) {
                if (widget.currentTab.name == null) {
                  context
                      .read<TabProvider>()
                      .setName(widget.currentTab, state.boardName);
                  widget.currentTab.name = state.boardName;
                }
                if (state.completeRefresh) {
                  controller.resetNoData();
                  controller.refreshCompleted();
                  controller.loadComplete();
                } else {
                  controller.loadNoData();
                }
                return SmartRefresher(
                  controller: controller,
                  enablePullUp: true,
                  onRefresh: () {
                    BlocProvider.of<BoardBloc>(context)
                        .add(RefreshBoardEvent(refreshFromScratch: true));
                  },
                  onLoading: () {
                    BlocProvider.of<BoardBloc>(context)
                        .add(RefreshBoardEvent());
                  },
                  footer: RefreshCustomFooter(controller: controller),
                  child: ListView.builder(
                    itemCount: state.threads!.length,
                    itemBuilder: (context, index) {
                      return ThreadCard(
                        thread: state.threads![index],
                        currentTab: widget.currentTab,
                      );
                    },
                  ),
                );
              } else if (state is BoardSearchState) {
                return ListView.builder(
                  itemCount: state.searchResult.length,
                  itemBuilder: (context, index) {
                    return ThreadCard(
                      thread: state.searchResult[index],
                      currentTab: widget.currentTab,
                    );
                  },
                );
              } else if (state is BoardErrorState) {
                return Center(child: Text(state.errorMessage));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          )),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:treechan/models/bloc/board_bloc.dart';
import '../widgets/refresh_custom_footer.dart';
import '../widgets/thread_card.dart';
import 'tab_navigator.dart';
import '../widgets/go_back_widget.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen(
      {super.key,
      required this.currentTab,
      required this.onOpen,
      required this.onGoBack,
      required this.onSetName});
  final DrawerTab currentTab;
  final Function onOpen;
  final Function onGoBack;
  final Function onSetName;
  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
// List of threads
  @override
  Widget build(BuildContext context) {
    super.build(context);
    RefreshController controller = RefreshController();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.currentTab.name ?? "Загрузка...",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: GoBackButton(
            onGoBack: widget.onGoBack, currentTab: widget.currentTab),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              BlocProvider.of<BoardBloc>(context)
                  .add(RefreshBoardEvent(refreshFromScratch: true));
            },
          )
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
          child: BlocBuilder<BoardBloc, BoardState>(
            builder: (context, state) {
              if (state is BoardLoadedState) {
                if (widget.currentTab.name == null) {
                  widget.onSetName(state.boardName);
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
                        onOpen: widget.onOpen,
                        onGoBack: widget.onGoBack,
                      );
                    },
                  ),
                );
              } else if (state is BoardErrorState) {
                return const Center(child: Text("404 - доска не найдена"));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          )),
    );
  }
}

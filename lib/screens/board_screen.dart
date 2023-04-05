import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/models/bloc/board_bloc.dart';
import '../widgets/thread_card.dart';
import 'tab_navigator.dart';
import '../widgets/go_back_widget.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen(
      {super.key,
      required this.boardName,
      required this.boardTag,
      required this.onOpen,
      required this.onGoBack});
  final String boardName;
  final String boardTag;
  final Function onOpen;
  final Function onGoBack;
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
    DrawerTab currentTab = DrawerTab(
        type: TabTypes.board, tag: widget.boardTag, prevTab: boardListTab);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.boardName),
        leading:
            GoBackButton(onGoBack: widget.onGoBack, currentTab: currentTab),
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
                return ListView.builder(
                  itemCount: state.threads!.length,
                  itemBuilder: (context, index) {
                    return ThreadCard(
                      thread: state.threads![index],
                      onOpen: widget.onOpen,
                      onGoBack: widget.onGoBack,
                      boardName: widget.boardName,
                      boardTag: widget.boardTag,
                    );
                  },
                );
              } else if (state is BoardErrorState) {
                return Center(
                  child: Text(state.errorMessage),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          )),
    );
  }
}

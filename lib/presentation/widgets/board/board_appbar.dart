import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:treechan/presentation/widgets/board/popup_menu_board.dart';

import '../../../domain/models/tab.dart';
import '../../../utils/constants/enums.dart';
import '../../bloc/board_bloc.dart';
import '../../provider/tab_provider.dart';
import '../shared/go_back_widget.dart';

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

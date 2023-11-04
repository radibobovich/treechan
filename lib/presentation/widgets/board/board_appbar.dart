import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hidable/hidable.dart';
import 'package:provider/provider.dart';
import 'package:treechan/presentation/screens/page_navigator.dart';
import 'package:treechan/presentation/widgets/board/popup_menu_board.dart';
import 'package:treechan/utils/custom_hidable_visibility.dart';

import '../../../domain/models/tab.dart';
import '../../../utils/constants/enums.dart';
import '../../bloc/board_bloc.dart';
import '../../provider/page_provider.dart';
import '../shared/go_back_widget.dart';

class NormalAppBar extends StatefulWidget {
  const NormalAppBar({super.key, required this.currentTab});

  final BoardTab currentTab;

  @override
  State<NormalAppBar> createState() => _NormalAppBarState();
}

class _NormalAppBarState extends State<NormalAppBar> {
  @override
  Widget build(BuildContext context) {
    return Hidable(
      deltaFactor: 0.04,
      visibility: customHidableVisibility,
      controller: !Platform.isWindows
          ? context.read<BoardBloc>().scrollController
          : ScrollController(),
      preferredWidgetSize: const Size.fromHeight(86),
      child: AppBar(
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
                      .boardRepository
                      .sortType ==
                  SortBy.page) {
                BlocProvider.of<BoardBloc>(context)
                    .add(ChangeSortBoardEvent(null, query: ""));
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
                  Provider.of<PageProvider>(context, listen: false).addTab(tab))
        ],
        bottom: context.select<BoardBloc, bool>((BoardBloc bloc) => bloc.isBusy)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
    );
  }

  StatelessWidget _getLeading(BuildContext context) {
    return !Platform.isWindows
        ? GoBackButton(currentTab: widget.currentTab)
        : IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              openDrawer();
            },
          );
  }
}

class SearchAppBar extends StatefulWidget {
  const SearchAppBar({super.key, required this.state});
  final BoardSearchState state;
  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        controller: BlocProvider.of<BoardBloc>(context).textController,
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
  }
}

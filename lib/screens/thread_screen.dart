import 'dart:io';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/widgets/thread/popup_menu_thread.dart';
import 'dart:ui';

import '../screens/tab_navigator.dart';

import '../main.dart';
import '../models/json/json.dart';
import '../models/bloc/thread_bloc.dart';

import '../services/scroll_service.dart';
import '../widgets/shared/go_back_widget.dart';
import '../widgets/thread/post_widget.dart';

class ThreadScreen extends StatefulWidget {
  const ThreadScreen(
      {super.key,
      required this.onOpen,
      required this.onGoBack,
      required this.currentTab,
      required this.prevTab,
      required this.onSetName});
  final DrawerTab currentTab;
  final DrawerTab prevTab;
  final Function onOpen;
  final Function onGoBack;
  final Function onSetName;
  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late ScrollController scrollController;
  late ScrollService scrollService;
  GlobalKey treeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollService = ScrollService(scrollController,
        (window.physicalSize / window.devicePixelRatio).width);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.currentTab.name ?? "Загрузка...",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: !Platform.isWindows
              ? GoBackButton(
                  onGoBack: widget.onGoBack, currentTab: widget.currentTab)
              : IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
          actions: <Widget>[
            IconButton(
                onPressed: () async {
                  _refreshThread();
                },
                icon: const Icon(Icons.refresh)),
            PopupMenuThread()
          ],
        ),
        body: BlocBuilder<ThreadBloc, ThreadState>(
          builder: (context, state) {
            if (state is ThreadLoadedState) {
              if (widget.currentTab.name == null) {
                widget.onSetName(state.threadInfo!.title!);
                widget.currentTab.name = state.threadInfo!.title!;
              }
              return FlexibleTreeView<Post>(
                key: treeKey,
                scrollable: prefs.getBool('2dscroll')!,
                indent: !Platform.isWindows ? 16 : 24,
                showLines: state.threadInfo!.showLines!,
                scrollController: scrollController,
                nodes: state.roots!,
                nodeWidth: MediaQuery.of(context).size.width / 1.5,
                nodeItemBuilder: (context, node) {
                  return PostWidget(
                    key: node.gKey,
                    node: node,
                    roots: state.roots!,
                    currentTab: widget.currentTab,
                    onOpen: widget.onOpen,
                    onGoBack: widget.onGoBack,
                    scrollService: scrollService,
                  );
                },
              );
            } else if (state is ThreadErrorState) {
              return Center(child: Text(state.errorMessage));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }

  Future<void> _refreshThread() async {
    scrollService.saveCurrentScrollInfo();

    BlocProvider.of<ThreadBloc>(context).add(RefreshThreadEvent());
    await Future.delayed(const Duration(milliseconds: 10));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollService.updateScrollPosition();
    });
  }
}

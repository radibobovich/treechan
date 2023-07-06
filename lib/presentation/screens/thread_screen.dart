import 'dart:io';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/presentation/widgets/thread/popup_menu_thread.dart';
import 'dart:ui';

import '../provider/tab_provider.dart';
import '../../domain/models/tab.dart';

import '../../main.dart';
import '../../domain/models/json/json.dart';
import '../bloc/thread_bloc.dart';

import '../../domain/services/scroll_service.dart';
import '../widgets/shared/go_back_widget.dart';
import '../widgets/thread/post_widget.dart';

class ThreadScreen extends StatefulWidget {
  const ThreadScreen({
    super.key,
    required this.currentTab,
    required this.prevTab,
  });
  final DrawerTab currentTab;
  final DrawerTab prevTab;
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
              ? GoBackButton(currentTab: widget.currentTab)
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
            const PopupMenuThread()
          ],
        ),
        body: BlocBuilder<ThreadBloc, ThreadState>(
          builder: (context, state) {
            if (state is ThreadLoadedState) {
              if (widget.currentTab.name == null) {
                context
                    .read<TabProvider>()
                    .setName(widget.currentTab, state.threadInfo!.title!);
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
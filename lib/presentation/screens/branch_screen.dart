import 'dart:io';
import 'dart:ui';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/utils/constants/enums.dart';

import '../../domain/models/json/post_json.dart';
import '../../domain/models/tab.dart';
import '../../domain/models/tree.dart';
import '../../domain/services/scroll_service.dart';
import '../../exceptions.dart';
import '../../main.dart';
import '../bloc/branch_bloc.dart';
import '../provider/tab_provider.dart';
import '../widgets/shared/go_back_widget.dart';
import '../widgets/shared/no_connection_placeholder.dart';
import '../widgets/thread/post_widget.dart';

class BranchScreen extends StatefulWidget {
  const BranchScreen({super.key, required this.currentTab});

  final DrawerTab currentTab;
  @override
  State<BranchScreen> createState() => _BranchScreenState();
}

class _BranchScreenState extends State<BranchScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // late ScrollController scrollController;
  // late ScrollService scrollService;
  // @override
  // void initState() {
  //   super.initState();
  //   scrollController = ScrollController();
  //   scrollService = ScrollService(scrollController,
  //       (window.physicalSize / window.devicePixelRatio).width);
  // }

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
                  BlocProvider.of<BranchBloc>(context)
                      .add(RefreshBranchEvent(RefreshSource.branch));
                },
                icon: const Icon(Icons.refresh)),
            // const PopupMenuBranch()
          ],
        ),
        body: BlocBuilder<BranchBloc, BranchState>(
          builder: (context, state) {
            if (state is BranchLoadedState) {
              return FlexibleTreeView<Post>(
                // key: treeKey,
                key: ValueKey(state.branch.data.id),
                scrollable: prefs.getBool('2dscroll')!,
                indent: !Platform.isWindows ? 16 : 24,
                showLines: state.threadInfo.showLines!,
                scrollController:
                    BlocProvider.of<BranchBloc>(context).scrollController,
                nodes: [state.branch],
                nodeWidth: MediaQuery.of(context).size.width / 1.5,
                nodeItemBuilder: (context, node) {
                  return PostWidget(
                    // get separated key set based on branch node id
                    key: node.getGlobalKey(state.branch.data.id),
                    node: node,
                    roots: [state.branch],
                    currentTab: widget.currentTab,
                    scrollService:
                        BlocProvider.of<BranchBloc>(context).scrollService,
                  );
                },
              );
            } else if (state is BranchErrorState) {
              if (state.exception is NoConnectionException) {
                return const NoConnectionPlaceholder();
              }
              return Center(child: Text(state.message));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }
}

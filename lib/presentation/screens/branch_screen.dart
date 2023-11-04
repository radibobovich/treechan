import 'dart:io';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hidable/hidable.dart';
import 'package:should_rebuild/should_rebuild.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/presentation/screens/page_navigator.dart';
import 'package:treechan/utils/constants/constants.dart';
import 'package:treechan/utils/constants/enums.dart';
import 'package:treechan/utils/custom_hidable_visibility.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../domain/models/tab.dart';
import '../../exceptions.dart';
import '../../main.dart';
import '../bloc/branch_bloc.dart';
import '../widgets/shared/go_back_widget.dart';
import '../widgets/shared/no_connection_placeholder.dart';
import '../widgets/thread/post_widget.dart';

class BranchScreen extends StatefulWidget {
  const BranchScreen({super.key, required this.currentTab});

  final BranchTab currentTab;
  @override
  State<BranchScreen> createState() => _BranchScreenState();
}

class _BranchScreenState extends State<BranchScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ShouldRebuild(
      shouldRebuild: (oldWidget, newWidget) => false,
      child: Scaffold(
          // appBar: BranchAppBar(currentTab: widget.currentTab),
          body: Stack(children: [
        BlocBuilder<BranchBloc, BranchState>(
          builder: (context, state) {
            if (state is BranchLoadedState) {
              return FlexibleTreeView<Post>(
                // key: treeKey,
                key: ValueKey(state.branch.data.id),
                scrollable: prefs.getBool('2dscroll')!,
                indent: !Platform.isWindows ? 16 : 24,
                showLines: state.threadInfo.showLines,
                scrollController:
                    BlocProvider.of<BranchBloc>(context).scrollController,
                nodes: [state.branch],
                nodeWidth: MediaQuery.of(context).size.width / 1.5,
                header: SizedBox.fromSize(size: const Size.fromHeight(86)),
                footer: SizedBox.fromSize(
                    size: const Size.fromHeight(AppConstants.navBarHeight)),
                nodeItemBuilder: (context, node) {
                  node.data.hidden = BlocProvider.of<BranchBloc>(context)
                      .threadRepository
                      .hiddenPosts
                      .contains(node.data.id);
                  return PostWidget(
                    // get separated key set based on branch node id
                    key: node.getGlobalKey(state.branch.data.id),
                    bloc: context.read<BranchBloc>(),
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
        ),
        BranchAppBar(currentTab: widget.currentTab),
      ])),
    );
  }
}

class BranchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BranchAppBar({
    super.key,
    required this.currentTab,
  });

  final BranchTab currentTab;
  @override
  Size get preferredSize => const Size.fromHeight(86);

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0) {
          context.read<BranchBloc>().resetNewPostsCount();
        }
      },
      child: Hidable(
        deltaFactor: 0.04,
        visibility: customHidableVisibility,
        controller: !Platform.isWindows
            ? context.read<BranchBloc>().scrollController
            : ScrollController(),
        preferredWidgetSize: const Size.fromHeight(86),
        child: AppBar(
          title: Text(
            currentTab.name ?? "Загрузка...",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: !Platform.isWindows
              ? GoBackButton(currentTab: currentTab)
              : IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    openDrawer();
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
          bottom:
              context.select<BranchBloc, bool>((BranchBloc bloc) => bloc.isBusy)
                  ? const PreferredSize(
                      preferredSize: Size.fromHeight(4),
                      child: LinearProgressIndicator(),
                    )
                  : null,
        ),
      ),
    );
  }
}

import 'dart:io';
import 'dart:ui';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hidable/hidable.dart';
import 'package:provider/provider.dart';
import 'package:should_rebuild/should_rebuild.dart' as rebuild;
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/presentation/screens/page_navigator.dart';
import 'package:treechan/presentation/widgets/drawer/end_drawer.dart';
import 'package:treechan/presentation/widgets/thread/popup_menu_thread.dart';
import 'package:treechan/utils/constants/constants.dart';
import 'package:treechan/utils/custom_hidable_visibility.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../exceptions.dart';
import '../provider/page_provider.dart';
import '../../domain/models/tab.dart';

import '../../main.dart';
import '../bloc/thread_bloc.dart';

import '../widgets/shared/go_back_widget.dart';
import '../widgets/shared/no_connection_placeholder.dart';
import '../widgets/thread/post_widget.dart';

class ThreadScreen extends StatefulWidget {
  const ThreadScreen({
    super.key,
    required this.currentTab,
    required this.prevTab,
  });
  final ThreadTab currentTab;
  final DrawerTab prevTab;
  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        key: context.read<ThreadBloc>().scaffoldKey,
        endDrawer: AppEndDrawer(currentTab: widget.currentTab),
        onEndDrawerChanged: (isOpened) {
          if (isOpened) {
            BlocProvider.of<ThreadBloc>(context)
                .restoreEndDrawerScrollPosition();
          } else {
            BlocProvider.of<ThreadBloc>(context).storeEndDrawerScrollPosition();
          }
        },
        // appBar: ThreadAppBar(currentTab: widget.currentTab),
        // extendBodyBehindAppBar: true,
        body: Stack(children: [
          rebuild.ShouldRebuild(
            shouldRebuild: (oldWidget, newWidget) => false,
            child: BlocBuilder<ThreadBloc, ThreadState>(
              builder: (context, state) {
                if (state is ThreadLoadedState) {
                  if (widget.currentTab.name == null) {
                    Provider.of<PageProvider>(context, listen: false)
                        .setName(widget.currentTab, state.threadInfo.title);
                    widget.currentTab.name = state.threadInfo.title;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {});
                    });
                  }
                  final bloc = context.read<ThreadBloc>();
                  return FlexibleTreeView<Post>(
                    scrollable: prefs.getBool('2dscroll')!,
                    indent: !Platform.isWindows ? 16 : 24,
                    showLines: state.threadInfo.showLines,
                    scrollController: bloc.scrollController,
                    nodes: state.roots!,
                    nodeWidth: MediaQuery.of(context).size.width / 1.5,
                    header: SizedBox.fromSize(size: const Size.fromHeight(86)),
                    footer: SizedBox.fromSize(
                        size: const Size.fromHeight(AppConstants.navBarHeight)),
                    nodeItemBuilder: (context, node) {
                      node.data.hidden = BlocProvider.of<ThreadBloc>(context)
                          .threadRepository
                          .hiddenPosts
                          .contains(node.data.id);
                      return PostWidget(
                        bloc: bloc,
                        key: node.getGlobalKey(state.threadInfo.opPostId),
                        node: node,
                        roots: state.roots!,
                        currentTab: widget.currentTab,
                        scrollService:
                            BlocProvider.of<ThreadBloc>(context).scrollService,
                      );
                    },
                  );
                } else if (state is ThreadErrorState) {
                  if (state.exception is NoConnectionException) {
                    return const NoConnectionPlaceholder();
                  }
                  return Center(child: Text(state.message));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),

          /// Use stack to make content appear behind the appbar and to avoid
          /// lags like we would have if used [extendBodyBehindAppbar] property
          ThreadAppBar(currentTab: widget.currentTab),
        ]));
  }
}

class ThreadAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ThreadAppBar({
    super.key,
    required this.currentTab,
  });

  final ThreadTab currentTab;

  @override
  State<ThreadAppBar> createState() => _ThreadAppBarState();
  @override
  Size get preferredSize => const Size.fromHeight(86);
}

class _ThreadAppBarState extends State<ThreadAppBar> {
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0) {
          context.read<ThreadBloc>().resetNewPostsCount();
        }
      },
      child: Hidable(
        deltaFactor: 0.04,
        visibility: customHidableVisibility,
        controller: !Platform.isWindows
            ? context.read<ThreadBloc>().scrollController
            : ScrollController(),
        preferredWidgetSize: const Size.fromHeight(86),
        child: AppBar(
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
                    openDrawer();
                  },
                ),
          actions: <Widget>[
            IconButton(
                onPressed: () async {
                  BlocProvider.of<ThreadBloc>(context)
                      .add(RefreshThreadEvent());
                },
                icon: const Icon(Icons.refresh)),
            const PopupMenuThread()
          ],
          bottom:
              context.select<ThreadBloc, bool>((ThreadBloc bloc) => bloc.isBusy)
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/presentation/widgets/shared/html_container_widget.dart';
import 'package:treechan/presentation/widgets/thread/action_menu_widget.dart';
import 'package:treechan/presentation/widgets/thread/post_widget.dart';

import '../../../domain/models/json/json.dart';
import '../../../domain/models/tab.dart';
import '../../../domain/models/tree.dart';
import '../../../domain/services/date_time_service.dart';
import '../../bloc/thread_bloc.dart';

class AppEndDrawer extends StatelessWidget {
  const AppEndDrawer({super.key, required this.currentTab});
  final DrawerTab currentTab;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: Text('Последние посты', style: TextStyle(fontSize: 16)),
        ),
        const Divider(
          thickness: 1,
        ),
        BlocBuilder<ThreadBloc, ThreadState>(
          builder: (_, state) {
            if (state is ThreadLoadedState) {
              final lastPosts = BlocProvider.of<ThreadBloc>(context)
                  .threadService
                  .getLastPosts;
              return Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  key: const PageStorageKey<String>('endDrawer'),
                  controller: BlocProvider.of<ThreadBloc>(context)
                      .endDrawerScrollController,
                  itemCount: lastPosts.length,
                  itemBuilder: (_, index) {
                    BlocProvider.of<ThreadBloc>(context).threadService.getPosts;
                    final post = lastPosts[index];
                    return PostPreview(post: post, currentTab: currentTab);
                  },
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        )
      ]),
    );
  }
}

class PostPreview extends StatelessWidget {
  const PostPreview({
    super.key,
    required this.post,
    required this.currentTab,
  });

  final Post post;
  final DrawerTab currentTab;

  @override
  Widget build(BuildContext context) {
    final bloc = getBloc(context, currentTab);
    final node =
        Tree.findNode(bloc.threadService.getRootsSynchronously, post.id);
    return Card(
      child: InkWell(
        onLongPress: () => openActionMenu(
            context, currentTab, node!, (function) {},
            calledFromEndDrawer: true),
        child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                _PostHeader(post: post),
                HtmlContainer(
                  post: post,
                  currentTab: currentTab,
                  treeNode: node,
                  roots: bloc.threadService.getRootsSynchronously,
                  // bloc: BlocProvider.of<ThreadBloc>(context)
                )
              ],
            )),
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({Key? key, required this.post}) : super(key: key);
  final Post post;

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<ThreadBloc>(context).threadService.getPosts;
    final DateTimeService dateTimeSerivce =
        DateTimeService(timestamp: post.timestamp);
    return Row(
      children: [
        Text(post.name,
            style: post.email == "mailto:sage"
                ? TextStyle(color: Theme.of(context).secondaryHeaderColor)
                : null),
        post.op == true
            ? const Padding(
                padding: EdgeInsets.fromLTRB(3, 0, 0, 0),
                child: Text(
                  'OP',
                  style: TextStyle(
                    color: Color.fromARGB(255, 120, 153, 34),
                  ),
                ),
              )
            : const SizedBox.shrink(),
        Text(" ${dateTimeSerivce.getAdaptiveDate()}",
            style:
                TextStyle(color: Theme.of(context).textTheme.bodySmall!.color)),
      ],
    );
  }
}

class PostBody extends StatelessWidget {
  const PostBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

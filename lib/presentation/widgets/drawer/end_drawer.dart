import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/config/themes.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/presentation/widgets/shared/html_container_widget.dart';
import 'package:treechan/presentation/widgets/shared/media_preview_widget.dart';
import 'package:treechan/presentation/widgets/thread/post_widget.dart';

import '../../../domain/models/tab.dart';
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
              final lastPosts =
                  context.read<ThreadBloc>().threadRepository.getLastNodes;
              return Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  // key: const PageStorageKey<String>('endDrawer'),
                  controller:
                      context.read<ThreadBloc>().endDrawerScrollController,
                  itemCount: lastPosts.length,
                  itemBuilder: (_, index) {
                    final node = lastPosts[index];
                    return EndDrawerPostWidget(
                      key: PageStorageKey(node.data.id),
                      node: node,
                      currentTab: currentTab,
                      bloc: context.read<ThreadBloc>(),
                    );
                  },
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        )
      ]),
    );
  }
}

class EndDrawerPostWidget extends StatelessWidget {
  const EndDrawerPostWidget({
    super.key,
    required this.node,
    required this.currentTab,
    required this.bloc,
  });

  final TreeNode<Post> node;
  final DrawerTab currentTab;
  final ThreadBloc bloc;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onLongPress: () => openActionMenu(
            context, bloc, currentTab, node, (function) {},
            calledFromEndDrawer: true),
        child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PostHeader(post: node.data),
                MediaPreview(
                  files: node.data.files,
                  height: 60,
                  imageboard: currentTab.imageboard,
                ),
                HtmlContainer(
                  bloc: bloc,
                  post: node.data,
                  currentTab: currentTab,
                  treeNode: node,
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
    context.read<ThreadBloc>().threadRepository.posts;
    final DateTimeService dateTimeSerivce =
        DateTimeService(timestamp: post.timestamp);
    return Row(
      children: [
        Text(post.name,
            style: post.email == "mailto:sage"
                ? TextStyle(color: context.colors.boldText)
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

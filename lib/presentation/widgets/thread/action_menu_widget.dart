import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share/share.dart';

import '../../../data/hidden_posts.database.dart';
import '../../../domain/models/json/json.dart';
import '../../../domain/models/tab.dart';
import '../../../domain/models/tree.dart';
import '../../../utils/remove_html.dart';
import '../../bloc/branch_bloc.dart';
import '../../bloc/thread_bloc.dart';
import '../../provider/page_provider.dart';

class ActionMenu extends StatelessWidget {
  final DrawerTab currentTab;
  final TreeNode<Post> node;
  final Function setStateCallBack;
  final bool calledFromEndDrawer;
  const ActionMenu({
    super.key,
    required this.currentTab,
    required this.node,
    required this.setStateCallBack,
    this.calledFromEndDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = getBloc(context, currentTab);
    return SizedBox(
        width: double.minPositive,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            title: Text('Пост #${node.data.id}'),
            subtitle: const Text('Информация о посте'),
            visualDensity: const VisualDensity(vertical: -3),
            onTap: () {
              showPostInfo(context);
            },
          ),
          node.data.number != 1
              ? ListTile(
                  title: const Text('Открыть в новой вкладке'),
                  visualDensity: const VisualDensity(vertical: -3),
                  onTap: () => openPostInNewTab(context),
                )
              : const SizedBox.shrink(),
          node.parent != null
              ? ListTile(
                  title: const Text('Свернуть ветку'),
                  visualDensity: const VisualDensity(vertical: -3),
                  onTap: () {
                    Navigator.pop(context);
                    bloc.shrinkBranch(node);
                  },
                )
              : const SizedBox.shrink(),
          node.parent != null
              ? ListTile(
                  title: const Text('Свернуть корневую ветку'),
                  visualDensity: const VisualDensity(vertical: -3),
                  onTap: () {
                    Navigator.pop(context);
                    bloc.shrinkRootBranch(node);
                  },
                )
              : const SizedBox.shrink(),
          ListTile(
            title: const Text('Перейти к посту'),
            visualDensity: const VisualDensity(vertical: -3),
            onTap: () => goToPost(node, context),
          ),
          ListTile(
            title: const Text('Копировать текст'),
            visualDensity: const VisualDensity(vertical: -3),
            onTap: () async {
              String comment = removeHtmlTags(node.data.comment,
                  links: true, replaceBr: true);
              await Clipboard.setData(ClipboardData(text: comment));
            },
          ),
          ListTile(
              title: const Text('Поделиться'),
              visualDensity: const VisualDensity(vertical: -3),
              onTap: () {
                Share.share(getPostLink(node));
              }),
          ListTile(
            title: node.data.hidden
                ? const Text('Показать')
                : const Text('Скрыть'),
            visualDensity: const VisualDensity(vertical: -3),
            onTap: () => hideOrRevealPost(context, bloc),
          )
        ]));
  }

  void hideOrRevealPost(BuildContext context, dynamic bloc) {
    Navigator.pop(context);

    /// Action can be called from branch screen too
    late final int threadId;
    if (currentTab is ThreadTab) {
      threadId = (currentTab as ThreadTab).id;
    } else if (currentTab is BranchTab) {
      /// This branch tab can be opened from another branch tab
      /// so we need to find thread tab
      DrawerTab tab = currentTab;
      while (tab is! ThreadTab) {
        tab = tab.prevTab!;
      }
      threadId = tab.id;
    }

    if (node.data.hidden) {
      HiddenPostsDatabase().removePost(
        currentTab.tag,
        threadId,
        node.data.id,
      );
      bloc.threadService.hiddenPosts.remove(node.data.id);
      setStateCallBack(() {
        node.data.hidden = false;
      });
      return;
    }
    HiddenPostsDatabase().addPost(
      currentTab.tag,
      threadId,
      node.data.id,
      node.data.comment,
    );
    bloc.threadService.hiddenPosts.add(node.data.id);
    setStateCallBack(() {
      node.data.hidden = true;
    });
  }

  Future<void> goToPost(TreeNode<Post> node, BuildContext context) async {
    final bloc = getBloc(context, currentTab);

    /// Check if this action was called in post preview dialog
    if (bloc.dialogStack.isNotEmpty) {
      final TreeNode<Post> visibleNode = bloc.dialogStack.first;

      Navigator.of(context).popUntil(ModalRoute.withName('/'));

      /// Find current root tree visible post belongs to.
      final TreeNode<Post> currentRoot = Tree.findRootNode(visibleNode);

      /// Check if desirable post is in the same tree as visible post.
      if (node == Tree.findNode([currentRoot], node.data.id)) {
        bloc.scrollService.scrollToParent(node, (currentTab as dynamic).id);
      } else {
        bloc.scrollService.scrollToNodeByPost(
          node.data,
          await bloc.threadService.getRoots(),
          (currentTab as dynamic).id,
        );
      }
    } else {
      Navigator.of(context).popUntil(ModalRoute.withName('/'));
      bloc.scrollService.scrollToNodeByPost(
        node.data,
        await bloc.threadService.getRoots(),
        (currentTab as dynamic).id,
      );
    }
  }

  Future<dynamic> showPostInfo(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Информация о посте'),
          content: SizedBox(
              // width: double.minPositive,
              child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Пост #${node.data.id}'),
              Text('Доска: ${node.data.board}'),
              Text('Автор: ${node.data.name}'),
              Text('Дата создания: ${node.data.date}'),
              Text('Порядковый номер: ${node.data.number}'),
              Text('Посты-родители: ${getParents(node)}'),
              Text('Ответы: ${getChildren(node)}'),
              Text(
                  'ОП: ${node.data.op || node.data.number == 1 ? 'да' : 'нет'}'),
              Text(
                  'e-mail: ${node.data.email.isEmpty ? 'нет' : node.data.email}'),
              SelectableText('Ссылка на пост: ${getPostLink(node)}'),
              IconButton(
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: getPostLink(node)));
                  },
                  icon: const Icon(Icons.copy))
            ],
          )),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ОК'))
          ],
        );
      },
    );
  }

  openPostInNewTab(BuildContext context) {
    /// context may not have [TabProvider] in [EndDrawer]

    context.read<PageProvider>().addTab(
          BranchTab(
            tag: currentTab.tag,
            id: node.data.id,
            name: 'Ответ: "${removeHtmlTags(node.data.comment, links: false)}"',
            prevTab: currentTab,
          ),
        );
    Navigator.pop(context);
  }
}

dynamic getBloc(BuildContext context, DrawerTab currentTab) {
  if (currentTab is ThreadTab) {
    return BlocProvider.of<ThreadBloc>(context);
  } else if (currentTab is BranchTab) {
    return BlocProvider.of<BranchBloc>(context);
  }
}

String getParents(TreeNode<Post> node) {
  List<int> parents = node.data.parents;
  if (parents.isEmpty) return 'нет';
  return parents.toString().replaceFirst('[', '').replaceFirst(']', '');
}

String getChildren(TreeNode<Post> node) {
  List<String> children =
      node.children.map((e) => e.data.id.toString()).toList();
  if (children.isEmpty) return 'нет';
  return children.toString().replaceFirst('[', '').replaceFirst(']', '');
}

String getPostLink(TreeNode<Post> node) {
  /// If parent = 0 then it is an OP-post => threadId equals to the post id
  int threadId = node.data.parent == 0 ? node.data.id : node.data.parent;
  String link =
      'https://2ch.hk/${node.data.board}/res/$threadId.html#${node.data.id}';
  return link;
}

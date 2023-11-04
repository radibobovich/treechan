import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:treechan/data/local/hidden_posts.database.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/presentation/bloc/thread_base.dart';
import 'package:treechan/utils/string.dart';
import '../../../domain/models/tab.dart';
import '../../../utils/remove_html.dart';
import '../../provider/page_provider.dart';

class ActionMenu extends StatelessWidget {
  final dynamic bloc;
  final DrawerTab currentTab;
  final TreeNode<Post> node;
  final Function setStateCallBack;
  final bool calledFromEndDrawer;
  const ActionMenu({
    super.key,
    required this.bloc,
    required this.currentTab,
    required this.node,
    required this.setStateCallBack,
    this.calledFromEndDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    // final bloc = currentTab.getBloc(context);
    debugPrint(
        'Post ${node.data.id} action menu opened, global key is ${node.getGlobalKey((currentTab as IdMixin).id)}, object key is ${node.key}');
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
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      bloc.shrinkBranch(node);
                    });
                  },
                )
              : const SizedBox.shrink(),
          node.parent != null
              ? ListTile(
                  title: const Text('Свернуть корневую ветку'),
                  visualDensity: const VisualDensity(vertical: -3),
                  onTap: () {
                    Navigator.pop(context);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      bloc.shrinkRootBranch(node);
                    });
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
      threadId = (currentTab as BranchTab)
          .getParentThreadTab()!
          .id; // DrawerTab tab = currentTab;
      // while (tab is! ThreadTab) {
      //   tab = (tab as BranchTab).prevTab;
      // }
      // threadId = tab.id;
    }

    if (node.data.hidden) {
      HiddenPostsDatabase().removePost(
        (currentTab as TagMixin).tag,
        threadId,
        node.data.id,
      );
      bloc.threadRepository.hiddenPosts.remove(node.data.id);
      setStateCallBack(() {
        node.data.hidden = false;
      });
      return;
    }
    HiddenPostsDatabase().addPost(
      (currentTab as TagMixin).tag,
      threadId,
      node.data.id,
      node.data.comment,
    );
    bloc.threadRepository.hiddenPosts.add(node.data.id);
    setStateCallBack(() {
      node.data.hidden = true;
    });
  }

  Future<void> goToPost(TreeNode<Post> node, BuildContext context) async {
    // ThreadBase bloc = currentTab.getBloc(context);
    (bloc as ThreadBase).goToPost(node, context: context);
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
              Text('Доска: ${node.data.boardTag}'),
              node.data.boardTag != 's'
                  ? Text('Автор: ${node.data.name}')
                  : Text('Автор: ${extractUserInfo(node.data.name)}'),
              Text('Дата создания: ${node.data.date}'),
              Text('Порядковый номер: ${node.data.number}'),
              Text('Посты-родители: ${getParents(node)}'),
              Text('Ответы: ${getChildren(node)}'),
              Text(
                  'ОП: ${node.data.op || node.data.number == 1 ? 'да' : 'нет'}'),
              Text(
                  'e-mail: ${node.data.email.isEmpty ? 'нет' : node.data.email}'),
              node.data.boardTag == 's'
                  ? Text(
                      'Устройство: ${extractUserInfo(node.data.name, mode: ExtractMode.info)}')
                  : const SizedBox.shrink(),
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
    final int threadId;
    if (currentTab is ThreadTab) {
      threadId = (currentTab as ThreadTab).id;
    } else if (currentTab is BranchTab) {
      threadId = (currentTab as BranchTab).threadId;
    } else {
      throw Exception('Unknown tab type');
    }
    context.read<PageProvider>().addTab(
          BranchTab(
            tag: (currentTab as TagMixin).tag,
            imageboard: currentTab.imageboard,
            id: node.data.id,
            threadId: threadId,
            name: 'Ответ: "${removeHtmlTags(node.data.comment, links: false)}"',
            prevTab: currentTab,
          ),
        );
    Navigator.pop(context);
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
      'https://2ch.hk/${node.data.boardTag}/res/$threadId.html#${node.data.id}';
  return link;
}

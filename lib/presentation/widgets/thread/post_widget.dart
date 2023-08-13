import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:share/share.dart';
import 'package:treechan/data/hidden_posts.database.dart';
import 'package:treechan/main.dart';
import 'package:treechan/domain/services/date_time_service.dart';
import 'package:treechan/utils/remove_html.dart';
import '../../../domain/models/json/json.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:pausable_timer/pausable_timer.dart';

import '../../../domain/models/tab.dart';
import '../../../domain/services/scroll_service.dart';
import '../../bloc/branch_bloc.dart';
import '../../bloc/thread_bloc.dart';
import '../../provider/page_provider.dart';
import '../shared/media_preview_widget.dart';
import '../shared/html_container_widget.dart';

class PostWidget extends StatefulWidget {
  final TreeNode<Post> node;
  final List<TreeNode<Post>> roots;
  final DrawerTab currentTab;
  final ScrollService? scrollService;

  const PostWidget({
    super.key,
    required this.node,
    required this.roots,
    required this.currentTab,
    this.scrollService,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> with TickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Color?> colorAnimation;

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    animationController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  PausableTimer? timer;

  @override
  Widget build(BuildContext context) {
    final Post post = widget.node.data;
    colorAnimation = ColorTween(
            begin: post.isHighlighted
                ? const Color.fromARGB(255, 255, 174, 0)
                : Theme.of(context).dividerColor,
            end: Theme.of(context).dividerColor)
        .animate(animationController);

    bool firstTimeSeen = true;
    return VisibilityDetector(
      key: Key(post.id.toString()),
      onVisibilityChanged: (visibilityInfo) {
        widget.scrollService?.checkVisibility(
          widget: widget,
          visibilityInfo: visibilityInfo,
          post: post,
        );
        handleHighlight(visibilityInfo, post, firstTimeSeen);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Card(
          child: InkWell(
            onTap: () async {
              widget.node.expanded = !widget.node.expanded;
              await Future.delayed(const Duration(milliseconds: 500));
            },
            onLongPress: () {
              openActionMenu(context, widget.currentTab, widget.node, setState);
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PostHeader(node: widget.node),
                  !widget.node.data.hidden
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(
                              thickness: 1,
                              color: colorAnimation.value,
                            ),
                            post.subject == ""
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text.rich(TextSpan(
                                      text: post.subject,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                                  ),
                            MediaPreview(files: post.files),
                            HtmlContainer(
                              post: post,
                              treeNode: widget.node,
                              roots: widget.roots,
                              currentTab: widget.currentTab,
                              scrollService: widget.scrollService,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Removes highlight after 15 seconds of a new post being seen
  void handleHighlight(
      VisibilityInfo visibilityInfo, Post post, bool firstTimeSeen) {
    if (visibilityInfo.visibleFraction == 1 && post.isHighlighted) {
      if (firstTimeSeen) {
        timer = PausableTimer(const Duration(seconds: 15), () {
          animationController.forward();
          post.isHighlighted = false;
        });
        timer?.start();
        firstTimeSeen = false;
      }
    } else if (visibilityInfo.visibleFraction < 1 && post.isHighlighted) {
      timer?.pause();
    }
  }
}

Future<dynamic> openActionMenu(BuildContext context, DrawerTab currentTab,
    TreeNode<Post> node, Function setStateCallback) {
  return showDialog(
      context: context,
      builder: (BuildContext bcontext) {
        if (currentTab is ThreadTab) {
          return BlocProvider.value(
            value: context.read<ThreadBloc>(),
            child: AlertDialog(
                contentPadding: const EdgeInsets.all(10),
                content: ActionMenu(
                  currentTab: currentTab,
                  node: node,
                  setStateCallBack: setStateCallback,
                )),
          );
        } else if (currentTab is BranchTab) {
          return BlocProvider.value(
            value: context.read<BranchBloc>(),
            child: AlertDialog(
                contentPadding: const EdgeInsets.all(10),
                content: ActionMenu(
                  currentTab: currentTab,
                  node: node,
                  setStateCallBack: setStateCallback,
                )),
          );
        } else {
          throw Exception(
              'Tried to open post preview with unsupported bloc type: ${currentTab.runtimeType.toString()}');
        }
      });
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({Key? key, required this.node}) : super(key: key);
  final TreeNode<Post> node;

  @override
  Widget build(BuildContext context) {
    Post post = node.data;
    final DateTimeService dateTimeSerivce =
        DateTimeService(timestamp: post.timestamp);

    return Padding(
      padding: node.hasNodes
          ? const EdgeInsets.fromLTRB(8, 2, 0, 0)
          : const EdgeInsets.fromLTRB(8, 2, 8, 0),
      child: Row(
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
          _isEnoughSpaceForDate()
              ? Text(" ${dateTimeSerivce.getAdaptiveDate()}",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall!.color))
              : const SizedBox.shrink(),
          const Spacer(),
          node.hasNodes
              ? IconButton(
                  iconSize: 20,
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(const Size(20, 20)),
                  icon: Icon(
                      node.expanded ? Icons.expand_more : Icons.chevron_right),
                  onPressed: () {
                    node.expanded = !node.expanded;
                  },
                )
              : const SizedBox(
                  //width: node.depth == 0 ? 0 : 30,
                  //width: 30,
                  width: 10)
        ],
      ),
    );
  }

  // don't show date for deep nodes to prevent overflow.
  // but show date in 2d scroll mode no matter how deep the node is.
  bool _isEnoughSpaceForDate() {
    return (node.depth % 16 <= 9 && node.depth % 16 != 0 ||
        node.depth == 0 ||
        prefs.getBool('2dscroll')!);
  }
}

class ActionMenu extends StatelessWidget {
  final DrawerTab currentTab;
  final TreeNode<Post> node;
  final Function setStateCallBack;

  const ActionMenu({
    super.key,
    required this.currentTab,
    required this.node,
    required this.setStateCallBack,
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
                  onTap: () {
                    /// context may not have [TabProvider] in [EndDrawer]

                    context.read<PageProvider>().addTab(
                          BranchTab(
                            tag: currentTab.tag,
                            id: node.data.id,
                            name:
                                'Ответ: "${removeHtmlTags(node.data.comment, links: false)}"',
                            prevTab: currentTab,
                          ),
                        );
                    Navigator.pop(context);
                  },
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
            onTap: () {
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
            },
          )
        ]));
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

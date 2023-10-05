import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/domain/services/url_service.dart';
import 'package:treechan/presentation/bloc/thread_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../main.dart';
import '../../bloc/branch_bloc.dart';
import '../../bloc/thread_base.dart';
import '../../provider/page_provider.dart';
import '../../../domain/models/tab.dart';
import '../../../domain/models/tree.dart';
import '../../../domain/services/scroll_service.dart';
import '../thread/post_widget.dart';

/// Represents greyed out text in post text.
class _SpoilerText extends StatefulWidget {
  final RenderContext node;
  final Widget children;
  const _SpoilerText({Key? key, required this.node, required this.children})
      : super(key: key);

  @override
  _SpoilerTextState createState() => _SpoilerTextState();
}

class _SpoilerTextState extends State<_SpoilerText> {
  bool spoilerVisibility = false;

  @override
  void initState() {
    super.initState();
  }

  void toggleVisibility() {
    setState(() {
      spoilerVisibility = !spoilerVisibility;
    });
  }

  @override
  Widget build(BuildContext context) {
    final newContainerSpan = ContainerSpan(
        style: Style(
          lineHeight: const LineHeight(1),
          backgroundColor: Colors.grey[600],
        ),
        newContext: widget.node,
        children: [
          TextSpan(
              text: widget.node.tree.element!.text,
              style: TextStyle(color: Colors.grey[600]))
        ]);
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
            onTap: () => toggleVisibility(),
            child: spoilerVisibility ? widget.children : newContainerSpan
            // : Text(
            //     widget.node.tree.element!.text,
            //     style: TextStyle(
            //       backgroundColor: Colors.grey[600],
            //       color: Colors.grey[600],
            //       fontSize: 14.5,
            //     ),
            //   ),
            );
      },
    );
  }
}

/// Represents post text.
/// Extracted from PostWidget because of a large onLinkTap function.
class HtmlContainer extends StatelessWidget {
  const HtmlContainer(
      {Key? key,
      required this.bloc,
      required this.post,
      required this.currentTab,
      this.treeNode,
      this.roots,
      this.scrollService})
      : super(key: key);
  // data can be Post or Thread object
  final ThreadBase? bloc;
  final Post post;
  final TreeNode<Post>? treeNode;
  final List<TreeNode<Post>>? roots;
  final DrawerTab currentTab;

  final ScrollService? scrollService;
  @override
  Widget build(BuildContext context) {
    // Wrapped in ExcludeSemantics because of AssertError exception in debug mode
    return ExcludeSemantics(
      child: Html(
        // limit text on BoardScreen
        style: currentTab is BoardTab
            ? {'#': Style(maxLines: 15, textOverflow: TextOverflow.ellipsis)}
            : {},
        data: post.comment,
        customRender: {
          "span": (node, children) {
            List<String> spanClasses = node.tree.elementClasses;
            if (spanClasses.contains("unkfunc")) {
              // greentext cite
              return TextSpan(
                  style:
                      const TextStyle(color: Color.fromARGB(255, 120, 153, 34)),
                  text: node.tree.element!.text);
            } else if (spanClasses.contains("spoiler")) {
              if (prefs.getBool('spoilers') == true) {
                return _SpoilerText(node: node, children: children);
              }
            } else if (spanClasses.contains("s")) {
              return TextSpan(
                  text: node.tree.element!.text,
                  style:
                      const TextStyle(decoration: TextDecoration.lineThrough));
            } else {
              return children;
            }
          },
          "a": (node, children) {
            return GestureDetector(
              onTap: () => openLink(node, context, bloc),
              child: Text(
                // custom link color render
                style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    decoration: TextDecoration.underline,
                    // highlight current parent in the post text if
                    // there are multiple parents
                    fontWeight: (treeNode != null &&
                            post.aTagsCount > 1 &&
                            treeNode!.parent != null &&
                            node.tree.element!.text
                                .contains('>>${treeNode!.parent!.data.id}'))
                        ? FontWeight.bold
                        : FontWeight.normal),
                node.tree.element!.text,
              ),
            );
          },
        },
      ),
    );
  }

  void openLink(RenderContext node, BuildContext context, ThreadBase? bloc) {
    assert(bloc != null || currentTab is BoardTab,
        'You should pass bloc while opening link from thread or branch screen');
    String url = node.tree.element!.attributes['href']!;
    String? searchTag = node.tree.element!.attributes['title'];
    // check if link points to some post in thread
    if (currentTab is! BoardTab &&
        (isReplyLinkInCurrentTab(url, currentTab) ||
            isReplyLinkToParentThreadTab(url, currentTab as IdMixin))) {
      // get post id placed after # symbol
      int id = int.parse(url.substring(url.indexOf("#") + 1));
      if (roots != null && roots!.isNotEmpty && treeNode != null) {
        openPostPreview(context, id, bloc!);
      }

      // check if link is external relative to this thread
    } else {
      UrlService searchBarService = UrlService(currentTab: currentTab);
      try {
        final newTab = searchBarService.parseInput(url, searchTag: searchTag);
        if (newTab is BoardTab && newTab.isCatalog == true) {
          context
              .read<PageProvider>()
              .openCatalog(boardTag: newTab.tag, query: newTab.query ?? '');
        } else {
          context.read<PageProvider>().addTab(newTab);
        }
      } catch (e) {
        tryLaunchUrl(url);
      }
    }
  }

  /// Check if the link points to the post that is presented in a current tab.
  bool isReplyLinkInCurrentTab(String url, DrawerTab currentTab) {
    if (currentTab is! ThreadTab) return false;
    return url.contains("/${currentTab.tag}/res/${currentTab.id}.html#");
  }

  /// Reply links at [BranchScreen] may point to a post that is not in the
  /// current branch. So we need to check if it is a reply to a post
  /// that is in the parent [ThreadScreen].
  bool isReplyLinkToParentThreadTab(String url, IdMixin currentTab) {
    if (currentTab is! BranchTab) return false;

    IdMixin tab = currentTab;

    /// go to threadTab parent (branch can be opened from previous branch
    /// so we can't just use tab.prevTab)
    while (tab is! ThreadTab) {
      tab = tab.prevTab as IdMixin;
    }

    return url.contains("/${tab.tag}/res/${tab.id}.html#");
  }

  Future<void> openPostPreview(
      BuildContext context, int id, ThreadBase bloc) async {
    // final ThreadBase bloc = currentTab.getBloc(context);
    showDialog(
        context: context,
        builder: (_) {
          if (currentTab is ThreadTab) {
            bloc.dialogStack.add(treeNode!);

            return BlocProvider.value(
              value: bloc as ThreadBloc,
              child: PostPreviewDialog(

                  /// if link points to the parent post, then pass parent post
                  /// in other cases pass null and it will perform search
                  /// based on the post id
                  node: (treeNode!.parent != null &&
                          id == treeNode!.parent!.data.id)
                      ? treeNode!.parent
                      : null,
                  bloc: bloc,
                  roots: roots ?? [],
                  nodeFinder: bloc.threadRepository.nodesAt,
                  id: id,
                  currentTab: currentTab,
                  scrollService: scrollService),
            );
          } else if (currentTab is BranchTab) {
            bloc.dialogStack.add(treeNode!);

            return BlocProvider.value(
                value: bloc as BranchBloc,
                child: PostPreviewDialog(
                    bloc: bloc,
                    node: (treeNode!.parent != null &&
                            id == treeNode!.parent!.data.id)
                        ? treeNode!.parent
                        : null,
                    roots: roots ?? bloc.threadRepository.getRootsSynchronously,
                    nodeFinder: bloc.threadRepository.nodesAt,
                    id: id,
                    currentTab: currentTab,
                    scrollService: scrollService));
          } else {
            throw Exception(
                'Tried to open post preview with unsupported bloc type: ${currentTab.runtimeType.toString()}');
          }
        }).then((value) => bloc.dialogStack.remove(treeNode));
  }
}

class PostPreviewDialog extends StatelessWidget {
  const PostPreviewDialog(
      {required this.bloc,
      required this.roots,
      required this.currentTab,
      required this.scrollService,
      super.key,
      this.node,
      this.id,
      this.nodeFinder})
      : assert(node != null || id != null, 'node or id must be not null');
  final ThreadBase bloc;
  final TreeNode<Post>? node;
  final List<TreeNode<Post>> roots;
  final int? id;
  final DrawerTab currentTab;
  final ScrollService? scrollService;
  final Function? nodeFinder;
  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        PostWidget(
          bloc: bloc,
          node: node ??
              ((nodeFinder != null)
                  ? nodeFinder!(id).first
                  : Tree.findNode(roots, id!)!),
          roots: roots,
          currentTab: currentTab,
          scrollService: scrollService,
          trackVisibility: false,
        )
      ]),
    ));
  }
}

Future<void> tryLaunchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}

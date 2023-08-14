import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:treechan/domain/services/search_bar_service.dart';
import 'package:treechan/presentation/widgets/thread/action_menu_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../main.dart';
import '../../bloc/board_bloc.dart';
import '../../../domain/models/json/json.dart';
import '../../bloc/branch_bloc.dart';
import '../../bloc/thread_bloc.dart';
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
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () => toggleVisibility(),
          child: spoilerVisibility
              ? widget.children
              : Text(
                  widget.node.tree.element!.text,
                  style: TextStyle(
                    backgroundColor: Colors.grey[600],
                    color: Colors.grey[600],
                    fontSize: 14.5,
                  ),
                ),
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
      required this.post,
      required this.currentTab,
      this.treeNode,
      this.roots,
      this.scrollService})
      : super(key: key);
  // data can be Post or Thread object
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
              onTap: () => openLink(node, context),
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

  void openLink(RenderContext node, BuildContext context) {
    String url = node.tree.element!.attributes['href']!;
    String? searchTag = node.tree.element!.attributes['title'];
    // check if link points to some post in thread
    if (currentTab is ThreadTab &&
        url.contains(
            "/${currentTab.tag}/res/${(currentTab as ThreadTab).id}.html#")) {
      // get post id placed after # symbol
      int id = int.parse(url.substring(url.indexOf("#") + 1));
      if (roots != null &&
          roots!.isNotEmpty &&
          Tree.findNode(roots!, id) == null) {
        return;
      }
      openPostPreview(context, id);

      // check if link is external relative to this thread
    } else {
      SearchBarService searchBarService =
          SearchBarService(currentTab: currentTab);
      try {
        final newTab = searchBarService.parseInput(url, searchTag: searchTag);
        if (newTab is BoardTab && newTab.isCatalog == true) {
          if (currentTab is BoardTab) {
            context
                .read<BoardBloc>()
                .add(ChangeViewBoardEvent(null, query: newTab.query));
          } else if (currentTab is ThreadTab) {
            context
                .read<PageProvider>()
                .openCatalog(boardTag: newTab.tag, query: newTab.query!);
          }
        } else {
          context.read<PageProvider>().addTab(newTab);
        }
      } catch (e) {
        tryLaunchUrl(url);
      }
    }
  }

  Future<void> openPostPreview(BuildContext context, int id) async {
    showDialog(
        context: context,
        builder: (_) {
          if (currentTab is ThreadTab) {
            context.read<ThreadBloc>().dialogStack.add(treeNode!);
            return BlocProvider.value(
              value: context.read<ThreadBloc>(),
              child: PostPreviewDialog(
                  roots: roots,
                  id: id,
                  currentTab: currentTab,
                  scrollService: scrollService),
            );
          } else if (currentTab is BranchTab) {
            context.read<BranchBloc>().dialogStack.add(treeNode!);
            return BlocProvider.value(
                value: context.read<BranchBloc>(),
                child: PostPreviewDialog(
                    roots: roots,
                    id: id,
                    currentTab: currentTab,
                    scrollService: scrollService));
          } else {
            throw Exception(
                'Tried to open post preview with unsupported bloc type: ${currentTab.runtimeType.toString()}');
          }
        }).then((value) => getBloc(context, currentTab).dialogStack.remove(id));
  }
}

class PostPreviewDialog extends StatelessWidget {
  const PostPreviewDialog({
    super.key,
    required this.roots,
    required this.id,
    required this.currentTab,
    required this.scrollService,
  });

  final List<TreeNode<Post>>? roots;
  final int id;
  final DrawerTab currentTab;
  final ScrollService? scrollService;

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // TODO: optimization: dont call findNode twice (first time in Html onTap)
        PostWidget(
          // node: roots != null && roots!.isNotEmpty
          //     ? Tree.findNode(roots!, id)!
          //     : getMockNode(id, context, currentTab),
          node: Tree.findNode(roots!, id)!,
          roots: roots != null ? roots! : [],
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

/// Used in [EndDrawer]
// TreeNode<Post> getMockNode(int id, BuildContext context, DrawerTab currentTab) {
//   final List<Post> posts;
//   if (currentTab is ThreadTab) {
//     // posts = (bloc as ThreadBloc).threadService.getPosts;
//     posts = context.read<ThreadBloc>().threadService.getPosts;
//   } else {
//     // posts = (bloc as BranchBloc).threadService.getPosts;
//     posts = context.read<BranchBloc>().threadService.getPosts;
//   }
//   final Post post = posts.firstWhere((element) => element.id == id);
//   return TreeNode(data: post);
// }

int countATags(String text) {
  int count = 0;
  int index = 0;
  String substring = 'class="post-reply-link"';
  while (index < text.length) {
    index = text.indexOf(substring, index);
    if (index == -1) {
      break;
    }
    count++;
    index += substring.length;
  }
  return count;
}

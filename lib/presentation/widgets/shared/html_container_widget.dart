import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:treechan/domain/services/search_bar_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/parser.dart' as html;

import '../../../utils/constants/enums.dart';
import '../../bloc/board_bloc.dart';
import '../../../domain/models/json/json.dart';
import '../../provider/tab_provider.dart';
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
  bool _spoilerVisibility = false;

  @override
  void initState() {
    _spoilerVisibility = false;
    super.initState();
  }

  void toggleVisibility() {
    setState(() {
      _spoilerVisibility = !_spoilerVisibility;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () => toggleVisibility(),
          child: _spoilerVisibility
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
class HtmlContainer extends StatefulWidget {
  const HtmlContainer(
      {Key? key,
      required this.post,
      this.treeNode,
      this.roots,
      required this.currentTab,
      this.scrollService})
      : super(key: key);
  // data can be Post or Thread object
  final Post post;
  final TreeNode<Post>? treeNode;
  final List<TreeNode<Post>>? roots;
  final DrawerTab currentTab;

  final ScrollService? scrollService;
  @override
  State<HtmlContainer> createState() => _HtmlContainerState();
}

class _HtmlContainerState extends State<HtmlContainer> {
  @override
  Widget build(BuildContext context) {
    // Wrapped in ExcludeSemantics because of AssertError exception in debug mode
    return ExcludeSemantics(
      child: Html(
        // limit text on BoardScreen
        style: widget.currentTab.type == TabTypes.thread
            ? {}
            : {'#': Style(maxLines: 15, textOverflow: TextOverflow.ellipsis)},
        data: widget.post.comment,
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
              return _SpoilerText(node: node, children: children);
            }
          },
          "a": (node, children) {
            if (widget.post.id == 7610120) {
              debugPrint('gotcha');
            }
            return TextSpan(
                // custom link color render
                style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    decoration: TextDecoration.underline,
                    // highlight current parent in the post text if
                    // there are multiple parents
                    fontWeight: (widget.treeNode != null &&
                            countATags(widget.post.comment) > 1 &&
                            node.tree.element!.text.contains(
                                '>>${widget.treeNode!.parent!.data.id}'))
                        ? FontWeight.bold
                        : FontWeight.normal),
                text: node.tree.element!.text,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => openLink(node));
          },
        },
      ),
    );
  }

  void openLink(RenderContext node) {
    String url = node.tree.element!.attributes['href']!;
    String? searchTag = node.tree.element!.attributes['title'];
    // check if link points to some post in thread
    if (widget.currentTab.type == TabTypes.thread &&
        url.contains(
            "/${widget.currentTab.tag}/res/${widget.currentTab.id}.html#")) {
      // get post id placed after # symbol
      int id = int.parse(url.substring(url.indexOf("#") + 1));
      if (Tree.findPost(widget.roots!, id) == null) {
        return;
      }
      openPostPreview(context, id);

      // check if link is external relative to this thread
    } else {
      SearchBarService searchBarService =
          SearchBarService(currentTab: widget.currentTab);
      try {
        DrawerTab newTab =
            searchBarService.parseInput(url, searchTag: searchTag);
        if (newTab.isCatalog != null) {
          if (widget.currentTab.type == TabTypes.board) {
            context
                .read<BoardBloc>()
                .add(ChangeViewBoardEvent(null, searchTag: newTab.searchTag));
          } else if (widget.currentTab.type == TabTypes.thread) {
            context.read<TabProvider>().openCatalog(
                boardTag: newTab.tag, searchTag: newTab.searchTag!);
          }
        } else {
          context.read<TabProvider>().addTab(newTab);
        }
      } catch (e) {
        tryLaunchUrl(url);
      }
    }
  }

  Future<dynamic> openPostPreview(BuildContext context, int id) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              PostWidget(
                node: Tree.findPost(widget.roots!, id)!,
                roots: widget.roots!,
                currentTab: widget.currentTab,
                scrollService: widget.scrollService,
              )
            ]),
          ));
        });
  }

  Future<void> tryLaunchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}

int countATags(String text) {
  final document = html.parse(text);
  final tags = document.getElementsByTagName('a');
  int count = 0;
  for (var tag in tags) {
    if (tag.className == 'post-reply-link') {
      count += 1;
    }
  }
  return count;
}

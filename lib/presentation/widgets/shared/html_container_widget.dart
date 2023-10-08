import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:treechan/domain/imageboards/imageboard_specific.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/main.dart';
import 'package:treechan/presentation/bloc/thread_bloc.dart';

import '../../bloc/branch_bloc.dart';
import '../../bloc/thread_base.dart';
import '../../../domain/models/tab.dart';
import '../../../domain/models/tree.dart';
import '../../../domain/services/scroll_service.dart';
import '../thread/post_widget.dart';

/// Represents greyed out text in post text.
class SpoilerText extends StatefulWidget {
  final RenderContext node;
  final Widget children;
  const SpoilerText({Key? key, required this.node, required this.children})
      : super(key: key);

  @override
  State<SpoilerText> createState() => _SpoilerTextState();
}

class _SpoilerTextState extends State<SpoilerText> {
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
      this.scrollService})
      : super(key: key);
  final ThreadBase? bloc;
  final Post post;
  final TreeNode<Post>? treeNode;
  final DrawerTab currentTab;

  final ScrollService? scrollService;
  @override
  Widget build(BuildContext context) {
    assert(bloc != null || currentTab is BoardTab,
        'You should pass bloc while using HtmlContainer, else you can not open post previews');

    // Wrapped in ExcludeSemantics because of AssertError exception in debug mode
    return ExcludeSemantics(
      child: Html(
        // limit text on BoardScreen
        style: currentTab is BoardTab
            ? {'#': Style(maxLines: 15, textOverflow: TextOverflow.ellipsis)}
            : {},
        data: post.comment,
        customRender: {
          "span": (node, children) => ImageboardSpecific(currentTab.imageboard)
              .spanCustomRender(node, children, prefs: prefs),
          "a": (node, children) =>
              ImageboardSpecific(currentTab.imageboard).linkCustomRender(
                node,
                children,
                context: context,
                treeNode: treeNode,
                post: post,
                bloc: bloc,
                currentTab: currentTab,
              ),
          // (node, children) {
          //   return GestureDetector(
          //     onTap: () => openLink(node, context, bloc),
          //     child: Text(
          //       // custom link color render
          //       style: TextStyle(
          //           color: Theme.of(context).secondaryHeaderColor,
          //           decoration: TextDecoration.underline,
          //           // highlight current parent in the post text if
          //           // there are multiple parents
          //           fontWeight: (treeNode != null &&
          //                   post.aTagsCount > 1 &&
          //                   treeNode!.parent != null &&
          //                   node.tree.element!.text
          //                       .contains('>>${treeNode!.parent!.data.id}'))
          //               ? FontWeight.bold
          //               : FontWeight.normal),
          //       node.tree.element!.text,
          //     ),
          //   );
          // },
        },
      ),
    );
  }
}

Future<void> openPostPreview(
  BuildContext context,
  int id,
  ThreadBase bloc, {
  required DrawerTab currentTab,
  required TreeNode<Post> treeNode,
}) async {
  showDialog(
      context: context,
      builder: (_) {
        if (currentTab is ThreadTab) {
          bloc.dialogStack.add(treeNode);

          return BlocProvider.value(
            value: bloc as ThreadBloc,
            child: PostPreviewDialog(

                /// if link points to the parent post, then pass parent post
                /// in other cases pass null and it will perform search
                /// based on the post id
                node:
                    (treeNode.parent != null && id == treeNode.parent!.data.id)
                        ? treeNode.parent
                        : null,
                bloc: bloc,
                roots: bloc.threadRepository.getRootsSynchronously,
                nodeFinder: bloc.threadRepository.nodesAt,
                id: id,
                currentTab: currentTab,
                scrollService: bloc.scrollService),
          );
        } else if (currentTab is BranchTab) {
          bloc.dialogStack.add(treeNode);

          return BlocProvider.value(
              value: bloc as BranchBloc,
              child: PostPreviewDialog(
                  bloc: bloc,
                  node: (treeNode.parent != null &&
                          id == treeNode.parent!.data.id)
                      ? treeNode.parent
                      : null,
                  roots: bloc.threadRepository.getRootsSynchronously,
                  nodeFinder: bloc.threadRepository.nodesAt,
                  id: id,
                  currentTab: currentTab,
                  scrollService: bloc.scrollService));
        } else {
          throw Exception(
              'Tried to open post preview with unsupported bloc type: ${currentTab.runtimeType.toString()}');
        }
      }).then((value) => bloc.dialogStack.remove(treeNode));
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

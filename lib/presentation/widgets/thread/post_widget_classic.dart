import 'package:flutter/material.dart';
import 'package:treechan/config/themes.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/domain/models/tab.dart';
import 'package:treechan/domain/services/scroll_service.dart';
import 'package:treechan/presentation/bloc/thread_base.dart';
import 'package:treechan/presentation/widgets/board/thread_card.dart';
import 'package:treechan/presentation/widgets/shared/html_container_widget.dart';
import 'package:treechan/presentation/widgets/shared/media_preview_widget.dart';

class PostWidgetClassic extends StatefulWidget {
  final Post post;
  final ThreadBase bloc;
  final DrawerTab currentTab;
  final bool trackVisibility;
  final ScrollService? scrollService;

  const PostWidgetClassic({
    super.key,
    required this.post,
    required this.bloc,
    required this.currentTab,
    this.trackVisibility = true,
    this.scrollService,
  });

  @override
  State<PostWidgetClassic> createState() => _PostWidgetClassicState();
}

class _PostWidgetClassicState extends State<PostWidgetClassic> {
  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// headers + image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// subject, name, date, id
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      post.files == null
                          ? const SizedBox.shrink()
                          : const SizedBox.square(dimension: 8),
                      post.subject.isEmpty
                          ? const SizedBox.shrink()
                          : Text(post.subject,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                      CardHeader(post: post),

                      /// Post id
                      Row(children: [
                        Text(post.id.toString(),
                            style: TextStyle(
                                color:
                                    context.theme.textTheme.bodySmall?.color))
                      ])
                    ],
                  ),
                ),
                MediaPreview(
                  files: post.files,
                  imageboard: widget.currentTab.imageboard,
                  height: 70,
                  classicPreview: true,
                )
              ],
            ),
          ),
          HtmlContainer(
            bloc: widget.bloc,
            post: post,
            currentTab: widget.currentTab,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: InkWell(child: Text(post.children.length.toString())),
          )
        ],
      ),
    );
  }
}

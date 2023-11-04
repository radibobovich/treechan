import "package:flutter/material.dart";
import 'package:treechan/data/local/hidden_threads_database.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/presentation/widgets/board/thread_card.dart';

import '../../../domain/models/tab.dart';
import '../shared/html_container_widget.dart';
import '../shared/media_preview_widget.dart';

/// Classic version of thread card. Has only one image in preview.
class ThreadCardClassic extends StatefulWidget {
  final Thread thread;
  final BoardTab currentTab;
  const ThreadCardClassic(
      {Key? key, required this.thread, required this.currentTab})
      : super(key: key);

  @override
  State<ThreadCardClassic> createState() => _ThreadCardClassicState();
}

class _ThreadCardClassicState extends State<ThreadCardClassic> {
  @override
  Widget build(BuildContext context) {
    final post = widget.thread.posts.first;
    return Card(
      margin: const EdgeInsets.all(2),
      child: InkWell(
        onTap: widget.thread.hidden
            ? () {
                HiddenThreadsDatabase()
                    .removeThread(widget.currentTab.tag, post.id);

                setState(() {
                  widget.thread.hidden = false;
                });
              }
            : () => openThread(context, widget.thread, widget.currentTab),
        child: widget.thread.hidden
            ? Row(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Text(post.subject,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Title, header, media
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 80),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 5, 0, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(post.subject,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  const Spacer(),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 4, 4, 0),
                                    child: CardHeader(
                                        thread: widget.thread, greyName: true),
                                  ),
                                ],
                              ),
                            ),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: HtmlContainer(
                        bloc: null,
                        post: post,
                        currentTab: widget.currentTab,
                        // onOpenCatalog: onOpenCatalog,
                      ),
                    ),
                    CardFooter(
                      thread: widget.thread,
                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 4),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

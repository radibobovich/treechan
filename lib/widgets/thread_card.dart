import "package:flutter/material.dart";

import '../models/json/json.dart';
import "../screens/tab_navigator.dart";
import "html_container_widget.dart";
import "media_preview_widget.dart";

// Represents thread in list of threads
class ThreadCard extends StatelessWidget {
  final Thread? thread;
  final DrawerTab currentTab;
  final Function onOpen;
  final Function onGoBack;

  const ThreadCard({
    Key? key,
    required this.thread,
    required this.currentTab,
    required this.onOpen,
    required this.onGoBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: openThread,
      child: Card(
        margin: const EdgeInsets.all(2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 16),
                    child: _CardHeader(thread: thread),
                  ),
                  Text.rich(TextSpan(
                    text: thread!.subject,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
                ],
              ),
            ),
            ImagesPreview(files: thread!.files),
            HtmlContainer(
              post: thread!,
              currentTab: currentTab,
              onOpen: onOpen,
              onGoBack: onGoBack,
            ),
            _CardFooter(thread: thread)
          ],
        ),
      ),
    );
  }

  void openThread() {
    onOpen(DrawerTab(
        type: TabTypes.thread,
        id: thread!.num_,
        tag: thread!.board!,
        name: thread!.subject!,
        prevTab: currentTab));
  }
}

// contains username and date
class _CardHeader extends StatelessWidget {
  const _CardHeader({
    Key? key,
    required this.thread,
  }) : super(key: key);

  final Thread? thread;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(thread?.name ?? "No author"),
        const Spacer(),
        Text(thread?.date ?? "a long time ago"),
      ],
    );
  }
}

class _CardFooter extends StatelessWidget {
  const _CardFooter({
    Key? key,
    required this.thread,
  }) : super(key: key);

  final Thread? thread;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(
          thickness: 1,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
          child: Row(
            children: [
              const Icon(Icons.question_answer, size: 20),
              Text(thread?.postsCount.toString() ?? "count"),
              const Spacer(),
            ],
          ),
        )
      ],
    );
  }
}

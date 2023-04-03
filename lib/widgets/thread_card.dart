import "package:flutter/material.dart";

import "../models/board_json.dart";
import "../screens/tab_navigator.dart";
import "html_container_widget.dart";
import "media_preview_widget.dart";

// Represents thread in list of threads
class ThreadCard extends StatelessWidget {
  final Thread? thread;
  final Function onOpen;
  final Function onGoBack;

  final String boardName;
  final String boardTag;
  const ThreadCard(
      {Key? key,
      required this.thread,
      required this.onOpen,
      required this.onGoBack,
      required this.boardName,
      required this.boardTag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        DrawerTab currentTab =
            DrawerTab(type: TabTypes.board, tag: boardTag, name: boardName);
        onOpen(DrawerTab(
            type: TabTypes.thread,
            id: thread!.num_,
            tag: thread!.board!,
            name: thread!.subject!,
            prevTab: currentTab));
      },
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
                    child: CardHeader(thread: thread),
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
              isCalledFromThread: false,
              onOpen: onOpen,
              onGoBack: onGoBack,
            ),
            CardFooter(thread: thread)
          ],
        ),
      ),
    );
  }
}

// contains username and date
class CardHeader extends StatelessWidget {
  const CardHeader({
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

class CardFooter extends StatelessWidget {
  const CardFooter({
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

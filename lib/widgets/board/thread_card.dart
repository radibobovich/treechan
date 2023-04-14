import "package:flutter/material.dart";
import 'package:treechan/services/date_time_service.dart';

import '../../models/json/json.dart';
import '../../screens/tab_navigator.dart';
import '../shared/html_container_widget.dart';
import '../shared/media_preview_widget.dart';

// Represents thread in list of threads
class ThreadCard extends StatelessWidget {
  final Thread? thread;
  final DrawerTab currentTab;
  final Function onOpen;
  final Function onGoBack;
  final Function onOpenCatalog;
  const ThreadCard({
    Key? key,
    required this.thread,
    required this.currentTab,
    required this.onOpen,
    required this.onGoBack,
    required this.onOpenCatalog,
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
                    text: thread!.posts[0].subject,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
                ],
              ),
            ),
            MediaPreview(files: thread!.posts[0].files),
            HtmlContainer(
              post: thread!.posts[0],
              currentTab: currentTab,
              onOpen: onOpen,
              onGoBack: onGoBack,
              onOpenCatalog: onOpenCatalog,
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
        id: thread!.posts[0].id,
        tag: thread!.posts[0].board!,
        name: thread!.posts[0].subject!,
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
    DateTimeService dateTimeSerivce =
        DateTimeService(dateRaw: thread!.posts[0].date!);
    return Row(
      children: [
        Text(thread?.posts[0].name ?? "No author"),
        const Spacer(),
        Text(dateTimeSerivce.getAdaptiveDate(),
            style:
                TextStyle(color: Theme.of(context).textTheme.bodySmall!.color))
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

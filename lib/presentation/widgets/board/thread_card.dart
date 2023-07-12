import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:treechan/presentation/provider/tab_provider.dart';
import 'package:treechan/domain/services/date_time_service.dart';

import '../../../utils/constants/enums.dart';
import '../../../domain/models/json/json.dart';
import '../../../domain/models/tab.dart';
import '../shared/html_container_widget.dart';
import '../shared/media_preview_widget.dart';

// Represents thread in list of threads
class ThreadCard extends StatelessWidget {
  final Thread? thread;
  final DrawerTab currentTab;
  const ThreadCard({
    Key? key,
    required this.thread,
    required this.currentTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(2),
      child: InkWell(
        onTap: () => openThread(context),
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
              // onOpenCatalog: onOpenCatalog,
            ),
            _CardFooter(thread: thread)
          ],
        ),
      ),
    );
  }

  void openThread(BuildContext context) {
    context.read<TabProvider>().addTab(DrawerTab(
        type: TabTypes.thread,
        id: thread!.posts[0].id,
        tag: thread!.posts[0].board,
        name: thread!.posts[0].subject,
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
        DateTimeService(timestamp: thread!.posts[0].timestamp);
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

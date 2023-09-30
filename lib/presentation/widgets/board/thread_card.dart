import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:treechan/data/local/hidden_threads_database.dart';
import 'package:treechan/di/injection.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/presentation/provider/page_provider.dart';
import 'package:treechan/domain/services/date_time_service.dart';
import 'package:treechan/presentation/widgets/shared/user_platform_icons.dart';
import 'package:treechan/utils/constants/dev.dart';
import 'package:treechan/utils/string.dart';

import '../../../domain/models/tab.dart';
import '../shared/html_container_widget.dart';
import '../shared/media_preview_widget.dart';

// Represents thread in list of threads
class ThreadCard extends StatefulWidget {
  final Thread thread;
  final BoardTab currentTab;
  const ThreadCard({
    Key? key,
    required this.thread,
    required this.currentTab,
  }) : super(key: key);

  @override
  State<ThreadCard> createState() => _ThreadCardState();
}

class _ThreadCardState extends State<ThreadCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(2),
      child: InkWell(
        onTap: widget.thread.hidden
            ? () {
                HiddenThreadsDatabase().removeThread(
                    widget.currentTab.tag, widget.thread.posts.first.id);

                setState(() {
                  widget.thread.hidden = false;
                });
              }
            : () => openThread(context),
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
                    child: _CardHeader(thread: widget.thread),
                  ),
                  Text.rich(TextSpan(
                    text: widget.thread.posts.first.subject,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
                ],
              ),
            ),
            widget.thread.hidden
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MediaPreview(files: widget.thread.posts.first.files),
                      HtmlContainer(
                        post: widget.thread.posts.first,
                        currentTab: widget.currentTab,
                        // onOpenCatalog: onOpenCatalog,
                      ),
                      _CardFooter(thread: widget.thread),
                    ],
                  )
          ],
        ),
      ),
    );
  }

  void openThread(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    context.read<PageProvider>().addTab(ThreadTab(
        id: env == Env.prod ? widget.thread.posts.first.id : debugThreadId,
        tag: env == Env.prod
            ? widget.thread.posts.first.boardTag
            : debugBoardTag,
        name: widget.thread.posts.first.subject,
        prevTab: widget.currentTab));
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
        DateTimeService(timestamp: thread!.posts.first.timestamp);
    return Row(
      children: [
        thread!.posts.first.boardTag != 's'
            ? Text(thread?.posts.first.name ?? "No author")
            : Text(extractUserInfo(thread!.posts.first.name)),
        thread!.posts.first.boardTag == 's'
            ? UserPlatformIcons(userName: thread!.posts.first.name)
            : const SizedBox.shrink(),
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
              Text(thread?.posts.length.toString() ?? "count"),
              const Spacer(),
            ],
          ),
        )
      ],
    );
  }
}

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
  const ThreadCard({Key? key, required this.thread, required this.currentTab})
      : super(key: key);

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
            : () => openThread(context, widget.thread, widget.currentTab),
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
                    child: CardHeader(thread: widget.thread),
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
                      MediaPreview(
                        files: widget.thread.posts.first.files,
                        imageboard: widget.currentTab.imageboard,
                      ),
                      HtmlContainer(
                        bloc: null,
                        post: widget.thread.posts.first,
                        currentTab: widget.currentTab,
                        // onOpenCatalog: onOpenCatalog,
                      ),
                      CardFooter(thread: widget.thread),
                    ],
                  )
          ],
        ),
      ),
    );
  }
}

void openThread(BuildContext context, Thread thread, BoardTab currentTab) {
  FocusManager.instance.primaryFocus?.unfocus();
  context.read<PageProvider>().addTab(ThreadTab(
      imageboard: thread.imageboard,
      id: env == Env.prod ? thread.posts.first.id : debugThreadId,
      tag: env == Env.prod ? thread.posts.first.boardTag : debugBoardTag,
      name: thread.posts.first.subject,
      prevTab: currentTab));
}

// contains username and date
class CardHeader extends StatelessWidget {
  const CardHeader({
    Key? key,
    required this.thread,
    this.greyName = false,
  }) : super(key: key);
  final bool greyName;
  final Thread thread;
  @override
  Widget build(BuildContext context) {
    final nameStyle = greyName
        ? TextStyle(color: Theme.of(context).textTheme.bodySmall!.color)
        : null;
    DateTimeService dateTimeSerivce =
        DateTimeService(timestamp: thread.posts.first.timestamp);
    return Row(
      children: [
        /// name
        thread.posts.first.boardTag != 's'
            ? Text(thread.posts.first.name, style: nameStyle)
            : Text(extractUserInfo(thread.posts.first.name), style: nameStyle),

        /// device icons
        thread.posts.first.boardTag == 's'
            ? UserPlatformIcons(userName: thread.posts.first.name)
            : const SizedBox.shrink(),
        const Spacer(),

        /// date
        Text(dateTimeSerivce.getAdaptiveDate(),
            style:
                TextStyle(color: Theme.of(context).textTheme.bodySmall!.color))
      ],
    );
  }
}

class CardFooter extends StatelessWidget {
  const CardFooter({
    Key? key,
    required this.thread,
    this.padding = const EdgeInsets.fromLTRB(8, 4, 8, 12),
  }) : super(key: key);

  final Thread thread;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(
          thickness: 1,
        ),
        Padding(
          padding: padding,
          child: Row(
            children: [
              const Icon(Icons.question_answer, size: 20),
              Text(thread.postsCount.toString()),
              const Spacer(),
            ],
          ),
        )
      ],
    );
  }
}

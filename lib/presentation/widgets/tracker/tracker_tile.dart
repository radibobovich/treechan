import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/tab.dart';
import '../../../domain/models/tracked_item.dart';
import '../../bloc/tracker_cubit.dart';
import '../../provider/page_provider.dart';

class TrackerTile extends StatefulWidget {
  final TrackedItem item;
  final bool isRefreshing;
  const TrackerTile(
      {super.key, required this.item, required this.isRefreshing});

  @override
  State<TrackerTile> createState() => _TrackerTileState();
}

class _TrackerTileState extends State<TrackerTile>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isRefreshing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.repeat();
      });
    } else if (_controller.isAnimating) {
      _controller.animateTo(1.0).whenComplete(() => _controller.reset());
    }
    return InkWell(
      onTap: () => onTrackerTileTap(widget.item, context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
        child: Row(
          children: [
            RefreshButton(controller: _controller, widget: widget),
            ItemTitle(widget: widget),
            Counters(widget: widget),
            // close
            IconButton(
              onPressed: () =>
                  context.read<TrackerCubit>().removeItem(widget.item),
              icon: const Icon(Icons.close),
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }

  void onTrackerTileTap(TrackedItem item, BuildContext context) {
    if (item is TrackedThread) {
      final tab = ThreadTab(
        id: item.threadId,
        tag: item.tag,
        name: item.name,
        imageboard: item.imageboard,
        prevTab: boardListTab,
      );
      context.read<PageProvider>().addTab(tab);
    } else if (item is TrackedBranch) {
      final tab = BranchTab(
        id: item.branchId,
        threadId: item.threadId,
        tag: item.tag,
        name: item.name,
        imageboard: item.imageboard,
        prevTab: boardListTab,
      );
      context.read<PageProvider>().addTab(tab);
    }
  }
}

class RefreshButton extends StatelessWidget {
  const RefreshButton({
    super.key,
    required AnimationController controller,
    required this.widget,
  }) : _controller = controller;

  final AnimationController _controller;
  final TrackerTile widget;

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
      child: IconButton(
        icon: const Icon(Icons.refresh),
        iconSize: 20,
        onPressed: () {
          context.read<TrackerCubit>().refreshItem(widget.item);
        },
      ),
    );
  }
}

class ItemTitle extends StatelessWidget {
  const ItemTitle({
    super.key,
    required this.widget,
  });

  final TrackerTile widget;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(widget.item.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textWidthBasis: TextWidthBasis.longestLine,
          style: widget.item.isDead
              ? const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  decorationThickness: 2,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)
              : const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }
}

class Counters extends StatelessWidget {
  const Counters({
    super.key,
    required this.widget,
  });

  final TrackerTile widget;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 55,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
        child: Row(
          children: [
            NewPostsCounter(widget: widget),
            const Spacer(),
            PostsCounter(widget: widget)
          ],
        ),
      ),
    );
  }
}

/// Includes new posts and new replies counters.
class NewPostsCounter extends StatelessWidget {
  const NewPostsCounter({
    super.key,
    required this.widget,
  });

  final TrackerTile widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.item.newPosts.toString().padRight(
                3,
                ' ',
              ),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(widget.item.newReplies.toString().padRight(3, ' '),
            style: const TextStyle(fontWeight: FontWeight.bold))
      ],
    );
  }
}

class PostsCounter extends StatelessWidget {
  const PostsCounter({
    super.key,
    required this.widget,
  });

  final TrackerTile widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.item.posts.toString().padLeft(3, ' '),
        ),
        const Text(''),
      ],
    );
  }
}

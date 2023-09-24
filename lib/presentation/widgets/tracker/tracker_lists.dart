import 'package:flutter/material.dart';

import '../../../domain/models/tracked_item.dart';
import 'tracker_tile.dart';

class ThreadsList extends StatelessWidget {
  final List<TrackedThread> threads;
  final TrackedItem? refreshingItem;
  const ThreadsList({
    super.key,
    required this.threads,
    this.refreshingItem,
  });

  @override
  Widget build(BuildContext context) {
    if (threads.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 50),
          child: Text('Нет отслеживаемых тредов'),
        ),
      );
    }
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: threads.length,
        itemBuilder: (context, index) {
          final item = threads[index];
          final bool isRefreshing =
              item.id == refreshingItem?.id && item.tag == refreshingItem?.tag;
          return TrackerTile(item: item, isRefreshing: isRefreshing);
        });
  }
}

class BranchesList extends StatelessWidget {
  final List<TrackedBranch> branches;
  final TrackedItem? refreshingItem;
  const BranchesList({
    super.key,
    required this.branches,
    this.refreshingItem,
  });

  @override
  Widget build(BuildContext context) {
    if (branches.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Center(
          child: Text('Нет отслеживаемых веток'),
        ),
      );
    }
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: branches.length,
        itemBuilder: (context, index) {
          final item = branches[index];
          final bool isRefreshing =
              item.id == refreshingItem?.id && item.tag == refreshingItem?.tag;
          return TrackerTile(item: item, isRefreshing: isRefreshing);
        });
  }
}

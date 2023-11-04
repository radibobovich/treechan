import 'package:treechan/utils/constants/enums.dart';

abstract class TrackedItem {
  final String tag;
  final int threadId;
  final String name;
  final Imageboard imageboard;
  final int posts;
  final int newPosts;
  final int newPostsDiff;
  final int newReplies;
  final int newRepliesDiff;
  final bool isDead;
  final int addTimestamp;
  final int refreshTimestamp;

  TrackedItem(
      {required this.tag,
      required this.threadId,
      required this.name,
      required this.imageboard,
      required this.posts,
      required this.newPosts,
      required this.newPostsDiff,
      required this.newReplies,
      required this.newRepliesDiff,
      required this.isDead,
      required this.addTimestamp,
      required this.refreshTimestamp});

  int get id;
}

class TrackedThread extends TrackedItem {
  TrackedThread(
      {required super.tag,
      required super.threadId,
      required super.name,
      required super.imageboard,
      required super.posts,
      required super.newPosts,
      required super.newPostsDiff,
      required super.newReplies,
      required super.newRepliesDiff,
      required super.isDead,
      required super.addTimestamp,
      required super.refreshTimestamp});

  @override
  int get id => threadId;
}

class TrackedBranch extends TrackedItem {
  final int branchId;

  TrackedBranch(
      {required super.tag,
      required this.branchId,
      required super.threadId,
      required super.name,
      required super.imageboard,
      required super.posts,
      required super.newPosts,
      required super.newPostsDiff,
      required super.newReplies,
      required super.newRepliesDiff,
      required super.isDead,
      required super.addTimestamp,
      required super.refreshTimestamp});

  @override
  int get id => branchId;
}

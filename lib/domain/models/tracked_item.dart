abstract class TrackedItem {
  final String tag;
  final int threadId;
  final String name;
  final int posts;
  final int newPosts;
  final int newReplies;
  final bool isDead;
  final int addTimestamp;
  final int refreshTimestamp;

  TrackedItem(
      {required this.tag,
      required this.threadId,
      required this.name,
      required this.posts,
      required this.newPosts,
      required this.newReplies,
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
      required super.posts,
      required super.newPosts,
      required super.newReplies,
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
      required super.posts,
      required super.newPosts,
      required super.newReplies,
      required super.isDead,
      required super.addTimestamp,
      required super.refreshTimestamp});

  @override
  int get id => branchId;
}

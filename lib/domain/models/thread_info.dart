class ThreadInfo {
  final String boardTag;
  final int id;
  final String title;
  int get opPostId => id;
  int lastPostId;
  int maxNum;
  bool showLines;

  ThreadInfo({
    required this.boardTag,
    required this.id,
    required this.title,
    required this.lastPostId,
    required this.maxNum,
    this.showLines = true,
  });
}

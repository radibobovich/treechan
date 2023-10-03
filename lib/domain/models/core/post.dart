import 'package:treechan/domain/models/api/dvach/thread_dvach_api_model.dart';
import 'package:treechan/utils/count_a_tags.dart';

import '../api/dvach/post_dvach_api_model.dart';
import 'file.dart';

class Post {
  final int id;
  final String subject;
  String comment;
  final String boardTag;
  final String date;
  final String email;
  final String name;
  final int timestamp;
  final List<File>? files;
  int? number;
  final bool op;
  final int parent;
  final bool sticky;
  final String? tags;
  final String? trip;
  final int views;

  // In-app fields

  /// Parents id's in the thread
  List<int> parents = [];

  /// Children indexes in posts list
  List<int> children = [];

  int aTagsCount = 0;

  /// If the post should be highlighted as a new post.
  /// Sets to true when added by refreshThread.
  bool isHighlighted = false;

  /// Changes to false when user sees the post.
  /// Used to handle new post highlight.
  bool firstTimeSeen = true;

  /// if user has hidden the post
  bool hidden = false;

  Post({
    required this.id,
    required this.subject,
    required this.comment,
    required this.boardTag,
    required this.date,
    required this.email,
    required this.name,
    required this.timestamp,
    required this.files,
    this.number,
    required this.op,
    required this.parent,
    required this.sticky,
    this.tags,
    this.trip,
    required this.views,
  }) {
    aTagsCount = countATags(comment);
  }

  Post.fromDvachApi(PostDvachApiModel post)
      : id = post.num,
        subject = post.subject ?? '',
        comment = post.comment,
        boardTag = post.board,
        date = post.date,
        email = post.email ?? '',
        name = post.name ?? '',
        timestamp = post.timestamp,
        files = post.files?.map((file) => File.fromFileDvachApi(file)).toList(),
        number = post.number ?? -1,
        op = post.op == 1 ? true : false,
        parent = post.parent,
        sticky = post.sticky == 1 ? true : false,
        tags = post.tags,
        trip = post.trip ?? '',
        views = post.views,
        aTagsCount = countATags(post.comment);

  Post.fromCatalogBoardDvachApi(ThreadDvachApiModel thread)
      : id = thread.num ?? -1,
        subject = thread.subject ?? '',
        comment = thread.comment ?? '',
        boardTag = thread.board ?? '',
        date = thread.date ?? '',
        email = thread.email ?? '',
        name = thread.name ?? '',
        timestamp = thread.timestamp ?? -1,
        files =
            thread.files?.map((file) => File.fromFileDvachApi(file)).toList(),
        number = -1,
        op = thread.op == 1 ? true : false,
        parent = thread.parent ?? -1,
        sticky = thread.sticky == 1 ? true : false,
        tags = thread.tags,
        trip = thread.trip ?? '',
        views = thread.views ?? -1,
        aTagsCount = countATags(thread.comment ?? '');
}

import "package:treechan/presentation/widgets/shared/html_container_widget.dart";

import "json.dart";
import "package:flutter/material.dart";

class Post {
  /// Banned or not for this post.
  late bool banned;

  /// Board tag, for example b
  late String board;

  /// Needs description.
  late bool closed;

  /// Text of the post.
  late String comment;

  /// Date of publication, for example '12/07/23 Срд 01:11:30'
  late String date;

  /// email. Usually empty string or 'sage'
  late String email;

  /// True if the thread removes old messages to add new ones
  late bool endless;

  /// Media attached to the post.
  List<File>? files;

  /// Needs description.
  late int lasthit;

  /// Author name. Usually 'Аноним'
  late String name;

  /// Post id, for example, 289970552
  /// Post id is unique for the board, but not for the entire website.
  late int id;

  /// Post position by count. OP-post has count 1. Null if on the board page.
  int? number;

  /// If this post made by OP.
  late bool op;

  /// Contains id of OP post of the thread. If this is OP post itself, it's 0.
  late int parent;

  /// If the thread is pinned at the top of the board.
  late bool sticky;

  /// Header of the post.
  late String subject;

  /// Needs description.
  String? tags;

  /// Unix timestamp.
  late int timestamp;

  /// Needs description
  late String trip;
  late int views;

  /// Each post has its GlobalKey because we need to scroll to a specific post
  /// after thread refresh.
  GlobalKey? gKey = GlobalKey();

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
  Post(
      {this.banned = false,
      this.board = '',
      this.closed = false,
      this.comment = '',
      this.date = '',
      this.email = '',
      this.endless = false,
      required this.files,
      this.lasthit = 0,
      this.name = '',
      this.id = 0,
      this.number = 0,
      this.op = false,
      this.parent = 0,
      this.sticky = false,
      this.subject = '',
      this.tags = '',
      this.timestamp = 0,
      this.trip = '',
      this.views = 0,
      this.gKey});

  Post.fromJson(Map<String, dynamic> json) {
    banned = json['banned'] == 1 ? true : false;
    board = json['board'];
    closed = json['closed'] == 1 ? true : false;
    comment = json['comment'];
    date = json['date'];
    email = json['email'];
    endless = json['endless'] == 1 ? true : false;
    if (json['files'] != null) {
      files = <File>[];
      json['files'].forEach((v) {
        files!.add(File.fromJson(v));
      });
    }
    lasthit = json['lasthit'];
    name = json['name'];
    id = json['num'];
    number = json['number'];
    op = json['op'] == 1 ? true : false;
    parent = json['parent'];
    sticky = json['sticky'] > 0 ? true : false;
    subject = json['subject'];
    tags = json['tags'];
    timestamp = json['timestamp'];
    trip = json['trip'];
    views = json['views'];

    aTagsCount = countATags(comment);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['banned'] = banned;
    data['board'] = board;
    data['closed'] = closed;
    data['comment'] = comment;
    data['date'] = date;
    data['email'] = email;
    data['endless'] = endless;
    data['files'] = files?.map((v) => v.toJson()).toList() ?? [];
    data['lasthit'] = lasthit;
    data['name'] = name;
    data['num'] = id;
    data['number'] = number;
    data['op'] = op;
    data['parent'] = parent;
    data['sticky'] = sticky;
    data['subject'] = subject;
    data['tags'] = tags;
    data['timestamp'] = timestamp;
    data['trip'] = trip;
    data['views'] = views;
    return data;
  }
}

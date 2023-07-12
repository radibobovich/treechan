import "json.dart";
import "package:flutter/material.dart";

class Post {
  /// Banned or not.
  late int banned;

  /// Board tag, for example b
  late String board;

  /// Needs description.
  late int closed;

  /// Text of the post.
  late String comment;

  /// Date of publication, for example '12/07/23 Срд 01:11:30'
  late String date;

  /// email. Usually empty string or 'sage'
  late String email;

  /// Needs description.
  late int endless;

  /// Media attached to the post.
  late List<File> files = [];

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
  late int op;

  /// Contains id of OP post of the thread. If this is OP post itself, it's 0.
  late int parent;

  /// Needs description.
  late int sticky;

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
  List<int> parents = List.empty(growable: true);

  /// Children indexes in posts list
  List<int> children = [];

  /// If the post should be highlighted as a new post.
  /// Sets to true when added by refreshThread.
  bool isHighlighted = false;
  Post(
      {this.banned = 0,
      this.board = '',
      this.closed = 0,
      this.comment = '',
      this.date = '',
      this.email = '',
      this.endless = 0,
      required this.files,
      this.lasthit = 0,
      this.name = '',
      this.id = 0,
      this.number = 0,
      this.op = 0,
      this.parent = 0,
      this.sticky = 0,
      this.subject = '',
      this.tags = '',
      this.timestamp = 0,
      this.trip = '',
      this.views = 0,
      this.gKey});

  Post.fromJson(Map<String, dynamic> json) {
    banned = json['banned'];
    board = json['board'];
    closed = json['closed'];
    comment = json['comment'];
    date = json['date'];
    email = json['email'];
    endless = json['endless'];
    if (json['files'] != null) {
      files = <File>[];
      json['files'].forEach((v) {
        files.add(File.fromJson(v));
      });
    }
    lasthit = json['lasthit'];
    name = json['name'];
    id = json['num'];
    number = json['number'];
    op = json['op'];
    parent = json['parent'];
    sticky = json['sticky'];
    subject = json['subject'];
    tags = json['tags'];
    timestamp = json['timestamp'];
    trip = json['trip'];
    views = json['views'];
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
    data['files'] = files.map((v) => v.toJson()).toList();
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

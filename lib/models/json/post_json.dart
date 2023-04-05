import "json.dart";
import "package:flutter/material.dart";

class Post {
  int? banned;
  String? board;
  int? closed;
  String? comment;
  String? date;
  String? email;
  int? endless;
  List<File>? files;
  int? lasthit;
  String? name;
  int? id;
  int? number;
  int? op;
  int? parent;
  int? sticky;
  String? subject;
  String? tags;
  int? timestamp;
  String? trip;
  int? views;
  GlobalKey? gKey = GlobalKey();
  List<int> parents = List.empty(growable: true);
  Post(
      {this.banned,
      this.board,
      this.closed,
      this.comment,
      this.date,
      this.email,
      this.endless,
      this.files,
      this.lasthit,
      this.name,
      this.id,
      this.number,
      this.op,
      this.parent,
      this.sticky,
      this.subject,
      this.tags,
      this.timestamp,
      this.trip,
      this.views,
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
        files!.add(File.fromJson(v));
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
    if (files != null) {
      data['files'] = files!.map((v) => v.toJson()).toList();
    }
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

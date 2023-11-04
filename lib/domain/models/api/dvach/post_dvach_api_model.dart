// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:treechan/domain/models/api/post_api_model.dart';

part '../../../../generated/domain/models/api/dvach/post_dvach_api_model.g.dart';

@JsonSerializable()
class PostDvachApiModel implements PostApiModel {
  final int num;
  final int parent;
  final String board;
  final int timestamp;
  final int lasthit;
  final String date;
  final String? email;
  final String? subject;
  final String comment;
  final int? number;
  final List<FileDvachApiModel>? files;
  final int views;
  final int sticky;
  final int endless;
  final int closed;
  final int banned;
  final int op;
  final String? name;
  final String? icon;
  final String? trip;
  final String? trip_style;
  final String? tags;
  final int? likes;
  final int? dislikes;

  PostDvachApiModel({
    required this.num,
    required this.parent,
    required this.board,
    required this.timestamp,
    required this.lasthit,
    required this.date,
    this.email,
    this.subject,
    required this.comment,
    this.number,
    this.files,
    required this.views,
    required this.sticky,
    required this.endless,
    required this.closed,
    required this.banned,
    required this.op,
    this.name,
    this.icon,
    this.trip,
    this.trip_style,
    this.tags,
    this.likes,
    this.dislikes,
  });

  factory PostDvachApiModel.fromJson(Map<String, dynamic> json) =>
      _$PostDvachApiModelFromJson(json
        ..update(
            'parent', (value) => value is String ? int.parse(value) : value)
        ..update(
          'board',
          (value) => value,
          ifAbsent: () => '',
        )
        ..update(
          'views',
          (value) => value,
          ifAbsent: () => -1,
        )
        ..update(
          'endless',
          (value) => value,
          ifAbsent: () => 0,
        ));
}

@JsonSerializable()
class FileDvachApiModel {
  final String name;
  final String fullname;
  final String displayname;
  final String path;
  final String thumbnail;
  final String? md5;
  final int type;
  final int size;
  final int width;
  final int height;
  final int tn_width;
  final int tn_height;
  final int? nsfw;
  final String? duration;
  final int? duration_secs;
  final String? pack;
  final String? sticker;
  final String? install;

  FileDvachApiModel({
    required this.name,
    required this.fullname,
    required this.displayname,
    required this.path,
    required this.thumbnail,
    this.md5,
    required this.type,
    required this.size,
    required this.width,
    required this.height,
    required this.tn_width,
    required this.tn_height,
    this.nsfw,
    this.duration,
    this.duration_secs,
    this.pack,
    this.sticker,
    this.install,
  });

  factory FileDvachApiModel.fromJson(Map<String, dynamic> json) =>
      _$FileDvachApiModelFromJson(json
        ..update('fullname', (value) => value, ifAbsent: () => '')
        ..update(
          'displayname',
          (value) => value,
          ifAbsent: () => '',
        ));
}

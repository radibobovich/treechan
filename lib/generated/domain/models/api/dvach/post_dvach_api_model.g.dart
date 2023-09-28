// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../../../domain/models/api/dvach/post_dvach_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostDvachApiModel _$PostDvachApiModelFromJson(Map<String, dynamic> json) =>
    PostDvachApiModel(
      num: json['num'] as int,
      parent: json['parent'] as int,
      board: json['board'] as String,
      timestamp: json['timestamp'] as int,
      lasthit: json['lasthit'] as int,
      date: json['date'] as String,
      email: json['email'] as String?,
      subject: json['subject'] as String?,
      comment: json['comment'] as String,
      number: json['number'] as int?,
      files: (json['files'] as List<dynamic>?)
          ?.map((e) => FileDvachApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      views: json['views'] as int,
      sticky: json['sticky'] as int,
      endless: json['endless'] as int,
      closed: json['closed'] as int,
      banned: json['banned'] as int,
      op: json['op'] as int,
      name: json['name'] as String?,
      icon: json['icon'] as String?,
      trip: json['trip'] as String?,
      trip_style: json['trip_style'] as String?,
      tags: json['tags'] as String?,
      likes: json['likes'] as int?,
      dislikes: json['dislikes'] as int?,
    );

Map<String, dynamic> _$PostDvachApiModelToJson(PostDvachApiModel instance) =>
    <String, dynamic>{
      'num': instance.num,
      'parent': instance.parent,
      'board': instance.board,
      'timestamp': instance.timestamp,
      'lasthit': instance.lasthit,
      'date': instance.date,
      'email': instance.email,
      'subject': instance.subject,
      'comment': instance.comment,
      'number': instance.number,
      'files': instance.files,
      'views': instance.views,
      'sticky': instance.sticky,
      'endless': instance.endless,
      'closed': instance.closed,
      'banned': instance.banned,
      'op': instance.op,
      'name': instance.name,
      'icon': instance.icon,
      'trip': instance.trip,
      'trip_style': instance.trip_style,
      'tags': instance.tags,
      'likes': instance.likes,
      'dislikes': instance.dislikes,
    };

FileDvachApiModel _$FileDvachApiModelFromJson(Map<String, dynamic> json) =>
    FileDvachApiModel(
      name: json['name'] as String,
      fullname: json['fullname'] as String,
      displayname: json['displayname'] as String,
      path: json['path'] as String,
      thumbnail: json['thumbnail'] as String,
      md5: json['md5'] as String?,
      type: json['type'] as int,
      size: json['size'] as int,
      width: json['width'] as int,
      height: json['height'] as int,
      tn_width: json['tn_width'] as int,
      tn_height: json['tn_height'] as int,
      nsfw: json['nsfw'] as int?,
      duration: json['duration'] as String?,
      duration_secs: json['duration_secs'] as int?,
      pack: json['pack'] as String?,
      sticker: json['sticker'] as String?,
      install: json['install'] as String?,
    );

Map<String, dynamic> _$FileDvachApiModelToJson(FileDvachApiModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'fullname': instance.fullname,
      'displayname': instance.displayname,
      'path': instance.path,
      'thumbnail': instance.thumbnail,
      'md5': instance.md5,
      'type': instance.type,
      'size': instance.size,
      'width': instance.width,
      'height': instance.height,
      'tn_width': instance.tn_width,
      'tn_height': instance.tn_height,
      'nsfw': instance.nsfw,
      'duration': instance.duration,
      'duration_secs': instance.duration_secs,
      'pack': instance.pack,
      'sticker': instance.sticker,
      'install': instance.install,
    };

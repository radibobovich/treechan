// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../../../domain/models/api/dvach/thread_dvach_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadResponseDvachApiModel _$ThreadResponseDvachApiModelFromJson(
        Map<String, dynamic> json) =>
    ThreadResponseDvachApiModel(
      advert_bottom_image: json['advert_bottom_image'] as String?,
      advert_bottom_link: json['advert_bottom_link'] as String?,
      advert_mobile_image: json['advert_mobile_image'] as String?,
      advert_mobile_link: json['advert_mobile_link'] as String?,
      advert_top_image: json['advert_top_image'] as String?,
      advert_top_link: json['advert_top_link'] as String?,
      board: BoardDvachApiModel.fromJson(json['board'] as Map<String, dynamic>),
      board_banner_image: json['board_banner_image'] as String,
      board_banner_link: json['board_banner_link'] as String,
      current_thread: json['current_thread'] as int,
      files_count: json['files_count'] as int,
      is_board: json['is_board'] as bool,
      is_closed: json['is_closed'] as int,
      is_index: json['is_index'] as bool,
      max_num: json['max_num'] as int,
      posts_count: json['posts_count'] as int,
      thread_first_image: json['thread_first_image'] as String,
      threads: (json['threads'] as List<dynamic>)
          .map((e) => ThreadDvachApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ThreadResponseDvachApiModelToJson(
        ThreadResponseDvachApiModel instance) =>
    <String, dynamic>{
      'advert_bottom_image': instance.advert_bottom_image,
      'advert_bottom_link': instance.advert_bottom_link,
      'advert_mobile_image': instance.advert_mobile_image,
      'advert_mobile_link': instance.advert_mobile_link,
      'advert_top_image': instance.advert_top_image,
      'advert_top_link': instance.advert_top_link,
      'board': instance.board,
      'board_banner_image': instance.board_banner_image,
      'board_banner_link': instance.board_banner_link,
      'current_thread': instance.current_thread,
      'files_count': instance.files_count,
      'is_board': instance.is_board,
      'is_closed': instance.is_closed,
      'is_index': instance.is_index,
      'max_num': instance.max_num,
      'posts_count': instance.posts_count,
      'thread_first_image': instance.thread_first_image,
      'threads': instance.threads,
    };

ThreadDvachApiModel _$ThreadDvachApiModelFromJson(Map<String, dynamic> json) =>
    ThreadDvachApiModel(
      title: json['title'] as String?,
      unique_posters: json['unique_posters'] as int?,
      posts: (json['posts'] as List<dynamic>?)
          ?.map((e) => PostDvachApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      banned: json['banned'] as int?,
      board: json['board'] as String?,
      closed: json['closed'] as int?,
      comment: json['comment'] as String?,
      date: json['date'] as String?,
      email: json['email'] as String?,
      endless: json['endless'] as int?,
      files: (json['files'] as List<dynamic>?)
          ?.map((e) => FileDvachApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      files_count: json['files_count'] as int?,
      lasthit: json['lasthit'] as int?,
      name: json['name'] as String?,
      num: json['num'] as int?,
      op: json['op'] as int?,
      parent: json['parent'] as int?,
      posts_count: json['posts_count'] as int?,
      sticky: json['sticky'] as int?,
      subject: json['subject'] as String?,
      tags: json['tags'] as String?,
      timestamp: json['timestamp'] as int?,
      trip: json['trip'] as String?,
      views: json['views'] as int?,
      fileCount: json['fileCount'] as int?,
      postsCount: json['postsCount'] as int?,
      thread_num: json['thread_num'] as int?,
    );

Map<String, dynamic> _$ThreadDvachApiModelToJson(
        ThreadDvachApiModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'unique_posters': instance.unique_posters,
      'posts': instance.posts,
      'fileCount': instance.fileCount,
      'postsCount': instance.postsCount,
      'thread_num': instance.thread_num,
      'banned': instance.banned,
      'board': instance.board,
      'closed': instance.closed,
      'comment': instance.comment,
      'date': instance.date,
      'email': instance.email,
      'endless': instance.endless,
      'files': instance.files,
      'files_count': instance.files_count,
      'lasthit': instance.lasthit,
      'name': instance.name,
      'num': instance.num,
      'op': instance.op,
      'parent': instance.parent,
      'posts_count': instance.posts_count,
      'sticky': instance.sticky,
      'subject': instance.subject,
      'tags': instance.tags,
      'timestamp': instance.timestamp,
      'trip': instance.trip,
      'views': instance.views,
    };

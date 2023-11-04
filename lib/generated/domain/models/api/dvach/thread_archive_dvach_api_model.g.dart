// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../../../domain/models/api/dvach/thread_archive_dvach_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadArchiveResponseDvachApiModel _$ThreadArchiveResponseDvachApiModelFromJson(
        Map<String, dynamic> json) =>
    ThreadArchiveResponseDvachApiModel(
      Board: json['Board'] as String,
      BoardInfo: json['BoardInfo'] as String,
      BoardInfoOuter: json['BoardInfoOuter'] as String,
      BoardName: json['BoardName'] as String,
      advert_bottom_image: json['advert_bottom_image'] as String?,
      advert_bottom_link: json['advert_bottom_link'] as String?,
      advert_mobile_image: json['advert_mobile_image'] as String?,
      advert_mobile_link: json['advert_mobile_link'] as String?,
      advert_top_image: json['advert_top_image'] as String?,
      advert_top_link: json['advert_top_link'] as String?,
      board_banner_image: json['board_banner_image'] as String?,
      board_banner_link: json['board_banner_link'] as String?,
      bump_limit: json['bump_limit'] as int?,
      current_thread: json['current_thread'] as String,
      default_name: json['default_name'] as String?,
      enable_dices: json['enable_dices'] as int?,
      enable_flags: json['enable_flags'] as int?,
      enable_icons: json['enable_icons'] as int?,
      enable_images: json['enable_images'] as int?,
      enable_likes: json['enable_likes'] as int?,
      enable_names: json['enable_names'] as int?,
      enable_oekaki: json['enable_oekaki'] as int?,
      enable_posting: json['enable_posting'] as int?,
      enable_sage: json['enable_sage'] as int?,
      enable_shield: json['enable_shield'] as int?,
      enable_subject: json['enable_subject'] as int?,
      enable_thread_tags: json['enable_thread_tags'] as int?,
      enable_trips: json['enable_trips'] as int?,
      enable_video: json['enable_video'] as int?,
      file_prefix: json['file_prefix'] as String?,
      files_count: json['files_count'] as int,
      is_board: json['is_board'] as int?,
      is_closed: json['is_closed'] as int?,
      is_index: json['is_index'] as int?,
      max_comment: json['max_comment'] as int?,
      max_num: json['max_num'] as int?,
      news: (json['news'] as List<dynamic>?)
          ?.map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      news_abu: (json['news_abu'] as List<dynamic>?)
          ?.map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      posts_count: json['posts_count'] as int,
      threads: (json['threads'] as List<dynamic>)
          .map((e) => ThreadDvachApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      top: (json['top'] as List<dynamic>?)
          ?.map((e) => TopItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      title: json['title'] as String,
    );

Map<String, dynamic> _$ThreadArchiveResponseDvachApiModelToJson(
        ThreadArchiveResponseDvachApiModel instance) =>
    <String, dynamic>{
      'Board': instance.Board,
      'BoardInfo': instance.BoardInfo,
      'BoardInfoOuter': instance.BoardInfoOuter,
      'BoardName': instance.BoardName,
      'advert_bottom_image': instance.advert_bottom_image,
      'advert_bottom_link': instance.advert_bottom_link,
      'advert_mobile_image': instance.advert_mobile_image,
      'advert_mobile_link': instance.advert_mobile_link,
      'advert_top_image': instance.advert_top_image,
      'advert_top_link': instance.advert_top_link,
      'board_banner_image': instance.board_banner_image,
      'board_banner_link': instance.board_banner_link,
      'bump_limit': instance.bump_limit,
      'current_thread': instance.current_thread,
      'default_name': instance.default_name,
      'enable_dices': instance.enable_dices,
      'enable_flags': instance.enable_flags,
      'enable_icons': instance.enable_icons,
      'enable_images': instance.enable_images,
      'enable_likes': instance.enable_likes,
      'enable_names': instance.enable_names,
      'enable_oekaki': instance.enable_oekaki,
      'enable_posting': instance.enable_posting,
      'enable_sage': instance.enable_sage,
      'enable_shield': instance.enable_shield,
      'enable_subject': instance.enable_subject,
      'enable_thread_tags': instance.enable_thread_tags,
      'enable_trips': instance.enable_trips,
      'enable_video': instance.enable_video,
      'file_prefix': instance.file_prefix,
      'files_count': instance.files_count,
      'is_board': instance.is_board,
      'is_closed': instance.is_closed,
      'is_index': instance.is_index,
      'max_comment': instance.max_comment,
      'max_num': instance.max_num,
      'news': instance.news,
      'news_abu': instance.news_abu,
      'posts_count': instance.posts_count,
      'threads': instance.threads,
      'top': instance.top,
      'title': instance.title,
    };

NewsItem _$NewsItemFromJson(Map<String, dynamic> json) => NewsItem(
      date: json['date'] as String?,
      num: json['num'] as int?,
      subject: json['subject'] as String?,
    );

Map<String, dynamic> _$NewsItemToJson(NewsItem instance) => <String, dynamic>{
      'date': instance.date,
      'num': instance.num,
      'subject': instance.subject,
    };

TopItem _$TopItemFromJson(Map<String, dynamic> json) => TopItem(
      board: json['board'] as String?,
      info: json['info'] as String?,
      name: json['name'] as String?,
      speed: json['speed'] as int?,
    );

Map<String, dynamic> _$TopItemToJson(TopItem instance) => <String, dynamic>{
      'board': instance.board,
      'info': instance.info,
      'name': instance.name,
      'speed': instance.speed,
    };

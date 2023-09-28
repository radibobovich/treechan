// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../../../domain/models/api/dvach/board_dvach_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoardResponseDvachApiModel _$BoardResponseDvachApiModelFromJson(
        Map<String, dynamic> json) =>
    BoardResponseDvachApiModel(
      advert_bottom_image: json['advert_bottom_image'] as String,
      advert_bottom_link: json['advert_bottom_link'] as String,
      advert_mobile_image: json['advert_mobile_image'] as String,
      advert_mobile_link: json['advert_mobile_link'] as String,
      advert_top_image: json['advert_top_image'] as String,
      advert_top_link: json['advert_top_link'] as String,
      board: BoardDvachApiModel.fromJson(json['board'] as Map<String, dynamic>),
      board_banner_image: json['board_banner_image'] as String,
      board_banner_link: json['board_banner_link'] as String,
      board_speed: json['board_speed'] as int?,
      current_page: json['current_page'] as int?,
      current_thread: json['current_thread'] as int?,
      is_board: json['is_board'] as bool?,
      is_index: json['is_index'] as bool?,
      pages: (json['pages'] as List<dynamic>?)?.map((e) => e as int).toList(),
      threads: (json['threads'] as List<dynamic>)
          .map((e) => ThreadDvachApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      filter: json['filter'] as String?,
    );

Map<String, dynamic> _$BoardResponseDvachApiModelToJson(
        BoardResponseDvachApiModel instance) =>
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
      'board_speed': instance.board_speed,
      'current_page': instance.current_page,
      'current_thread': instance.current_thread,
      'is_board': instance.is_board,
      'is_index': instance.is_index,
      'pages': instance.pages,
      'threads': instance.threads,
      'filter': instance.filter,
    };

BoardDvachApiModel _$BoardDvachApiModelFromJson(Map<String, dynamic> json) =>
    BoardDvachApiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      info: json['info'] as String,
      info_outer: json['info_outer'] as String,
      threads_per_page: json['threads_per_page'] as int,
      bump_limit: json['bump_limit'] as int,
      max_pages: json['max_pages'] as int,
      default_name: json['default_name'] as String?,
      enable_names: json['enable_names'] as bool,
      enable_trips: json['enable_trips'] as bool,
      enable_subject: json['enable_subject'] as bool,
      enable_sage: json['enable_sage'] as bool,
      enable_icons: json['enable_icons'] as bool,
      enable_flags: json['enable_flags'] as bool,
      enable_dices: json['enable_dices'] as bool,
      enable_shield: json['enable_shield'] as bool,
      enable_thread_tags: json['enable_thread_tags'] as bool,
      enable_posting: json['enable_posting'] as bool,
      enable_likes: json['enable_likes'] as bool,
      enable_oekaki: json['enable_oekaki'] as bool,
      file_types: (json['file_types'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      max_comment: json['max_comment'] as int,
      max_files_size: json['max_files_size'] as int,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      icons: (json['icons'] as List<dynamic>?)
          ?.map(
              (e) => BoardIconDvachApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BoardDvachApiModelToJson(BoardDvachApiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'info': instance.info,
      'info_outer': instance.info_outer,
      'threads_per_page': instance.threads_per_page,
      'bump_limit': instance.bump_limit,
      'max_pages': instance.max_pages,
      'default_name': instance.default_name,
      'enable_names': instance.enable_names,
      'enable_trips': instance.enable_trips,
      'enable_subject': instance.enable_subject,
      'enable_sage': instance.enable_sage,
      'enable_icons': instance.enable_icons,
      'enable_flags': instance.enable_flags,
      'enable_dices': instance.enable_dices,
      'enable_shield': instance.enable_shield,
      'enable_thread_tags': instance.enable_thread_tags,
      'enable_posting': instance.enable_posting,
      'enable_likes': instance.enable_likes,
      'enable_oekaki': instance.enable_oekaki,
      'file_types': instance.file_types,
      'max_comment': instance.max_comment,
      'max_files_size': instance.max_files_size,
      'tags': instance.tags,
      'icons': instance.icons,
    };

BoardIconDvachApiModel _$BoardIconDvachApiModelFromJson(
        Map<String, dynamic> json) =>
    BoardIconDvachApiModel(
      num: json['num'] as int?,
      name: json['name'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$BoardIconDvachApiModelToJson(
        BoardIconDvachApiModel instance) =>
    <String, dynamic>{
      'num': instance.num,
      'name': instance.name,
      'url': instance.url,
    };

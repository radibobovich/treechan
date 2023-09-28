// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

import '../board_api_model.dart';
import 'thread_dvach_api_model.dart';

part '../../../../generated/domain/models/api/dvach/board_dvach_api_model.g.dart';

@JsonSerializable()
class BoardResponseDvachApiModel implements BoardResponseApiModel {
  final String advert_bottom_image;
  final String advert_bottom_link;
  final String advert_mobile_image;
  final String advert_mobile_link;
  final String advert_top_image;
  final String advert_top_link;
  final BoardDvachApiModel board;
  final String board_banner_image;
  final String board_banner_link;
  final int? board_speed;
  final int? current_page;
  final int? current_thread;
  final bool? is_board;
  final bool? is_index;
  final List<int>? pages;
  final List<ThreadDvachApiModel> threads;
  final String? filter;

  BoardResponseDvachApiModel({
    required this.advert_bottom_image,
    required this.advert_bottom_link,
    required this.advert_mobile_image,
    required this.advert_mobile_link,
    required this.advert_top_image,
    required this.advert_top_link,
    required this.board,
    required this.board_banner_image,
    required this.board_banner_link,
    this.board_speed,
    this.current_page,
    this.current_thread,
    this.is_board,
    this.is_index,
    this.pages,
    required this.threads,
    this.filter,
  });

  factory BoardResponseDvachApiModel.fromJson(Map<String, dynamic> json) =>
      _$BoardResponseDvachApiModelFromJson(json);
}

@JsonSerializable()
class BoardDvachApiModel implements BoardApiModel {
  final String id;
  final String name;
  final String category;
  final String info;
  final String info_outer;
  final int threads_per_page;
  final int bump_limit;
  final int max_pages;
  final String? default_name;
  final bool enable_names;
  final bool enable_trips;
  final bool enable_subject;
  final bool enable_sage;
  final bool enable_icons;
  final bool enable_flags;
  final bool enable_dices;
  final bool enable_shield;
  final bool enable_thread_tags;
  final bool enable_posting;
  final bool enable_likes;
  final bool enable_oekaki;
  final List<String> file_types;
  final int max_comment;
  final int max_files_size;
  final List<String>? tags;
  final List<BoardIconDvachApiModel>? icons;

  BoardDvachApiModel({
    required this.id,
    required this.name,
    required this.category,
    required this.info,
    required this.info_outer,
    required this.threads_per_page,
    required this.bump_limit,
    required this.max_pages,
    required this.default_name,
    required this.enable_names,
    required this.enable_trips,
    required this.enable_subject,
    required this.enable_sage,
    required this.enable_icons,
    required this.enable_flags,
    required this.enable_dices,
    required this.enable_shield,
    required this.enable_thread_tags,
    required this.enable_posting,
    required this.enable_likes,
    required this.enable_oekaki,
    required this.file_types,
    required this.max_comment,
    required this.max_files_size,
    this.tags,
    this.icons,
  });

  factory BoardDvachApiModel.fromJson(Map<String, dynamic> json) =>
      _$BoardDvachApiModelFromJson(json);
}

@JsonSerializable()
class BoardIconDvachApiModel {
  final int? num;
  final String? name;
  final String? url;

  BoardIconDvachApiModel({
    required this.num,
    required this.name,
    required this.url,
  });

  factory BoardIconDvachApiModel.fromJson(Map<String, dynamic> json) =>
      _$BoardIconDvachApiModelFromJson(json);
}

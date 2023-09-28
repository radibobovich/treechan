// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:treechan/domain/models/api/thread_api_model.dart';

import 'board_dvach_api_model.dart';
import 'post_dvach_api_model.dart';

part '../../../../generated/domain/models/api/dvach/thread_dvach_api_model.g.dart';

@JsonSerializable()
class ThreadResponseDvachApiModel implements ThreadResponseApiModel {
  final String? advert_bottom_image;
  final String? advert_bottom_link;
  final String? advert_mobile_image;
  final String? advert_mobile_link;
  final String? advert_top_image;
  final String? advert_top_link;

  final BoardDvachApiModel board;
  final String board_banner_image;
  final String board_banner_link;
  final int current_thread;
  final int files_count;
  final bool is_board;
  final int is_closed;
  final bool is_index;
  final int max_num;
  final int posts_count;
  final String thread_first_image;

  final List<ThreadDvachApiModel> threads;

  ThreadResponseDvachApiModel({
    this.advert_bottom_image,
    this.advert_bottom_link,
    this.advert_mobile_image,
    this.advert_mobile_link,
    this.advert_top_image,
    this.advert_top_link,
    required this.board,
    required this.board_banner_image,
    required this.board_banner_link,
    required this.current_thread,
    required this.files_count,
    required this.is_board,
    required this.is_closed,
    required this.is_index,
    required this.max_num,
    required this.posts_count,
    required this.thread_first_image,
    required this.threads,
  });

  factory ThreadResponseDvachApiModel.fromJson(Map<String, dynamic> json) =>
      _$ThreadResponseDvachApiModelFromJson(json);
}

@JsonSerializable()
class ThreadDvachApiModel {
  /// From thread response
  final String? title;
  final int? unique_posters;
  final List<PostDvachApiModel>? posts;

  /// From index
  final int? fileCount;
  final int? postsCount;
  final int? thread_num;

  /// From catalog
  final int? banned;
  final String? board;
  final int? closed;
  final String? comment;
  final String? date;
  final String? email;
  final int? endless;
  final List<FileDvachApiModel>? files;
  final int? files_count;
  final int? lasthit;
  final String? name;
  final int? num;
  final int? op;
  final int? parent;
  final int? posts_count;
  final int? sticky;
  final String? subject;
  final String? tags;
  final int? timestamp;
  final String? trip;
  final int? views;

  ThreadDvachApiModel({
    this.title,
    this.unique_posters,
    this.posts,
    this.banned,
    this.board,
    this.closed,
    this.comment,
    this.date,
    this.email,
    this.endless,
    this.files,
    this.files_count,
    this.lasthit,
    this.name,
    this.num,
    this.op,
    this.parent,
    this.posts_count,
    this.sticky,
    this.subject,
    this.tags,
    this.timestamp,
    this.trip,
    this.views,
    this.fileCount,
    this.postsCount,
    this.thread_num,
  });

  factory ThreadDvachApiModel.fromJson(Map<String, dynamic> json) =>
      _$ThreadDvachApiModelFromJson(json);
}

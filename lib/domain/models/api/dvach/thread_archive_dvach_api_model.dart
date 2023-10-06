// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:treechan/domain/models/api/dvach/thread_dvach_api_model.dart';
import 'package:treechan/domain/models/api/thread_api_model.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/utils/constants/enums.dart';

part '../../../../generated/domain/models/api/dvach/thread_archive_dvach_api_model.g.dart';

@JsonSerializable()
class ThreadArchiveResponseDvachApiModel implements ThreadResponseApiModel {
  final String Board;
  final String BoardInfo;
  final String BoardInfoOuter;
  final String BoardName;

  final String? advert_bottom_image;
  final String? advert_bottom_link;
  final String? advert_mobile_image;
  final String? advert_mobile_link;
  final String? advert_top_image;
  final String? advert_top_link;

  final String? board_banner_image;
  final String? board_banner_link;

  final int? bump_limit;
  final String current_thread;
  final String? default_name;

  final int? enable_dices;
  final int? enable_flags;
  final int? enable_icons;
  final int? enable_images;
  final int? enable_likes;
  final int? enable_names;
  final int? enable_oekaki;
  final int? enable_posting;
  final int? enable_sage;
  final int? enable_shield;
  final int? enable_subject;
  final int? enable_thread_tags;
  final int? enable_trips;
  final int? enable_video;
  final String? file_prefix;
  final int files_count;
  final int? is_board;
  final int? is_closed;
  final int? is_index;

  final int? max_comment;
  final int? max_num;

  final List<NewsItem>? news;
  final List<NewsItem>? news_abu;

  final int posts_count;

  final List<ThreadDvachApiModel> threads;

  final List<TopItem>? top;

  final String title;

  ThreadArchiveResponseDvachApiModel(
      {required this.Board,
      required this.BoardInfo,
      required this.BoardInfoOuter,
      required this.BoardName,
      this.advert_bottom_image,
      this.advert_bottom_link,
      this.advert_mobile_image,
      this.advert_mobile_link,
      this.advert_top_image,
      this.advert_top_link,
      this.board_banner_image,
      this.board_banner_link,
      this.bump_limit,
      required this.current_thread,
      this.default_name,
      this.enable_dices,
      this.enable_flags,
      this.enable_icons,
      this.enable_images,
      this.enable_likes,
      this.enable_names,
      this.enable_oekaki,
      this.enable_posting,
      this.enable_sage,
      this.enable_shield,
      this.enable_subject,
      this.enable_thread_tags,
      this.enable_trips,
      this.enable_video,
      this.file_prefix,
      required this.files_count,
      this.is_board,
      this.is_closed,
      this.is_index,
      this.max_comment,
      required this.max_num,
      this.news,
      this.news_abu,
      required this.posts_count,
      required this.threads,
      this.top,
      required this.title});

  factory ThreadArchiveResponseDvachApiModel.fromJson(
          Map<String, dynamic> json) =>
      _$ThreadArchiveResponseDvachApiModelFromJson(json);

  Thread toThreadCoreModel() {
    return Thread(
      imageboard: Imageboard.dvachArchive,
      id: int.parse(current_thread),
      boardTag: Board,
      filesCount: files_count,
      posts: threads.first.posts!
          .map((post) => Post.fromDvachApi(post)
            ..files?.forEach((file) {
              if (file.thumbnail.substring(0, 5) == 'thumb') {
                file.thumbnail = "/$Board/${file.thumbnail}";
              }
            }))
          .toList(),
      postsCount: posts_count,
    );
  }
}

@JsonSerializable()
class NewsItem {
  final String? date;
  final int? num;
  final String? subject;

  NewsItem({this.date, this.num, this.subject});

  factory NewsItem.fromJson(Map<String, dynamic> json) =>
      _$NewsItemFromJson(json
        ..update('num', (value) => value is String ? int.parse(value) : value));
}

@JsonSerializable()
class TopItem {
  final String? board;
  final String? info;
  final String? name;
  final int? speed;

  TopItem({this.board, this.info, this.name, this.speed});

  factory TopItem.fromJson(Map<String, dynamic> json) =>
      _$TopItemFromJson(json);
}

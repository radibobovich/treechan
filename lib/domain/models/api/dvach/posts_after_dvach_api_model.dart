// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:treechan/domain/models/api/posts_after_api_model.dart';

import 'error_dvach_api_model.dart';
import 'post_dvach_api_model.dart';

part '../../../../generated/domain/models/api/dvach/posts_after_dvach_api_model.g.dart';

@JsonSerializable()
class PostsAfterDvachApiModel implements PostsAfterApiModel {
  final List<PostDvachApiModel> posts;
  final int? result;
  final ErrorDvachApiModel? error;
  final int? unique_posters;
  PostsAfterDvachApiModel({
    required this.posts,
    this.result,
    this.error,
    this.unique_posters,
  });

  factory PostsAfterDvachApiModel.fromJson(Map<String, dynamic> json) =>
      _$PostsAfterDvachApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostsAfterDvachApiModelToJson(this);
}

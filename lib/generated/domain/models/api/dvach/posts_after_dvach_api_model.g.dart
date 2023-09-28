// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../../../domain/models/api/dvach/posts_after_dvach_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostsAfterDvachApiModel _$PostsAfterDvachApiModelFromJson(
        Map<String, dynamic> json) =>
    PostsAfterDvachApiModel(
      posts: (json['posts'] as List<dynamic>)
          .map((e) => PostDvachApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      result: json['result'] as int?,
      error: json['error'] == null
          ? null
          : ErrorDvachApiModel.fromJson(json['error'] as Map<String, dynamic>),
      unique_posters: json['unique_posters'] as int?,
    );

Map<String, dynamic> _$PostsAfterDvachApiModelToJson(
        PostsAfterDvachApiModel instance) =>
    <String, dynamic>{
      'posts': instance.posts,
      'result': instance.result,
      'error': instance.error,
      'unique_posters': instance.unique_posters,
    };

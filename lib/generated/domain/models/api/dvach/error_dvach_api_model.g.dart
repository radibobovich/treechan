// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../../../domain/models/api/dvach/error_dvach_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorDvachApiModel _$ErrorDvachApiModelFromJson(Map<String, dynamic> json) =>
    ErrorDvachApiModel(
      errorCode: json['errorCode'] as int,
      message: json['message'] as String,
    );

Map<String, dynamic> _$ErrorDvachApiModelToJson(ErrorDvachApiModel instance) =>
    <String, dynamic>{
      'errorCode': instance.errorCode,
      'message': instance.message,
    };

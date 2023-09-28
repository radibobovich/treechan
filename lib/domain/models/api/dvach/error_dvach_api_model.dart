import 'package:json_annotation/json_annotation.dart';

part '../../../../generated/domain/models/api/dvach/error_dvach_api_model.g.dart';

@JsonSerializable()
class ErrorDvachApiModel {
  final int errorCode;
  final String message;

  ErrorDvachApiModel({
    required this.errorCode,
    required this.message,
  });

  factory ErrorDvachApiModel.fromJson(Map<String, dynamic> json) =>
      _$ErrorDvachApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorDvachApiModelToJson(this);
}

  // * 0 NoError, ошибки нет.
  // * 403 ErrorForbidden, ошибка доступа.
  // * 666 ErrorInternal, внутренняя ошибка.
  // * 667 ErrorNotFound, используется для совместимости, если запрос не существует.

  // * -2 ErrorNoBoard, доска не существует.
  // * -3 ErrorNoParent, тред не существует.
  // * -31 ErrorNoPost, пост не существует.
  // * -4 ErrorNoAccess, контент существует, но у вас нет доступа.
  // * -41 ErrorBoardClosed, доска закрыта.
  // * -42 ErrorBoardOnlyVIP, доступ к доске возможен только с пасскодом.
  // * -5 ErrorCaptchaNotValid, капча не валидна.
  // * -6 ErrorBanned, вы были забанены. Сообщение содержит причину и номер бана.
  // * -7 ErrorThreadClosed, тред закрыт.
  // * -8 ErrorPostingToFast, вы постите слишком быстро ИЛИ установлен лимит на создание тредов на доске.
  // * -9 ErrorFieldTooBig, поле слишком большое. Например, комментарий превысил лимит.
  // * -10 ErrorFileSimilar, похожий файл уже был загружен.
  // * -11 ErrorFileNotSupported, файл не поддерживается.
  // * -12 ErrorFileTooBig, слишком большой файл.
  // * -13 ErrorFilesTooMuch, вы загрузили больше файлов, чем разрешено на доске.
  // * -14 ErrorTripBanned, трипкод был забанен.
  // * -15 ErrorWordBanned, в комментарии недопустимое выражение.
  // * -16 ErrorSpamList, в комментарии выражение из спамлиста.
  // * -19 ErrorEmptyOp, при создании треда необходимо загрузить файл.
  // * -20 ErrorEmptyPost, пост не может быть пустым, необходим комментарий/файл/etc.
  // * -21 ErrorPasscodeNotExist, пасскод не существует.
  // * -22 ErrorLimitReached, достигнут лимит запросов, попробуйте позже.
  // * -23 ErrorFieldTooSmall, слишком короткое сообщение. (используется в поиске).

  // * -50 ErrorReportTooManyPostsm, слишком много постов для жалобы.
  // * -51 ErrorReportEmpty, вы ничего не написали в жалобе.
  // * -52 ErrorReportExist, вы уже отправляли жалобу.

  // * -300 ErrorAppNotExist, приложение не существует или было отключено.
  // * -301 ErrorAppIDWrong, некорректный идентификатор приложения.
  // * -302 ErrorAppIDExpired, идентификатор приложения истёк.
  // * -303 ErrorAppIDSignature, неверная подпись поста с помощью идентификатора.
  // * -304 ErrorAppIDUsed, указанный идентификатор уже был использован.

  // * -24 ErrorWrongStickerID, некорректный идентификатор стикера.
  // * -25 ErrorStickerNotFound, стикер не найден.
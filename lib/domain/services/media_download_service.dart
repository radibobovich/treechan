import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gal/gal.dart';
import 'package:injectable/injectable.dart';
import 'package:treechan/config/local_notifications.dart';
import 'package:treechan/domain/imageboards/imageboard_specific.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/utils/constants/enums.dart';

@LazySingleton()
class MediaDownloadService {
  Future<void> downloadMedia(File file,
      {required Imageboard imageboard, bool notify = true}) async {
    if (ImageboardSpecific(imageboard).imageTypes.contains(file.type)) {
      await _downloadImage(file, notify);
    } else {
      await _downloadVideo(file, notify);
    }
  }

  _downloadImage(File file, bool notify) async {
    final name = file.fullName;
    final imagePath = '${io.Directory.systemTemp.path}/$name';
    await _downloadFile(file.path, imagePath, file.displayName, notify);
    await Gal.putImage(imagePath);
  }

  _downloadVideo(File file, bool notify) async {
    final name = file.fullName;
    final videoPath = '${io.Directory.systemTemp.path}/$name';
    await _downloadFile(file.path, videoPath, file.displayName, notify);
    await Gal.putVideo(videoPath);
  }

  _downloadFile(
      String url, String downloadPath, String displayName, bool notify) async {
    final progressService = DownloadProgressService();
    final id = url.hashCode;
    await Dio().download(
      url,
      downloadPath,
      onReceiveProgress: (count, total) {
        if (!notify) return;
        progressService.notify(
            100, ((count / total) * 100).toInt(), id, displayName);
      },
    ).whenComplete(() {
      if (!notify) return;
      progressService.complete(id, displayName);
    });
  }

  Future<void> downloadMultiple(List<File> files,
      {required Imageboard imageboard}) async {
    final progressService = DownloadProgressService();

    bool aborted = false;
    final stream = notificationActionBus.stream;
    stream.listen((event) {
      debugPrint('got event');
      if (event.type == NotificationActionType.cancel) {
        aborted = true;
      }
    });

    int index = 0;
    for (File file in files) {
      if (aborted) {
        debugPrint('download aborted');
        return;
      }
      progressService.notify(
          files.length, index, files.hashCode, 'Files: ${files.length}');
      await downloadMedia(file, imageboard: imageboard, notify: false);
      index += 1;
    }

    progressService.complete(
        files.hashCode, 'Files downloaded: ${files.length}');
  }
}

class DownloadProgressService {
  notify(int maxProgress, int progress, int id, String displayName) {
    FlutterLocalNotificationsPlugin().cancel(id);

    final androidDetails = AndroidNotificationDetails(
        downloadChannel, 'Download progress',
        channelDescription: 'Download progress',
        channelShowBadge: false,
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce: true,
        playSound: false,
        showProgress: true,
        maxProgress: maxProgress,
        progress: progress,
        actions: [const AndroidNotificationAction('cancel', 'Отмена')]);
    final platformDetails = NotificationDetails(android: androidDetails);
    FlutterLocalNotificationsPlugin()
        .show(id, 'Загрузка... ', displayName, platformDetails);
  }

  complete(int id, String displayName) {
    const androidDetails = AndroidNotificationDetails(
      downloadChannel,
      'Download finished',
      channelDescription: 'Download finished',
      channelShowBadge: false,
      importance: Importance.high,
      onlyAlertOnce: true,
      playSound: false,
    );
    const platformDetails = NotificationDetails(android: androidDetails);

    FlutterLocalNotificationsPlugin()
        .show(id, 'Загрузка завершена', displayName, platformDetails);

    // FlutterLocalNotificationsPlugin().cancel(id);
  }
}

const String downloadChannel = 'download';

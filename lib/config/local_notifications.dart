import 'dart:async';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:treechan/utils/constants/enums.dart';

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> initLocalNotifications() async {
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
          onDidReceiveLocalNotification: _onDidReceiveLocalNotification);

  const LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'Open notification');

  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse);

  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannelGroup(channelGroup);

  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannelGroup(personalChannelGroup);

  // await groupNotifications();
}

/// Fired when a notification is received
void _onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {}

/// Fired when a notification is clicked
_onDidReceiveNotificationResponse(
    NotificationResponse receivedNotificationResponse) {
  pushNotificationStreamController.add(PushUpdateNotification.fromJson(
      jsonDecode(receivedNotificationResponse.payload!)));
}

final StreamController<PushUpdateNotification>
    pushNotificationStreamController =
    StreamController<PushUpdateNotification>.broadcast();

const String _normalChannel = 'normal';

const String _personalChannel = 'personal';

// const String _group = 'mygroup';

AndroidNotificationDetails androidNormalGroupNotificationDetails =
    const AndroidNotificationDetails(
  _normalChannel,
  'Common notifications',
  setAsGroupSummary: true,
  // groupKey: group,
  playSound: false,
  // onlyAlertOnce: true,
);

NotificationDetails normalGroupNotificationDetails =
    NotificationDetails(android: androidNormalGroupNotificationDetails);

AndroidNotificationDetails androidGroupPersonalNotificationDetails =
    const AndroidNotificationDetails(
  _personalChannel,
  'Personal notifications',
  setAsGroupSummary: true,
  // groupKey: group,
  playSound: true,
  // onlyAlertOnce: true,
);

NotificationDetails personalGroupNotificationDetails =
    NotificationDetails(android: androidGroupPersonalNotificationDetails);

class PushUpdateNotification {
  final String type;
  final Imageboard imageboard;
  final String boardTag;
  final int id;
  final int? threadId;
  final String name;

  PushUpdateNotification(
      {required this.type,
      required this.imageboard,
      required this.boardTag,
      required this.id,
      required this.name,
      this.threadId});

  factory PushUpdateNotification.fromJson(Map<String, dynamic> json) {
    return PushUpdateNotification(
      type: json['type'],
      imageboard: imageboardFromString(json['imageboard']),
      boardTag: json['board_tag'],
      id: json['id'],
      threadId: json['thread_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'imageboard': imageboard.toString(),
      'board_tag': boardTag,
      'id': id,
      'thread_id': threadId,
      'name': name,
    };
  }
}

// AndroidNotificationChannelGroup channelGroup =
//     const AndroidNotificationChannelGroup(group, 'Main group');

// Future<void> groupNotifications() async {
//   List<ActiveNotification>? activeNotifications =
//       await flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>()
//           ?.getActiveNotifications();

//   if (activeNotifications != null && activeNotifications.isNotEmpty) {
//     List<String> lines =
//         activeNotifications.map((e) => e.title.toString()).toList();
//     InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
//       lines,
//       contentTitle: "${activeNotifications.length - 1} Updates",
//       summaryText: "${activeNotifications.length - 1} Updates",
//     );

//     androidNormalGroupNotificationDetails = AndroidNotificationDetails(
//       normalChannel,
//       'Common notifications',
//       styleInformation: inboxStyleInformation,
//       setAsGroupSummary: true,
//       groupKey: group,
//       playSound: false,
//       // onlyAlertOnce: true,
//     );
//     normalGroupNotificationDetails =
//         NotificationDetails(android: androidNormalGroupNotificationDetails);

//     androidGroupPersonalNotificationDetails = AndroidNotificationDetails(
//       personalChannel,
//       'Personal notifications',
//       styleInformation: inboxStyleInformation,
//       setAsGroupSummary: true,
//       groupKey: group,
//       playSound: true,
//       // onlyAlertOnce: true,
//     );

//     personalGroupNotificationDetails =
//         NotificationDetails(android: androidGroupPersonalNotificationDetails);
//   }
//   await flutterLocalNotificationsPlugin.show(
//       0, '', '', normalGroupNotificationDetails);
// }

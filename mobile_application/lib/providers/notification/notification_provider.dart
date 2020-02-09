import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

import 'package:http/http.dart' as http;

///
/// Firebase Cloud Messaging background routing
///
Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }
}

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}

class NotificationProvider with ChangeNotifier {
  FlutterLocalNotificationsPlugin localNotification;
  BehaviorSubject<ReceivedNotification> notificationController;
  FirebaseMessaging firebaseMessaging;

  void initialize() async {
    ///
    /// Flutter local notification initialization
    ///
    localNotification = FlutterLocalNotificationsPlugin();
    notificationController = BehaviorSubject<ReceivedNotification>();
    var androidSettings = AndroidInitializationSettings('app_icon');
    var iosSettings = IOSInitializationSettings(
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        notificationController.add(
          ReceivedNotification(
              id: id, title: title, body: body, payload: payload),
        );
      },
    );
    var initSettings = InitializationSettings(androidSettings, iosSettings);
    await localNotification.initialize(
      initSettings,
      onSelectNotification: (String payload) async {
        if (payload != null) {
          debugPrint('notification payload: ' + payload);
        }
        //selectNotificationSubject.add(payload);
      },
    );



    ///
    /// Initializing Firebase Cloud Messaging
    ///
    firebaseMessaging = FirebaseMessaging();
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  Future<String> get fcmToken async => await firebaseMessaging.getToken();

  Future<String> _downloadAndSaveImage(String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await http.get(url);
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<void> _showInboxNotification() async {
    var lines = List<String>();
    lines.add('line <b>1</b>');
    lines.add('line <i>2</i>');
    var inboxStyleInformation = InboxStyleInformation(lines,
        htmlFormatLines: true,
        contentTitle: 'overridden <b>inbox</b> context title',
        htmlFormatContentTitle: true,
        summaryText: 'summary <i>text</i>',
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'inbox channel id', 'inboxchannel name', 'inbox channel description',
        style: AndroidNotificationStyle.Inbox,
        styleInformation: inboxStyleInformation);
    var platformChannelSpecifics =
    NotificationDetails(androidPlatformChannelSpecifics, null);
    await localNotification.show(
        0, 'inbox title', 'inbox body', platformChannelSpecifics);
  }

  Future<void> _showNotificationMediaStyle(String url) async {
    var largeIconPath = await _downloadAndSaveImage(url, 'largeIcon');
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'media channel id',
      'media channel name',
      'media channel description',
      largeIcon: largeIconPath,
      largeIconBitmapSource: BitmapSource.FilePath,
      style: AndroidNotificationStyle.Media,
    );
    var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      null,
    );
    await localNotification.show(
        0, 'notification title', 'notification body', platformChannelSpecifics);
  }
}

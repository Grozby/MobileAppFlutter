import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

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
  static FlutterLocalNotificationsPlugin localNotification =
      FlutterLocalNotificationsPlugin();
  static BehaviorSubject<ReceivedNotification> notificationController;
  FirebaseMessaging firebaseMessaging;

  ///
  /// Flutter local notification initialization
  ///
  static Future<void> initializeLocalNotification(
      {void Function() callback}) async {
    notificationController = BehaviorSubject<ReceivedNotification>();
    var androidSettings = AndroidInitializationSettings('app_icon');
    var iosSettings = IOSInitializationSettings(
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        notificationController.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
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
    if (callback != null) callback();
  }

  Future<void> initialize() async {
    await initializeLocalNotification();

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

  ///
  /// Firebase Cloud Messaging background routing
  ///
  static Future<dynamic> myBackgroundMessageHandler(
    Map<String, dynamic> message,
  ) async {
    if (message.containsKey('data')) {
      print("hereee");
      await initializeLocalNotification();
      _showNotificationMediaStyle(message['data'] as Map<String, dynamic>);
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
      await initializeLocalNotification();
    }

    return Future<void>.value();
  }

  Future<String> get fcmToken async => await firebaseMessaging.getToken();

  static Future<String> _downloadAndSaveImage(
      String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await http.get(url);
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static Future<void> _showInboxNotification(
    Map<String, dynamic> payload,
  ) async {
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

  static Future<void> _showNotificationMediaStyle(
    Map<String, dynamic> payload,
  ) async {
    var largeIconPath = await _downloadAndSaveImage(
      payload['image'],
      'largeIcon',
    );
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
      0,
      payload["title"],
      payload["body"],
      platformChannelSpecifics,
    );
  }
}

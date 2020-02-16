import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/io_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ryfy/providers/configuration.dart';

class ReceivedNotification {
  final int id;
  final dynamic payload;

  ReceivedNotification({
    @required this.id,
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
        notificationController.add(
          ReceivedNotification(
            id: message["id"],
            payload: message["data"],
          ),
        );
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
      await initializeLocalNotification();
      showNotificationMediaStyle(message['data']);
    }

    return Future<void>.value();
  }

  Future<String> get fcmToken async => await firebaseMessaging.getToken();

  static Future<String> _downloadAndSaveImage(
    String url,
    String fileName,
  ) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(httpClient);

    String actualUrl =
        url.startsWith('assets') ? "${Configuration.serverUrl}/$url" : url;

    var response = await ioClient.get(actualUrl);
    ioClient.close();
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
      'inbox channel id',
      'inboxchannel name',
      'inbox channel description',
      style: AndroidNotificationStyle.Inbox,
      styleInformation: inboxStyleInformation,
    );
    var platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, null);
    await localNotification.show(
      0,
      'inbox title',
      'inbox body',
      platformChannelSpecifics,
    );
  }

  static Future<void> showNotificationMediaStyle(dynamic payload) async {
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
      priority: Priority.Max,
      importance: Importance.Max,
    );
    var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      null,
    );
    await localNotification.show(
      int.tryParse(payload["id"]),
      payload["title"],
      payload["body"],
      platformChannelSpecifics,
    );
  }
}

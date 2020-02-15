import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:ryfy/models/chat/contact_mentor.dart';
import 'package:ryfy/providers/authentication/authentication_provider.dart';
import 'package:ryfy/providers/chat/chat_provider.dart';
import 'package:ryfy/providers/database/database_provider.dart';
import 'package:ryfy/providers/notification/notification_provider.dart';
import 'package:socket_io_client/src/manager.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:sqflite/sqflite.dart';
import 'package:test/test.dart';

class MockDio extends Mock implements Dio {
  Interceptors get interceptors => Interceptors();
}

class MockDatabaseProvider extends Mock implements DatabaseProvider {}

class MockDatabase extends Mock implements Database {}

class MockBatch extends Mock implements Batch {}

class MockSocket extends Mock implements Socket {}

void main() {
  group("Unit Test ChatProvider", () {
    String currentDatabaseFilename;
    String currentRequestFilename;
    MockDio httpManager = MockDio();
    AuthenticationProvider authenticationProvider =
        AuthenticationProvider(httpManager);

    when(httpManager.get("/users/userid", options: null)).thenAnswer(
      (_) async => Response(data: {"id": "IdBello"}, statusCode: 200),
    );
    when(httpManager.get("/users/contactrequest")).thenAnswer(
      (_) async => await File(currentRequestFilename)
          .readAsString()
          .then((fileContents) async => await jsonDecode(fileContents))
          .then(
            (l) => l
                .map<Map<String, dynamic>>((e) => e as Map<String, dynamic>)
                .toList(),
          )
          .then(
            (data) => Response(data: data, statusCode: 200),
          ),
    );
    //Socket mock
    Map<String, dynamic> eventsHandler = {};
    MockSocket socket = MockSocket();
    when(socket.connect()).thenAnswer((_) {
      return;
    });
    when(socket.hasListeners(any)).thenAnswer((_) => false);
    when(socket.on(any, any)).thenAnswer((invocation) {
      eventsHandler[invocation.positionalArguments[0]] =
          invocation.positionalArguments[1];
    });

    MockDatabase database = MockDatabase();
    when(database.query(DatabaseProvider.contactsTableName))
        .thenAnswer((_) async {
      return File(currentDatabaseFilename)
          .readAsString()
          .then((fileContents) async => await jsonDecode(fileContents))
          .then((l) => l
              .map<Map<String, dynamic>>((e) => {
                    "id": e["id"],
                    "json": jsonEncode(e),
                  })
              .toList());
    });
    when(database.query(
      DatabaseProvider.messagesTableName,
      columns: ['id', 'json'],
      where: '"contact_id" = ?',
      whereArgs: anyNamed("whereArgs"),
      orderBy: "date DESC",
    )).thenAnswer((_) async {
      return Future.value(<Map<String, dynamic>>[]);
    });
    MockBatch batch = MockBatch();
    when(database.batch()).thenAnswer((_) {
      return batch;
    });
    when(batch.insert(any, any)).thenAnswer((_) async {});
    when(batch.commit(noResult: anyNamed("noResult"))).thenAnswer((_) async {
      return;
    });

    MockDatabaseProvider databaseProvider = MockDatabaseProvider();
    when(databaseProvider.deleteContent()).thenAnswer((_) async {
      return;
    });
    when(databaseProvider.getDatabase()).thenAnswer((_) async {
      return Future.value(database);
    });

    test('Stored data not present in request, so they are deleted', () async {
      currentRequestFilename =
          'test/providers/chat_provider_test/contact_mentor_request_example1.json';
      currentDatabaseFilename =
          'test/providers/chat_provider_test/contact_mentor_database_example1.json';

      ChatProvider chatProvider = ChatProvider(
        httpRequestWrapper: authenticationProvider.httpRequestWrapper,
        databaseProvider: databaseProvider,
        fcmToken: "FcmToken",
      );
      chatProvider.socket = socket;

      await chatProvider.initializeChatProvider(
        authToken: "TokenBello",
        pushNotificationStream:
            StreamController<ReceivedNotification>.broadcast().stream,
      );

      expect(chatProvider.userId, "IdBello");
      expect(chatProvider.contacts[0].answers[0].question, "16 18?");
      verify(httpManager.get("/users/userid", options: null)).called(1);
      verify(httpManager.get("/users/contactrequest")).called(1);

      eventsHandler.clear();
    });

    test('New data in request, so added to local db', () async {
      currentRequestFilename =
          'test/providers/chat_provider_test/contact_mentor_request_example2.json';
      currentDatabaseFilename =
          'test/providers/chat_provider_test/contact_mentor_database_example2.json';

      ChatProvider chatProvider = ChatProvider(
        httpRequestWrapper: authenticationProvider.httpRequestWrapper,
        databaseProvider: databaseProvider,
        fcmToken: "FcmToken",
      );
      chatProvider.socket = socket;

      await chatProvider.initializeChatProvider(
        authToken: "TokenBello",
        pushNotificationStream:
            StreamController<ReceivedNotification>.broadcast().stream,
      );

      expect(chatProvider.userId, "IdBello");
      expect(chatProvider.contacts[0].id, "5e4487449865b31a501a8405");
      expect(chatProvider.contacts[1].id, "5e4487449865b31a501a8406");
      expect(chatProvider.contacts[0].answers[0].question, "15 18?");
      expect(chatProvider.contacts[1].answers[0].question, "16 18?");
      verify(httpManager.get("/users/userid", options: null)).called(1);
      verify(httpManager.get("/users/contactrequest")).called(1);

      eventsHandler.clear();
    });

    test('Socket connect event', () async {
      currentRequestFilename =
          'test/providers/chat_provider_test/contact_mentor_request_example1.json';
      currentDatabaseFilename =
          'test/providers/chat_provider_test/contact_mentor_database_example1.json';

      ChatProvider chatProvider = ChatProvider(
        httpRequestWrapper: authenticationProvider.httpRequestWrapper,
        databaseProvider: databaseProvider,
        fcmToken: "FcmToken",
      );
      chatProvider.socket = socket;

      expect(chatProvider.isConnected, false);

      await chatProvider.initializeChatProvider(
        authToken: "TokenBello",
        pushNotificationStream:
            StreamController<ReceivedNotification>.broadcast().stream,
      );

      eventsHandler["connect"](null);
      expect(chatProvider.isConnected, true);

      eventsHandler.clear();
    });

    test('Socket connect then disconnect event', () async {
      currentRequestFilename =
          'test/providers/chat_provider_test/contact_mentor_request_example1.json';
      currentDatabaseFilename =
          'test/providers/chat_provider_test/contact_mentor_database_example1.json';

      ChatProvider chatProvider = ChatProvider(
        httpRequestWrapper: authenticationProvider.httpRequestWrapper,
        databaseProvider: databaseProvider,
        fcmToken: "FcmToken",
      );
      chatProvider.socket = socket;

      expect(chatProvider.isConnected, false);

      await chatProvider.initializeChatProvider(
        authToken: "TokenBello",
        pushNotificationStream:
            StreamController<ReceivedNotification>.broadcast().stream,
      );

      await eventsHandler["connect"](null);
      expect(chatProvider.isConnected, true);

      await eventsHandler["disconnect"](null);
      expect(chatProvider.isConnected, false);

      eventsHandler.clear();
    });

    test('Socket connect then error event', () async {
      currentRequestFilename =
          'test/providers/chat_provider_test/contact_mentor_request_example1.json';
      currentDatabaseFilename =
          'test/providers/chat_provider_test/contact_mentor_database_example1.json';

      ChatProvider chatProvider = ChatProvider(
        httpRequestWrapper: authenticationProvider.httpRequestWrapper,
        databaseProvider: databaseProvider,
        fcmToken: "FcmToken",
      );
      chatProvider.socket = socket;

      expect(chatProvider.isConnected, false);

      await chatProvider.initializeChatProvider(
        authToken: "TokenBello",
        pushNotificationStream:
            StreamController<ReceivedNotification>.broadcast().stream,
      );

      await eventsHandler["connect"](null);
      expect(chatProvider.isConnected, true);

      await eventsHandler["disconnect"](null);
      expect(chatProvider.isConnected, false);

      eventsHandler.clear();
    });

    test('Socket other user is online', () async {
      currentRequestFilename =
          'test/providers/chat_provider_test/contact_mentor_request_example1.json';
      currentDatabaseFilename =
          'test/providers/chat_provider_test/contact_mentor_database_example1.json';

      ChatProvider chatProvider = ChatProvider(
        httpRequestWrapper: authenticationProvider.httpRequestWrapper,
        databaseProvider: databaseProvider,
        fcmToken: "FcmToken",
      );
      chatProvider.socket = socket;

      expect(chatProvider.isConnected, false);

      await chatProvider.initializeChatProvider(
        authToken: "TokenBello",
        pushNotificationStream:
            StreamController<ReceivedNotification>.broadcast().stream,
      );

      await eventsHandler["connect"](null);
      expect(chatProvider.isConnected, true);

      await eventsHandler["online"]({
        "userId": "NotOurUserId",
        "chatId": "5e4487449865b31a501a8406",
      });

      var isOnline = await chatProvider
          .getOnlineStatusStream("5e4487449865b31a501a8406")
          .first;
      expect(isOnline, true);

      eventsHandler.clear();
    });

    test('Socket other user is online, then offline', () async {
      currentRequestFilename =
          'test/providers/chat_provider_test/contact_mentor_request_example1.json';
      currentDatabaseFilename =
          'test/providers/chat_provider_test/contact_mentor_database_example1.json';

      ChatProvider chatProvider = ChatProvider(
        httpRequestWrapper: authenticationProvider.httpRequestWrapper,
        databaseProvider: databaseProvider,
        fcmToken: "FcmToken",
      );
      chatProvider.socket = socket;

      expect(chatProvider.isConnected, false);

      await chatProvider.initializeChatProvider(
        authToken: "TokenBello",
        pushNotificationStream:
            StreamController<ReceivedNotification>.broadcast().stream,
      );

      await eventsHandler["connect"](null);
      expect(chatProvider.isConnected, true);

      await eventsHandler["online"]({
        "userId": "NotOurUserId",
        "chatId": "5e4487449865b31a501a8406",
      });

      var isOnline = await chatProvider
          .getOnlineStatusStream("5e4487449865b31a501a8406")
          .first;
      expect(isOnline, true);

      await eventsHandler["offline"]({
        "userId": "NotOurUserId",
        "chatId": "5e4487449865b31a501a8406",
      });

      isOnline = await chatProvider
          .getOnlineStatusStream("5e4487449865b31a501a8406")
          .first;
      expect(isOnline, false);

      eventsHandler.clear();
    });

    test('Socket other user is typing + timeout typing', () async {
      currentRequestFilename =
          'test/providers/chat_provider_test/contact_mentor_request_example1.json';
      currentDatabaseFilename =
          'test/providers/chat_provider_test/contact_mentor_database_example1.json';

      ChatProvider chatProvider = ChatProvider(
        httpRequestWrapper: authenticationProvider.httpRequestWrapper,
        databaseProvider: databaseProvider,
        fcmToken: "FcmToken",
      );
      chatProvider.socket = socket;

      expect(chatProvider.isConnected, false);

      await chatProvider.initializeChatProvider(
        authToken: "TokenBello",
        pushNotificationStream:
            StreamController<ReceivedNotification>.broadcast().stream,
      );

      await eventsHandler["connect"](null);
      expect(chatProvider.isConnected, true);

      await eventsHandler["online"]({
        "userId": "NotOurUserId",
        "chatId": "5e4487449865b31a501a8406",
      });

      var isOnline = await chatProvider
          .getOnlineStatusStream("5e4487449865b31a501a8406")
          .first;
      expect(isOnline, true);

      await eventsHandler["typing"]({
        "userId": "NotOurUserId",
        "chatId": "5e4487449865b31a501a8406",
      });

      var isTyping = await chatProvider
          .getTypingNotificationStream("5e4487449865b31a501a8406")
          .first;
      expect(isTyping, true);

      await Future.delayed(Duration(seconds: 3));

      isTyping = await chatProvider
          .getTypingNotificationStream("5e4487449865b31a501a8406")
          .first;
      expect(isTyping, false);

      eventsHandler.clear();
    });

    test('Socket get message', () async {
      currentRequestFilename =
          'test/providers/chat_provider_test/contact_mentor_request_example1.json';
      currentDatabaseFilename =
          'test/providers/chat_provider_test/contact_mentor_database_example1.json';

      ChatProvider chatProvider = ChatProvider(
        httpRequestWrapper: authenticationProvider.httpRequestWrapper,
        databaseProvider: databaseProvider,
        fcmToken: "FcmToken",
      );
      chatProvider.socket = socket;

      expect(chatProvider.isConnected, false);

      await chatProvider.initializeChatProvider(
        authToken: "TokenBello",
        pushNotificationStream:
            StreamController<ReceivedNotification>.broadcast().stream,
      );

      await eventsHandler["connect"](null);
      expect(chatProvider.isConnected, true);

      expect(chatProvider.contacts[0].messages.length, 1);

      await eventsHandler["message"]({
        "userId": "NotOurUserId",
        "chatId": "5e4487449865b31a501a8406",
        "_id": "5e4530cb6c82b10ce011804d",
        "isRead": false,
        "kind": "text",
        "createdAt": "2020-02-13T11:19:39.352Z",
        "content": "Ciao!"
      });

      expect(chatProvider.contacts[0].messages.length, 2);
      expect(chatProvider.contacts[0].messages[0].content, "Ciao!");
      expect(chatProvider.contacts[0].messages[0].userId, "NotOurUserId");

      eventsHandler.clear();
    });

    test('Updated contact request status', () async {
      currentRequestFilename =
          'test/providers/chat_provider_test/contact_mentor_request_example3.json';
      currentDatabaseFilename =
          'test/providers/chat_provider_test/contact_mentor_database_example3.json';

      ChatProvider chatProvider = ChatProvider(
        httpRequestWrapper: authenticationProvider.httpRequestWrapper,
        databaseProvider: databaseProvider,
        fcmToken: "FcmToken",
      );
      chatProvider.socket = socket;

      expect(chatProvider.isConnected, false);

      await chatProvider.initializeChatProvider(
        authToken: "TokenBello",
        pushNotificationStream:
            StreamController<ReceivedNotification>.broadcast().stream,
      );

      await eventsHandler["connect"](null);
      expect(chatProvider.isConnected, true);

      expect(chatProvider.contacts[0].status, StatusRequest.pending);

      await eventsHandler["updated_contact_request"]({
        "chatId": "5e4487449865b31a501a8406",
        "status": "accepted",
      });

      expect(chatProvider.contacts[0].status, StatusRequest.accepted);
      expect(chatProvider.contacts[0].messages.length, 1);

      eventsHandler.clear();
    });
  });
}

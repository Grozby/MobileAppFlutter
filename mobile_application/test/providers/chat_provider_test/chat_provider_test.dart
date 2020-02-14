import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:ryfy/providers/authentication/authentication_provider.dart';
import 'package:ryfy/providers/chat/chat_provider.dart';
import 'package:ryfy/providers/database/database_provider.dart';
import 'package:ryfy/providers/notification/notification_provider.dart';
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
    MockSocket socket = MockSocket();
    when(socket.connect()).thenAnswer((_) {
      return;
    });
    when(socket.hasListeners(any)).thenAnswer((_) => true);

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
    });
  });
}

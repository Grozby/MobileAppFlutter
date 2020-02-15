import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:ryfy/models/exceptions/no_user_profile_exception.dart';
import 'package:ryfy/models/exceptions/something_went_wrong_exception.dart';
import 'package:ryfy/models/users/user.dart';
import 'package:ryfy/providers/authentication/authentication_provider.dart';
import 'package:ryfy/providers/database/database_provider.dart';
import 'package:ryfy/providers/user/user_data_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:test/test.dart';

class MockDio extends Mock implements Dio {
  Interceptors get interceptors => Interceptors();
}

class MockDatabaseProvider extends Mock implements DatabaseProvider {}

class MockDatabase extends Mock implements Database {}

void main() {
  MockDio httpManager = MockDio();
  AuthenticationProvider authenticationProvider =
      AuthenticationProvider(httpManager);

  MockDatabase database = MockDatabase();
  when(database.query(DatabaseProvider.contactsTableName))
      .thenAnswer((_) async {
    return File(
            'test/providers/user_data_provider_test/user_database_example1.json')
        .readAsString()
        .then((fileContents) async => await jsonDecode(fileContents))
        .then((l) => l
            .map<Map<String, dynamic>>((e) => {
                  "id": e["_id"],
                  "kind": "Mentee",
                  "json": e,
                })
            .toList());
  });
  when(database.insert(
    any,
    any,
    conflictAlgorithm: anyNamed("conflictAlgorithm"),
  )).thenAnswer((_) async {
    return;
  });

  MockDatabaseProvider databaseProvider = MockDatabaseProvider();
  when(databaseProvider.getDatabase()).thenAnswer((_) async {
    return Future.value(database);
  });

  group('Unit Test UserDataProvider', () {
    test("Initialization", () async {
      UserDataProvider userDataProvider = UserDataProvider(
        httpRequestWrapper: authenticationProvider.httpRequestWrapper,
        databaseProvider: databaseProvider,
      );

      expect(userDataProvider.behavior, null);
    });

    test("Get user from request", () async {
      when(httpManager.get("/users/profile")).thenAnswer(
        (_) async => Response(
          data: await File(
                  'test/providers/user_data_provider_test/user_database_example1.json')
              .readAsString()
              .then((fileContents) async => await jsonDecode(fileContents)[0]),
          statusCode: 200,
        ),
      );

      UserDataProvider userDataProvider = UserDataProvider(
        httpRequestWrapper: authenticationProvider.httpRequestWrapper,
        databaseProvider: databaseProvider,
      );

      expect(userDataProvider.behavior, null);

      await userDataProvider.loadUserData();

      expect(userDataProvider.behavior.user.name, "Bobberino");
      expect(userDataProvider.behavior.user.id, "5e25a28b249f1c04fc51a07e");
    });

    test("Get user from failed request", () async {
      when(httpManager.get("/users/profile")).thenAnswer(
        (_) async => Response(
          data: await File(
                  'test/providers/user_data_provider_test/user_database_example1.json')
              .readAsString()
              .then((fileContents) async => await jsonDecode(fileContents)[0]),
          statusCode: 400,
        ),
      );

      UserDataProvider userDataProvider = UserDataProvider(
        httpRequestWrapper: authenticationProvider.httpRequestWrapper,
        databaseProvider: databaseProvider,
      );

      expect(userDataProvider.behavior, null);

      try {
        await userDataProvider.loadUserData();
      } on SomethingWentWrongException {
        expect(userDataProvider.behavior, null);
        return;
      }

      //If drops here the test is failed
      expect(1, 0);
    });

    test("Get other user from request", () async {
      when(httpManager.get("/users/profile/5e25a28b249f1c04fc51a07e"))
          .thenAnswer(
        (_) async => Response(
          data: await File(
                  'test/providers/user_data_provider_test/user_database_example1.json')
              .readAsString()
              .then((fileContents) async => await jsonDecode(fileContents)[0]),
          statusCode: 200,
        ),
      );

      UserDataProvider userDataProvider = UserDataProvider(
        httpRequestWrapper: authenticationProvider.httpRequestWrapper,
        databaseProvider: databaseProvider,
      );

      User otherUser = await userDataProvider
          .loadSpecifiedUserData("5e25a28b249f1c04fc51a07e");

      expect(otherUser, isNotNull);
      expect(otherUser.id, "5e25a28b249f1c04fc51a07e");
    });

    test("Get other user from failed request", () async {
      when(httpManager.get("/users/profile/5e25a28b249f1c04fc51a07e"))
          .thenAnswer(
        (_) async => Response(statusCode: 400),
      );

      UserDataProvider userDataProvider = UserDataProvider(
        httpRequestWrapper: authenticationProvider.httpRequestWrapper,
        databaseProvider: databaseProvider,
      );

      User otherUser;
      try {
        otherUser = await userDataProvider
            .loadSpecifiedUserData("5e25a28b249f1c04fc51a07e");
      } on SomethingWentWrongException {
        expect(otherUser, null);
        return;
      }

      expect(1, 0);
    });

    test("Get other user from request, but no user is present", () async {
      when(httpManager.get("/users/profile/NoUserPresent"))
          .thenAnswer((_) async => Response(statusCode: 200));

      UserDataProvider userDataProvider = UserDataProvider(
        httpRequestWrapper: authenticationProvider.httpRequestWrapper,
        databaseProvider: databaseProvider,
      );

      User otherUser;
      try {
        otherUser =
            await userDataProvider.loadSpecifiedUserData("NoUserPresent");
      } on NoUserProfileException {
        expect(otherUser, null);
        return;
      }

      expect(1, 0);
    });

    test("Update user", () async {
      when(httpManager.get("/users/profile")).thenAnswer(
        (_) async => Response(
          data: await File(
                  'test/providers/user_data_provider_test/user_database_example1.json')
              .readAsString()
              .then((fileContents) async => await jsonDecode(fileContents)[0]),
          statusCode: 200,
        ),
      );
      when(httpManager.patch(
        "/users/profile",
        data: anyNamed("data"),
        options: anyNamed("options"),
      )).thenAnswer(
        (_) async => Response(
          data: await File(
                  'test/providers/user_data_provider_test/user_database_example1.json')
              .readAsString()
              .then((fileContents) async =>
                  await jsonDecode(fileContents)[0] as Map<String, dynamic>)
              .then((Map<String, dynamic> map) {
            map["pastExperiences"] = [];
            return map;
          }),
          statusCode: 200,
        ),
      );

      UserDataProvider userDataProvider = UserDataProvider(
        httpRequestWrapper: authenticationProvider.httpRequestWrapper,
        databaseProvider: databaseProvider,
      );

      expect(userDataProvider.behavior, null);

      await userDataProvider.loadUserData();

      expect(userDataProvider.behavior.user.name, "Bobberino");
      expect(userDataProvider.behavior.user.id, "5e25a28b249f1c04fc51a07e");
      expect(userDataProvider.behavior.user.academicExperiences.length, 2);

      await userDataProvider.patchUserData({});
      expect(userDataProvider.behavior.user.academicExperiences.length, 0);
    });
  });
}

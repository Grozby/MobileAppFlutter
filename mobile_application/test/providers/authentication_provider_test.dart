import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:ryfy/providers/authentication/authentication_provider.dart';
import 'package:ryfy/providers/database/database_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

class MockDio extends Mock implements Dio {
  Interceptors get interceptors => Interceptors();
}

class MockDatabaseProvider extends Mock implements DatabaseProvider {}

void main() {
  group('Unit Test AuthenticationProvider', () {
    test('not logged at creation', () {
      expect(AuthenticationProvider(MockDio()).isLogged, false);
    });

    test('no token at creation', () {
      var authenticationProvider = AuthenticationProvider(MockDio());
      expect(authenticationProvider.gotAToken(), false);
      expect(authenticationProvider.token, null);
    });

    test('loading stored login information', () async {
      SharedPreferences.setMockInitialValues({
        "loginData": jsonEncode({
          "type": "credentials",
          "token": "UnTokenBello",
        }),
      });

      var authenticationProvider = AuthenticationProvider(MockDio());
      await authenticationProvider.loadAuthentication();

      expect(authenticationProvider.isLogged, true);
      expect(authenticationProvider.wasLogged, false);
      expect(authenticationProvider.gotAToken(), true);
      expect(authenticationProvider.token, "UnTokenBello");
    });

    test('loading stored login information, then logout', () async {
      SharedPreferences.setMockInitialValues({
        "loginData": jsonEncode({
          "type": "credentials",
          "token": "UnTokenBello",
        }),
      });
      MockDatabaseProvider databaseProvider = MockDatabaseProvider();
      when(databaseProvider.deleteContent()).thenAnswer((_) {
        return;
      });

      var authenticationProvider = AuthenticationProvider(
        MockDio(),
        databaseProvider: databaseProvider,
      );
      await authenticationProvider.loadAuthentication();

      await authenticationProvider.logout();

      var sharedPreferences = await SharedPreferences.getInstance();

      expect(authenticationProvider.isLogged, false);
      expect(authenticationProvider.wasLogged, false);
      expect(authenticationProvider.gotAToken(), false);
      expect(authenticationProvider.token, null);
      expect(sharedPreferences.containsKey("loginData"), false);
    });

    test('loading stored login information, then save it', () async {
      SharedPreferences.setMockInitialValues({
        "loginData": jsonEncode({
          "type": "credentials",
          "token": "UnTokenBello",
        }),
      });
      MockDatabaseProvider databaseProvider = MockDatabaseProvider();
      when(databaseProvider.deleteContent()).thenAnswer((_) {
        return;
      });

      var authenticationProvider = AuthenticationProvider(
        MockDio(),
        databaseProvider: databaseProvider,
      );
      await authenticationProvider.loadAuthentication();

      await authenticationProvider.saveAuthenticationData();

      var sharedPreferences = await SharedPreferences.getInstance();

      expect(authenticationProvider.isLogged, true);
      expect(authenticationProvider.wasLogged, false);
      expect(authenticationProvider.gotAToken(), true);
      expect(authenticationProvider.token, "UnTokenBello");
      expect(sharedPreferences.containsKey("loginData"), true);
      var storedData = jsonDecode(sharedPreferences.getString('loginData'));
      expect(storedData["type"], "credentials");
      expect(storedData["token"], "UnTokenBello");
    });

    test('check authentication without no data', () async {
      SharedPreferences.setMockInitialValues({
        "loginData": jsonEncode({
          "type": "credentials",
          "token": "UnTokenBello",
        }),
      });

      var authenticationProvider = AuthenticationProvider(MockDio());

      var isLogged = await authenticationProvider.checkAuthentication();

      expect(isLogged, false);
      expect(authenticationProvider.isLogged, false);
      expect(authenticationProvider.wasLogged, false);
      expect(authenticationProvider.gotAToken(), false);
      expect(authenticationProvider.token, null);
    });

    test(
      'loading stored login information, then check authentication with successful response',
      () async {
        SharedPreferences.setMockInitialValues({
          "loginData": jsonEncode({
            "type": "credentials",
            "token": "UnTokenBello",
          }),
        });
        MockDatabaseProvider databaseProvider = MockDatabaseProvider();
        MockDio httpManager = MockDio();
        var authenticationProvider = AuthenticationProvider(
          httpManager,
          databaseProvider: databaseProvider,
        );

        when(httpManager.get("/auth/checkauth", options: null)).thenAnswer(
          (_) async => Response(statusCode: 200),
        );

        await authenticationProvider.loadAuthentication();
        var auth = await authenticationProvider.checkAuthentication();

        expect(authenticationProvider.isLogged, true);
        expect(authenticationProvider.wasLogged, false);
        expect(authenticationProvider.gotAToken(), true);
        expect(authenticationProvider.token, "UnTokenBello");
        expect(auth, true);
      },
    );

    test(
      'loading stored login information, then check authentication with unsuccessful response',
      () async {
        SharedPreferences.setMockInitialValues({
          "loginData": jsonEncode({
            "type": "credentials",
            "token": "UnTokenBello",
          }),
        });
        MockDatabaseProvider databaseProvider = MockDatabaseProvider();
        MockDio httpManager = MockDio();
        when(httpManager.get("/auth/checkauth", options: null)).thenAnswer(
          (_) async => Response(statusCode: 401),
        );

        var authenticationProvider = AuthenticationProvider(
          httpManager,
          databaseProvider: databaseProvider,
        );

        when(databaseProvider.deleteContent()).thenAnswer((_) {
          return;
        });

        await authenticationProvider.loadAuthentication();
        var auth = await authenticationProvider.checkAuthentication();

        var sharedPreferences = await SharedPreferences.getInstance();

        expect(authenticationProvider.isLogged, false);
        expect(authenticationProvider.wasLogged, false);
        expect(authenticationProvider.gotAToken(), false);
        expect(authenticationProvider.token, null);
        expect(sharedPreferences.containsKey("loginData"), false);
        expect(auth, false);
      },
    );

    test('login with credentials', () async {
      SharedPreferences.setMockInitialValues({"c": "a"});
      MockDatabaseProvider databaseProvider = MockDatabaseProvider();
      MockDio httpManager = MockDio();
      when(httpManager.post(
        any,
        data: anyNamed("data"),
        options: anyNamed("options"),
      )).thenAnswer(
        (_) async => Response(
          data: {"access_token": "MaE'Bob"},
          statusCode: 200,
        ),
      );

      var authenticationProvider = AuthenticationProvider(
        httpManager,
        databaseProvider: databaseProvider,
      );

      when(databaseProvider.deleteContent()).thenAnswer((_) {
        return;
      });

      await authenticationProvider.authenticate({
        "email": "BobRoss",
        "password": "SuperBob",
      });

      var sharedPreferences = await SharedPreferences.getInstance();

      expect(authenticationProvider.isLogged, true);
      expect(authenticationProvider.wasLogged, false);
      expect(authenticationProvider.gotAToken(), true);
      expect(authenticationProvider.token, "MaE'Bob");
      expect(sharedPreferences.containsKey("loginData"), true);
      var storedData = jsonDecode(sharedPreferences.getString('loginData'));
      expect(storedData["type"], "credentials");
      expect(storedData["token"], "MaE'Bob");
    });
  });
}

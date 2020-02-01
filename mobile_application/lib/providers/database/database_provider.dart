import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider with ChangeNotifier {
  static const String databaseName = 'mobileAppDB.db';
  static const String contactsTableName = 'contacts';
  static const String messagesTableName = 'messages';

  Database _database;

  Future<Database> getDatabase() async {
    Sqflite.setDebugModeOn();

    if (_database == null) {
      var databasesPath = await getDatabasesPath();
      var path = join(databasesPath, databaseName);

      try {
        await Directory(databasesPath).create(recursive: true);
      } catch (_) {}

      _database = await openDatabase(
        path,
        onOpen: (database) {
          print("yay");
        },
        onCreate: (database, version) async {
          await database.execute("""CREATE TABLE ${contactsTableName}(
            id TEXT PRIMARY KEY,
            json TEXT
          )""");

          await database.execute("""CREATE TABLE ${messagesTableName}(
            id TEXT PRIMARY KEY,
            contact_id TEXT,
            json TEXT,
            int date
          )""");
        },
        version: 1,
      );
    }

    return await _database;
  }

  Future close() async => (await _database).close();
}

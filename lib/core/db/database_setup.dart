import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseSetup {
  static Future<Database>? _database;

  static Future<Database> getDatabase() async {
    return await _database!;
  }

  static Future<void> setup() async {
    _database = openDatabase(
      join(await getDatabasesPath(), 'local_1.db'),
      onCreate: (db, version) {
        return db.execute(
          '''
            CREATE TABLE collaborators(
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              uuid TEXT NOT NULL,
              name TEXT NOT NULL,
              email TEXT NOT NULL,
              createdAt INTEGER NOT NULL,
              createdBy TEXT NOT NULL,
              modifiedAt INTEGER NOT NULL,
              modifiedBy TEXT NOT NULL
            );
            CREATE UNIQUE INDEX idx_collaborators_uuid
            ON collaborators (uuid);

            CREATE TABLE customers(
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              uuid TEXT NOT NULL,
              name TEXT NOT NULL,
              email TEXT NOT NULL,
              createdAt INTEGER NOT NULL,
              createdBy TEXT NOT NULL,
              modifiedAt INTEGER NOT NULL,
              modifiedBy TEXT NOT NULL
            );
            CREATE UNIQUE INDEX idx_customers_uuid
            ON customers (uuid);
          ''',
        );
      },
      version: 1,
    );
  }
}

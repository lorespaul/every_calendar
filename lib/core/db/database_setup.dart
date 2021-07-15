import 'package:every_calendar/core/db/database_manager.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseSetup {
  static Future<Database>? _database;
  static String? _context;

  static Future<Database> getDatabase() async {
    return await _database!;
  }

  static String getContext() {
    return _context!;
  }

  static Future<void> setup(
    String tenant,
    String Function() getOwner,
    String Function() getDevice,
  ) async {
    DatabaseManager.getOwner = getOwner;
    DatabaseManager.getDevice = getDevice;
    var owner = getOwner();
    _context = tenant;
    _database = openDatabase(
      join(await getDatabasesPath(), '$owner-$tenant.db'),
      onCreate: (db, version) async {
        await db.execute(
          '''
            CREATE TABLE collaborators(
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              uuid TEXT NOT NULL,
              name TEXT NOT NULL,
              email TEXT NOT NULL,
              createdAt INTEGER NOT NULL,
              createdBy TEXT NOT NULL,
              modifiedAt INTEGER NOT NULL,
              modifiedBy TEXT NOT NULL,
              deletedAt INTEGER NULL,
              deletedBy TEXT NULL,
              modifiedByDevice TEXT NULL
            );
          ''',
        );

        await db.execute(
          '''
            CREATE UNIQUE INDEX idx_collaborators_uuid
            ON collaborators (uuid);
          ''',
        );

        await db.execute(
          '''
            CREATE TABLE customers(
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              uuid TEXT NOT NULL,
              name TEXT NOT NULL,
              email TEXT NOT NULL,
              createdAt INTEGER NOT NULL,
              createdBy TEXT NOT NULL,
              modifiedAt INTEGER NOT NULL,
              modifiedBy TEXT NOT NULL,
              deletedAt INTEGER NULL,
              deletedBy TEXT NULL,
              modifiedByDevice TEXT NULL
            );
          ''',
        );

        return await db.execute(
          '''
            CREATE UNIQUE INDEX idx_customers_uuid
            ON customers (uuid);
          ''',
        );
      },
      version: 1,
    );
  }
}

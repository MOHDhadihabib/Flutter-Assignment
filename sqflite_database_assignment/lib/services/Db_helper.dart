import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static const db_name = "MHH.db";
  static const db_version = 1;
  static const db_table = "myinfo";
  static const dt_id = "id";
  static const dt_name = "name";
  static const dt_title = "title";
  static const dt_description = "description";

  static final DbHelper instance = DbHelper();

  static Database? _database;

  Future<Database?> get database async {
    _database ??= await _initDb();
    return _database;
  }

  Future<Database> _initDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, db_name);
    return await openDatabase(path, version: db_version, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $db_table (
        $dt_id INTEGER PRIMARY KEY,
        $dt_name TEXT NOT NULL,
        $dt_title TEXT NOT NULL,
        $dt_description TEXT NOT NULL
      )
    ''');
  }

  InsertRecord(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(db_table, row);
  }

  Future<List<Map<String, dynamic>>> querydatabase() async {
    Database? db = await instance.database;
    return await db!.query(db_table);
  }

  Future<int> updateRecord(Map<String, dynamic> row) async {
    Database? db = await instance.database;

    int id = row[dt_id];

    return await db!.update(db_table, row, where: '$dt_id=?', whereArgs: [id]);
  }

  Future<int> deleteRecord(int id) async {
    Database? db = await instance.database;

    return await db!.delete(db_table, where: '$dt_id=?', whereArgs: [id]);
  }
}

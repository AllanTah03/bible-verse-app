import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/verse.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'bible_verses.db');
    return openDatabase(path, version: 1, onCreate: _createTable);
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE personal_verses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reference TEXT NOT NULL,
        text TEXT NOT NULL,
        book TEXT NOT NULL,
        testament TEXT NOT NULL,
        categories TEXT,
        is_personal INTEGER DEFAULT 1
      )
    ''');
  }

  Future<int> insertVerse(Verse verse) async {
    final db = await database;
    return db.insert('personal_verses', verse.toMap());
  }

  Future<List<Verse>> getAllVerses() async {
    final db = await database;
    final maps = await db.query('personal_verses', orderBy: 'id DESC');
    return maps.map(Verse.fromMap).toList();
  }

  Future<int> deleteVerse(int id) async {
    final db = await database;
    return db.delete('personal_verses', where: 'id = ?', whereArgs: [id]);
  }
}

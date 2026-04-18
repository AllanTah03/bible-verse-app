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
    return openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createPersonalTable(db);
    await _createNotionTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) await _createNotionTable(db);
  }

  Future<void> _createPersonalTable(Database db) async {
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

  Future<void> _createNotionTable(Database db) async {
    await db.execute('''
      CREATE TABLE notion_verses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reference TEXT NOT NULL UNIQUE,
        text TEXT NOT NULL,
        book TEXT NOT NULL,
        testament TEXT NOT NULL,
        categories TEXT,
        is_personal INTEGER DEFAULT 0
      )
    ''');
  }

  // --- Versets personnels ---

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

  // --- Cache Notion ---

  Future<void> syncNotionVerses(List<Verse> verses) async {
    final db = await database;
    final batch = db.batch();
    batch.delete('notion_verses');
    for (final v in verses) {
      batch.insert('notion_verses', v.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Verse>> getNotionVerses() async {
    final db = await database;
    final maps = await db.query('notion_verses');
    return maps.map(Verse.fromMap).toList();
  }

  Future<bool> hasNotionVerses() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM notion_verses'));
    return (count ?? 0) > 0;
  }
}

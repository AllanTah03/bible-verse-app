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
    return openDatabase(path, version: 3, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createPersonalTable(db);
    await _createNotionTable(db);
    await _createDeletedRefsTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) await _createNotionTable(db);
    if (oldVersion < 3) await _createDeletedRefsTable(db);
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

  // Stocke les références Notion supprimées pour ne pas les réimporter à la sync
  Future<void> _createDeletedRefsTable(Database db) async {
    await db.execute('''
      CREATE TABLE deleted_notion_refs (
        reference TEXT PRIMARY KEY
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

  // Supprime un verset Notion du cache et l'ajoute à la liste noire pour éviter sa réimportation
  Future<void> deleteNotionVerse(String reference) async {
    final db = await database;
    await db.insert(
      'deleted_notion_refs',
      {'reference': reference},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    await db.delete('notion_verses',
        where: 'reference = ?', whereArgs: [reference]);
  }

  // Sync en respectant la liste noire des versets supprimés par l'utilisateur
  Future<void> syncNotionVerses(List<Verse> verses) async {
    final db = await database;
    final deletedRefs = (await db.query('deleted_notion_refs'))
        .map((r) => r['reference'] as String)
        .toSet();

    final batch = db.batch();
    batch.delete('notion_verses');
    for (final v in verses) {
      if (!deletedRefs.contains(v.reference)) {
        batch.insert('notion_verses', v.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
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

  // Vérifie dans les deux tables si une référence existe déjà (insensible à la casse)
  Future<bool> verseExistsByReference(String reference) async {
    final db = await database;
    final ref = reference.trim().toLowerCase();
    final personal = await db.query('personal_verses',
        where: 'LOWER(reference) = ?', whereArgs: [ref], limit: 1);
    if (personal.isNotEmpty) return true;
    final notion = await db.query('notion_verses',
        where: 'LOWER(reference) = ?', whereArgs: [ref], limit: 1);
    return notion.isNotEmpty;
  }

  // Retourne tous les versets (personnels en premier, puis Notion)
  Future<List<Verse>> getAllVersesFromAllSources() async {
    final personal = await getAllVerses();
    final notion = await getNotionVerses();
    return [...personal, ...notion];
  }
}

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
    return openDatabase(path, version: 4, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createPersonalTable(db);
    await _createNotionTable(db);
    await _createDeletedRefsTable(db);
    await _createNotionOverridesTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) await _createNotionTable(db);
    if (oldVersion < 3) await _createDeletedRefsTable(db);
    if (oldVersion < 4) await _createNotionOverridesTable(db);
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

  // Stocke les corrections apportées aux versets Notion pour survivre aux syncs
  Future<void> _createNotionOverridesTable(Database db) async {
    await db.execute('''
      CREATE TABLE notion_overrides (
        reference TEXT PRIMARY KEY,
        text TEXT NOT NULL,
        book TEXT NOT NULL,
        testament TEXT NOT NULL,
        categories TEXT
      )
    ''');
  }

  // --- Versets personnels ---

  Future<int> insertVerse(Verse verse) async {
    final db = await database;
    return db.insert('personal_verses', verse.toMap());
  }

  Future<void> updatePersonalVerse(Verse verse) async {
    final db = await database;
    await db.update(
      'personal_verses',
      verse.toMap(),
      where: 'id = ?',
      whereArgs: [verse.id],
    );
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
    await db.delete('notion_overrides',
        where: 'reference = ?', whereArgs: [reference]);
    await db.delete('notion_verses',
        where: 'reference = ?', whereArgs: [reference]);
  }

  // Sauvegarde les corrections d'un verset Notion — survit aux syncs futures
  Future<void> updateNotionVerse(Verse verse) async {
    final db = await database;
    final override = {
      'reference': verse.reference,
      'text': verse.text,
      'book': verse.book,
      'testament': verse.testament,
      'categories': verse.categories.join(','),
    };
    await db.insert('notion_overrides', override,
        conflictAlgorithm: ConflictAlgorithm.replace);
    await db.update('notion_verses', verse.toMap(),
        where: 'reference = ?', whereArgs: [verse.reference]);
  }

  // Sync en respectant la liste noire et les corrections de l'utilisateur
  Future<void> syncNotionVerses(List<Verse> verses) async {
    final db = await database;

    final deletedRefs = (await db.query('deleted_notion_refs'))
        .map((r) => r['reference'] as String)
        .toSet();

    // Charge les overrides pour réappliquer les corrections après la sync
    final overrides = {
      for (final r in await db.query('notion_overrides'))
        r['reference'] as String: r
    };

    final batch = db.batch();
    batch.delete('notion_verses');
    for (final v in verses) {
      if (deletedRefs.contains(v.reference)) continue;
      final map = v.toMap();
      if (overrides.containsKey(v.reference)) {
        final o = overrides[v.reference]!;
        map['text'] = o['text'];
        map['book'] = o['book'];
        map['testament'] = o['testament'];
        map['categories'] = o['categories'];
      }
      batch.insert('notion_verses', map,
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

  // Vérifie dans les deux tables si une référence existe déjà (insensible à la casse)
  Future<bool> verseExistsByReference(String reference,
      {String? excludeRef}) async {
    final db = await database;
    final ref = reference.trim().toLowerCase();
    if (excludeRef != null && ref == excludeRef.trim().toLowerCase()) {
      return false;
    }
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

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/verse.dart';
import '../widgets/verse_card.dart';
import 'add_verse_screen.dart';

class MyVersesScreen extends StatefulWidget {
  const MyVersesScreen({super.key});

  @override
  State<MyVersesScreen> createState() => _MyVersesScreenState();
}

class _MyVersesScreenState extends State<MyVersesScreen> {
  late Future<List<Verse>> _versesFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _versesFuture = DatabaseHelper.instance.getAllVerses();
  }

  Future<void> _delete(Verse verse) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer ce verset ?'),
        content: Text(verse.reference),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler',
                style: TextStyle(color: Color(0xFF9E9E9E))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed == true && verse.id != null) {
      await DatabaseHelper.instance.deleteVerse(verse.id!);
      setState(() => _load());
    }
  }

  Future<void> _goToAdd() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddVerseScreen()),
    );
    if (added == true) setState(() => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      appBar: AppBar(
        title: const Text('Mes versets'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAdd,
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Verse>>(
        future: _versesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF5C6BC0)),
            );
          }
          final verses = snapshot.data ?? [];
          if (verses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bookmark_border_rounded,
                      size: 64, color: Color(0xFFBDBDBD)),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun verset enregistré',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _goToAdd,
                    child: const Text(
                      'Ajouter mon premier verset',
                      style: TextStyle(color: Color(0xFF5C6BC0)),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: verses.length,
            itemBuilder: (_, i) => VerseCard(
              verse: verses[i],
              onDelete: () => _delete(verses[i]),
            ),
          );
        },
      ),
    );
  }
}

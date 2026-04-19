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
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer ce verset ?'),
        content: Text(verse.reference),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Annuler',
                style: TextStyle(color: cs.onSurfaceVariant)),
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
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Mes versets')),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAdd,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 2,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Verse>>(
        future: _versesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: cs.primary),
            );
          }
          final verses = snapshot.data ?? [];
          if (verses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border_rounded,
                      size: 64, color: cs.outline),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun verset enregistré',
                    style: TextStyle(
                      fontSize: 16,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _goToAdd,
                    child: Text(
                      'Ajouter mon premier verset',
                      style: TextStyle(color: cs.primary),
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

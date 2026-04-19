import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/verse.dart';
import '../widgets/verse_card.dart';
import 'add_verse_screen.dart';

const _kCategories = [
  'Encouragement', 'Amour', 'Foi', 'Paix', 'Force',
  'Sagesse', 'Espérance', 'Guérison', 'Grâce', 'Prière',
];

class AllVersesScreen extends StatefulWidget {
  const AllVersesScreen({super.key});

  @override
  State<AllVersesScreen> createState() => _AllVersesScreenState();
}

class _AllVersesScreenState extends State<AllVersesScreen> {
  List<Verse> _allVerses = [];
  bool _loading = true;
  String _sourceFilter = 'Tous';
  String? _categoryFilter;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final verses = await DatabaseHelper.instance.getAllVersesFromAllSources();
    setState(() {
      _allVerses = verses;
      _loading = false;
    });
  }

  // Applique les filtres source + catégorie + recherche texte en une seule passe
  List<Verse> get _filtered {
    return _allVerses.where((v) {
      if (_sourceFilter == 'Notion' && v.isPersonal) return false;
      if (_sourceFilter == 'Personnel' && !v.isPersonal) return false;
      if (_categoryFilter != null && !v.categories.contains(_categoryFilter)) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return v.reference.toLowerCase().contains(q) ||
            v.text.toLowerCase().contains(q) ||
            v.book.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  Future<void> _delete(Verse verse) async {
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer ce verset ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(verse.reference,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            if (!verse.isPersonal) ...[
              const SizedBox(height: 8),
              Text(
                'Ce verset ne sera plus affiché, même après une synchronisation Notion.',
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
              ),
            ],
          ],
        ),
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
    if (confirmed == true) {
      if (verse.isPersonal && verse.id != null) {
        await DatabaseHelper.instance.deleteVerse(verse.id!);
      } else {
        // Ajoute à la liste noire pour ne pas réimporter lors des syncs futures
        await DatabaseHelper.instance.deleteNotionVerse(verse.reference);
      }
      _load();
    }
  }

  Future<void> _edit(Verse verse) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => AddVerseScreen(initialVerse: verse)),
    );
    if (updated == true) _load();
  }

  Future<void> _goToAdd() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddVerseScreen()),
    );
    if (added == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bibliothèque'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${filtered.length} verset${filtered.length > 1 ? 's' : ''}',
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAdd,
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildSearchBar(cs),
          _buildSourceFilter(cs),
          _buildCategoryFilter(cs),
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: cs.primary))
                : filtered.isEmpty
                    ? _buildEmpty(cs)
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 80),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final verse = filtered[i];
                            return VerseCard(
                              verse: verse,
                              showSource: true,
                              onEdit: () => _edit(verse),
                              onDelete: () => _delete(verse),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Rechercher un verset…',
          hintStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, size: 18, color: cs.onSurfaceVariant),
                  onPressed: () => _searchCtrl.clear(),
                )
              : null,
          filled: true,
          fillColor: cs.surfaceContainerHighest,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSourceFilter(ColorScheme cs) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: ['Tous', 'Notion', 'Personnel'].map((src) {
          final active = _sourceFilter == src;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(src),
              selected: active,
              onSelected: (_) => setState(() => _sourceFilter = src),
              selectedColor: cs.primaryContainer,
              checkmarkColor: cs.onPrimaryContainer,
              labelStyle: TextStyle(
                color: active ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
              side: BorderSide(
                color: active ? cs.primary : cs.outlineVariant,
              ),
              backgroundColor: cs.surface,
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryFilter(ColorScheme cs) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _CategoryChip(
            label: 'Toutes catégories',
            active: _categoryFilter == null,
            cs: cs,
            onTap: () => setState(() => _categoryFilter = null),
          ),
          ..._kCategories.map((cat) => _CategoryChip(
                label: cat,
                active: _categoryFilter == cat,
                cs: cs,
                onTap: () => setState(() =>
                    _categoryFilter = _categoryFilter == cat ? null : cat),
              )),
        ],
      ),
    );
  }

  Widget _buildEmpty(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.library_books_outlined, size: 64, color: cs.outline),
          const SizedBox(height: 16),
          Text(
            'Aucun verset trouvé',
            style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant),
          ),
          if (_searchQuery.isNotEmpty || _categoryFilter != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() {
                _searchCtrl.clear();
                _categoryFilter = null;
                _sourceFilter = 'Tous';
              }),
              child: Text('Effacer les filtres',
                  style: TextStyle(color: cs.primary)),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool active;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.active,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? cs.secondaryContainer : cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? cs.secondary : cs.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: active ? cs.onSecondaryContainer : cs.onSurfaceVariant,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

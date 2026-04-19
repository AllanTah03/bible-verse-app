import 'package:flutter/material.dart';
import '../models/verse.dart';
import '../database/database_helper.dart';

const _kCategories = [
  'Encouragement', 'Amour', 'Foi', 'Paix', 'Force',
  'Sagesse', 'Espérance', 'Guérison', 'Grâce', 'Prière',
];

const Map<String, String> _kBibleBooks = {
  'Genèse': 'Ancien', 'Exode': 'Ancien', 'Lévitique': 'Ancien',
  'Nombres': 'Ancien', 'Deutéronome': 'Ancien', 'Josué': 'Ancien',
  'Juges': 'Ancien', 'Ruth': 'Ancien', '1 Samuel': 'Ancien',
  '2 Samuel': 'Ancien', '1 Rois': 'Ancien', '2 Rois': 'Ancien',
  '1 Chroniques': 'Ancien', '2 Chroniques': 'Ancien', 'Esdras': 'Ancien',
  'Néhémie': 'Ancien', 'Esther': 'Ancien', 'Job': 'Ancien',
  'Psaumes': 'Ancien', 'Proverbes': 'Ancien', 'Ecclésiaste': 'Ancien',
  'Cantique des Cantiques': 'Ancien', 'Isaïe': 'Ancien', 'Ésaïe': 'Ancien',
  'Jérémie': 'Ancien', 'Lamentations': 'Ancien', 'Ézéchiel': 'Ancien',
  'Daniel': 'Ancien', 'Osée': 'Ancien', 'Joël': 'Ancien',
  'Amos': 'Ancien', 'Abdias': 'Ancien', 'Jonas': 'Ancien',
  'Michée': 'Ancien', 'Nahum': 'Ancien', 'Habacuc': 'Ancien',
  'Sophonie': 'Ancien', 'Aggée': 'Ancien', 'Zacharie': 'Ancien',
  'Malachie': 'Ancien',
  'Matthieu': 'Nouveau', 'Marc': 'Nouveau', 'Luc': 'Nouveau',
  'Jean': 'Nouveau', 'Actes': 'Nouveau', 'Romains': 'Nouveau',
  '1 Corinthiens': 'Nouveau', '2 Corinthiens': 'Nouveau',
  'Galates': 'Nouveau', 'Éphésiens': 'Nouveau', 'Philippiens': 'Nouveau',
  'Colossiens': 'Nouveau', '1 Thessaloniciens': 'Nouveau',
  '2 Thessaloniciens': 'Nouveau', '1 Timothée': 'Nouveau',
  '2 Timothée': 'Nouveau', 'Tite': 'Nouveau', 'Philémon': 'Nouveau',
  'Hébreux': 'Nouveau', 'Jacques': 'Nouveau', '1 Pierre': 'Nouveau',
  '2 Pierre': 'Nouveau', '1 Jean': 'Nouveau', '2 Jean': 'Nouveau',
  '3 Jean': 'Nouveau', 'Jude': 'Nouveau', 'Apocalypse': 'Nouveau',
};

class AddVerseScreen extends StatefulWidget {
  const AddVerseScreen({super.key});

  @override
  State<AddVerseScreen> createState() => _AddVerseScreenState();
}

class _AddVerseScreenState extends State<AddVerseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _referenceCtrl = TextEditingController();
  final _textCtrl = TextEditingController();
  final _bookCtrl = TextEditingController();
  String _testament = 'Nouveau';
  String _selectedBook = '';
  final Set<String> _selectedCategories = {};
  bool _loading = false;

  @override
  void dispose() {
    _referenceCtrl.dispose();
    _textCtrl.dispose();
    _bookCtrl.dispose();
    super.dispose();
  }

  void _onBookSelected(String book) {
    _bookCtrl.text = book;
    _selectedBook = book;
    final testament = _kBibleBooks[book];
    if (testament != null) {
      setState(() => _testament = testament);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final ref = _referenceCtrl.text.trim();
    // Bloque l'ajout si la référence existe déjà dans les versets personnels ou Notion
    final exists = await DatabaseHelper.instance.verseExistsByReference(ref);
    if (exists) {
      setState(() => _loading = false);
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Text('Verset déjà présent'),
            content: Text(
                'Un verset avec la référence "$ref" existe déjà dans la bibliothèque.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('OK',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary)),
              ),
            ],
          ),
        );
      }
      return;
    }

    final verse = Verse(
      reference: ref,
      text: _textCtrl.text.trim(),
      book: _bookCtrl.text.trim(),
      testament: _testament,
      categories: _selectedCategories.toList(),
      isPersonal: true,
    );
    await DatabaseHelper.instance.insertVerse(verse);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un verset')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildField(
              cs: cs,
              controller: _referenceCtrl,
              label: 'Référence',
              hint: 'ex. Jean 3:16',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            _buildField(
              cs: cs,
              controller: _textCtrl,
              label: 'Texte du verset',
              hint: 'Saisir le texte complet...',
              maxLines: 5,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            _buildBookAutocomplete(cs),
            const SizedBox(height: 16),
            _buildTestamentPicker(cs),
            const SizedBox(height: 16),
            _buildCategoryPicker(cs),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _loading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.onPrimary,
                        ),
                      )
                    : const Text(
                        'Enregistrer',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookAutocomplete(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Livre',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return _kBibleBooks.keys;
            }
            final query = textEditingValue.text.toLowerCase();
            return _kBibleBooks.keys.where(
              (book) => book.toLowerCase().contains(query),
            );
          },
          onSelected: _onBookSelected,
          fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
            controller.text = _bookCtrl.text;
            controller.addListener(() {
              _bookCtrl.text = controller.text;
              _selectedBook = controller.text;
            });
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Champ requis' : null,
              decoration: InputDecoration(
                hintText: 'Rechercher un livre...',
                hintStyle: TextStyle(color: cs.outline),
                filled: true,
                fillColor: cs.surface,
                suffixIcon: Icon(Icons.arrow_drop_down, color: cs.outline),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.primary, width: 1.5),
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: cs.surface,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (_, i) {
                      final book = options.elementAt(i);
                      final testament = _kBibleBooks[book]!;
                      final isAncien = testament == 'Ancien';
                      return InkWell(
                        onTap: () => onSelected(book),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(book,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: cs.onSurface)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isAncien
                                      ? cs.tertiaryContainer
                                      : cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  testament,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isAncien
                                        ? cs.onTertiaryContainer
                                        : cs.onPrimaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildField({
    required ColorScheme cs,
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: cs.outline),
            filled: true,
            fillColor: cs.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestamentPicker(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Testament',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: ['Ancien', 'Nouveau'].map((t) {
            final selected = _testament == t;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _testament = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(right: t == 'Ancien' ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? cs.primary : cs.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? cs.primary : cs.outlineVariant,
                    ),
                  ),
                  child: Text(
                    t,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryPicker(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégories (optionnel)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _kCategories.map((cat) {
            final selected = _selectedCategories.contains(cat);
            return GestureDetector(
              onTap: () => setState(() {
                selected
                    ? _selectedCategories.remove(cat)
                    : _selectedCategories.add(cat);
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? cs.primary : cs.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? cs.primary : cs.outlineVariant,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 13,
                    color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

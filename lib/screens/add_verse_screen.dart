import 'package:flutter/material.dart';
import '../models/verse.dart';
import '../database/database_helper.dart';

const _kCategories = [
  'Encouragement', 'Amour', 'Foi', 'Paix', 'Force',
  'Sagesse', 'Espérance', 'Guérison', 'Grâce', 'Prière',
];

// Livres avec leur testament associé
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
    final verse = Verse(
      reference: _referenceCtrl.text.trim(),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      appBar: AppBar(
        title: const Text('Ajouter un verset'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildField(
              controller: _referenceCtrl,
              label: 'Référence',
              hint: 'ex. Jean 3:16',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _textCtrl,
              label: 'Texte du verset',
              hint: 'Saisir le texte complet...',
              maxLines: 5,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            _buildBookAutocomplete(),
            const SizedBox(height: 16),
            _buildTestamentPicker(),
            const SizedBox(height: 16),
            _buildCategoryPicker(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C6BC0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
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

  Widget _buildBookAutocomplete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Livre',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D2D),
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
            // Synchronise le controller interne avec _bookCtrl
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
                hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: const Icon(Icons.arrow_drop_down,
                    color: Color(0xFFBDBDBD)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFF5C6BC0), width: 1.5),
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
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (_, i) {
                      final book = options.elementAt(i);
                      final testament = _kBibleBooks[book]!;
                      return InkWell(
                        onTap: () => onSelected(book),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(book,
                                    style: const TextStyle(fontSize: 14)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: testament == 'Ancien'
                                      ? const Color(0xFFF3E5D0)
                                      : const Color(0xFFE8EAF6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  testament,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: testament == 'Ancien'
                                        ? const Color(0xFF8D6E63)
                                        : const Color(0xFF5C6BC0),
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
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF5C6BC0), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestamentPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Testament',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D2D),
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
                    color: selected
                        ? const Color(0xFF5C6BC0)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF5C6BC0)
                          : const Color(0xFFEEEEEE),
                    ),
                  ),
                  child: Text(
                    t,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: selected
                          ? Colors.white
                          : const Color(0xFF9E9E9E),
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

  Widget _buildCategoryPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catégories (optionnel)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D2D),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF5C6BC0)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF5C6BC0)
                        : const Color(0xFFEEEEEE),
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 13,
                    color: selected
                        ? Colors.white
                        : const Color(0xFF9E9E9E),
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

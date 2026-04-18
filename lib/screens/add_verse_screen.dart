import 'package:flutter/material.dart';
import '../models/verse.dart';
import '../database/database_helper.dart';

const _kCategories = [
  'Encouragement', 'Amour', 'Foi', 'Paix', 'Force',
  'Sagesse', 'Espérance', 'Guérison', 'Grâce', 'Prière',
];

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
  final Set<String> _selectedCategories = {};
  bool _loading = false;

  @override
  void dispose() {
    _referenceCtrl.dispose();
    _textCtrl.dispose();
    _bookCtrl.dispose();
    super.dispose();
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
            _buildField(
              controller: _bookCtrl,
              label: 'Livre',
              hint: 'ex. Jean, Psaumes',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Champ requis' : null,
            ),
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

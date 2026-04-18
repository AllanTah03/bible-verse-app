class Verse {
  final int? id;
  final String reference;
  final String text;
  final String book;
  final String testament;
  final List<String> categories;
  final bool isPersonal;

  const Verse({
    this.id,
    required this.reference,
    required this.text,
    required this.book,
    required this.testament,
    this.categories = const [],
    this.isPersonal = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'reference': reference,
        'text': text,
        'book': book,
        'testament': testament,
        'categories': categories.join(','),
        'is_personal': isPersonal ? 1 : 0,
      };

  factory Verse.fromMap(Map<String, dynamic> map) => Verse(
        id: map['id'] as int?,
        reference: map['reference'] as String,
        text: map['text'] as String,
        book: map['book'] as String,
        testament: map['testament'] as String,
        categories: (map['categories'] as String?)?.isNotEmpty == true
            ? (map['categories'] as String).split(',')
            : [],
        isPersonal: (map['is_personal'] as int?) == 1,
      );
}

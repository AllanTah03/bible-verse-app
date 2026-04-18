import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/verse.dart';
import '../config/notion_config.dart';

class NotionService {
  static const _baseUrl = 'https://api.notion.com/v1';
  static const _version = '2022-06-28';

  static Map<String, String> get _headers => {
        'Authorization': 'Bearer ${NotionConfig.token}',
        'Notion-Version': _version,
        'Content-Type': 'application/json',
      };

  static Future<List<Verse>> fetchVerses() async {
    final verses = <Verse>[];
    String? cursor;

    do {
      final body = cursor != null
          ? jsonEncode({'start_cursor': cursor, 'page_size': 100})
          : jsonEncode({'page_size': 100});

      final response = await http.post(
        Uri.parse('$_baseUrl/databases/${NotionConfig.databaseId}/query'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode != 200) break;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;

      for (final page in results) {
        final verse = _parseVerse(page);
        if (verse != null) verses.add(verse);
      }

      final hasMore = data['has_more'] as bool? ?? false;
      cursor = hasMore ? data['next_cursor'] as String? : null;
    } while (cursor != null);

    return verses;
  }

  static Verse? _parseVerse(Map<String, dynamic> page) {
    try {
      final props = page['properties'] as Map<String, dynamic>;

      final reference = _title(props['Référence']);
      final text = _richText(props['Texte']);
      final book = _richText(props['Livre']);
      final testament = _select(props['Testament']) ?? 'Nouveau';
      final categories = _multiSelect(props['Catégorie']);

      if (reference.isEmpty || text.isEmpty) return null;

      return Verse(
        reference: reference,
        text: text,
        book: book,
        testament: testament,
        categories: categories,
      );
    } catch (_) {
      return null;
    }
  }

  static String _title(dynamic prop) {
    if (prop == null) return '';
    final list = prop['title'] as List<dynamic>?;
    return list?.map((e) => e['plain_text'] as String).join() ?? '';
  }

  static String _richText(dynamic prop) {
    if (prop == null) return '';
    final list = prop['rich_text'] as List<dynamic>?;
    return list?.map((e) => e['plain_text'] as String).join() ?? '';
  }

  static String? _select(dynamic prop) {
    if (prop == null) return null;
    return prop['select']?['name'] as String?;
  }

  static List<String> _multiSelect(dynamic prop) {
    if (prop == null) return [];
    final list = prop['multi_select'] as List<dynamic>?;
    return list?.map((e) => e['name'] as String).toList() ?? [];
  }
}

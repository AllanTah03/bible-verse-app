import 'package:home_widget/home_widget.dart';
import '../models/verse.dart';

class WidgetService {
  static const _providerName = 'BibleVerseWidgetProvider';

  // Met à jour le contenu du widget avec le verset affiché dans l'app
  static Future<void> updateWidget(Verse verse) async {
    final text = verse.text.length > 150
        ? '«${verse.text.substring(0, 150)}…»'
        : '«${verse.text}»';

    await HomeWidget.saveWidgetData<String>('widget_verse_text', text);
    await HomeWidget.saveWidgetData<String>(
        'widget_verse_ref', '— ${verse.reference}');

    await HomeWidget.updateWidget(androidName: _providerName);
  }
}

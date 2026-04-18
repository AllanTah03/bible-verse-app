import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Réduit la latence de rendu pour les appareils à haute fréquence
  await Future.microtask(
    () => WidgetsBinding.instance.platformDispatcher.onReportTimings = (_) {},
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const BibleVerseApp());
}

class BibleVerseApp extends StatelessWidget {
  const BibleVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verset du Jour',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C6BC0),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F7F4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF2D2D2D),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

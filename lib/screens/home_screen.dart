import 'dart:math';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../config/theme_notifier.dart';
import '../data/verses_data.dart';
import '../models/verse.dart';
import '../widgets/verse_card.dart';
import '../database/database_helper.dart';
import '../services/notion_service.dart';
import '../services/notification_service.dart';
import 'my_verses_screen.dart';
import 'all_verses_screen.dart';
import 'notification_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Verse _currentVerse;
  List<Verse> _verses = [];
  final _random = Random();
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _currentVerse =
        kPlaceholderVerses[_random.nextInt(kPlaceholderVerses.length)];
    _loadAndSync();
    // Replanifie la notification avec un nouveau verset à chaque ouverture de l'app
    NotificationService.rescheduleIfEnabled();
  }

  Future<void> _loadAndSync() async {
    final cached = await DatabaseHelper.instance.getNotionVerses();
    if (cached.isNotEmpty) {
      setState(() {
        _verses = cached;
        _currentVerse = _verses[_random.nextInt(_verses.length)];
      });
    }

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;

    setState(() => _syncing = true);
    try {
      final fresh = await NotionService.fetchVerses();
      if (fresh.isNotEmpty) {
        await DatabaseHelper.instance.syncNotionVerses(fresh);
        setState(() {
          _verses = fresh;
          _currentVerse = _verses[_random.nextInt(_verses.length)];
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  void _newVerse() {
    final pool = _verses.isNotEmpty ? _verses : kPlaceholderVerses;
    setState(() => _currentVerse = pool[_random.nextInt(pool.length)]);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(cs),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      _buildDateLabel(cs),
                      const SizedBox(height: 24),
                      RepaintBoundary(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) =>
                              SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.08),
                              end: Offset.zero,
                            ).animate(animation),
                            child: FadeTransition(
                                opacity: animation, child: child),
                          ),
                          child: VerseCard(
                            key: ValueKey(_currentVerse.reference),
                            verse: _currentVerse,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildNewVerseButton(cs),
                      if (_syncing) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: cs.outline,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Synchronisation Notion…',
                              style: TextStyle(
                                fontSize: 11,
                                color: cs.outline,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomBar(context, cs),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 12, 0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verset du Jour',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  'Bible de Jérusalem',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.notifications_none_rounded,
                color: cs.onSurfaceVariant),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const NotificationSettingsScreen()),
            ),
            tooltip: 'Notifications',
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (_, mode, __) => IconButton(
              icon: Icon(
                mode == ThemeMode.dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: cs.onSurfaceVariant,
              ),
              onPressed: () {
                themeNotifier.value = mode == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;
              },
              tooltip: mode == ThemeMode.dark ? 'Mode clair' : 'Mode sombre',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateLabel(ColorScheme cs) {
    final now = DateTime.now();
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    return Text(
      '${now.day} ${months[now.month - 1]} ${now.year}',
      style: TextStyle(
        fontSize: 13,
        color: cs.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildNewVerseButton(ColorScheme cs) {
    return ElevatedButton.icon(
      onPressed: _newVerse,
      icon: const Icon(Icons.refresh_rounded, size: 18),
      label: const Text('Nouveau verset'),
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _BottomBarItem(
              icon: Icons.home_rounded,
              label: 'Accueil',
              active: true,
              cs: cs,
              onTap: () {},
            ),
            _BottomBarItem(
              icon: Icons.library_books_rounded,
              label: 'Bibliothèque',
              active: false,
              cs: cs,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllVersesScreen()),
              ),
            ),
            _BottomBarItem(
              icon: Icons.bookmark_border_rounded,
              label: 'Mes versets',
              active: false,
              cs: cs,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyVersesScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _BottomBarItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? cs.primary : cs.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

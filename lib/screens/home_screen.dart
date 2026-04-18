import 'dart:math';
import 'package:flutter/material.dart';
import '../data/verses_data.dart';
import '../models/verse.dart';
import '../widgets/verse_card.dart';
import 'my_verses_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Verse _currentVerse;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _currentVerse = _randomVerse();
  }

  Verse _randomVerse() {
    return kPlaceholderVerses[_random.nextInt(kPlaceholderVerses.length)];
  }

  void _newVerse() {
    setState(() => _currentVerse = _randomVerse());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      _buildDateLabel(),
                      const SizedBox(height: 24),
                      //VerseCard(verse: _currentVerse),
                      RepaintBoundary(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          switchInCurve: Curves.easeInOutCubicEmphasized,
                          switchOutCurve: Curves.easeInOutCubicEmphasized,
                          transitionBuilder: (child, animation) => SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.08),
                              end: Offset.zero,
                            ).animate(animation),
                            child: FadeTransition(opacity: animation, child: child),
                          ),
                          child: VerseCard(
                            key: ValueKey(_currentVerse.reference),
                            verse: _currentVerse,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildNewVerseButton(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF5C6BC0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verset du Jour',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              Text(
                'Bible de Jérusalem',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateLabel() {
    final now = DateTime.now();
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    final label =
        '${now.day} ${months[now.month - 1]} ${now.year}';
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFF9E9E9E),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildNewVerseButton() {
    return ElevatedButton.icon(
      onPressed: _newVerse,
      icon: const Icon(Icons.refresh_rounded, size: 18),
      label: const Text('Nouveau verset'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _BottomBarItem(
              icon: Icons.home_rounded,
              label: 'Accueil',
              active: true,
              onTap: () {},
            ),
            _BottomBarItem(
              icon: Icons.bookmark_border_rounded,
              label: 'Mes versets',
              active: false,
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
  final VoidCallback onTap;

  const _BottomBarItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        active ? const Color(0xFF5C6BC0) : const Color(0xFF9E9E9E);
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

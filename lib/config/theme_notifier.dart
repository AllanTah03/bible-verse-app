import 'package:flutter/material.dart';

// Notifier global pour basculer entre mode clair et sombre depuis n'importe quel écran
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

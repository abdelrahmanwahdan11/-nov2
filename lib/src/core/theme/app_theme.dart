import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._(this.light, this.dark);

  final ThemeData light;
  final ThemeData dark;

  static AppTheme build(bool darkMode) {
    final baseLight = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0BA360),
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.tajawalTextTheme(),
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
    );
    final baseDark = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0BA360),
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.tajawalTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
    );
    return AppTheme._(baseLight, baseDark);
  }
}

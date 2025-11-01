import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final appThemeProvider = Provider<AppTheme>((ref) {
  return AppTheme();
});

class AppTheme {
  ThemeData get light => _baseTheme(Brightness.light);

  ThemeData get dark => _baseTheme(Brightness.dark);

  ThemeData _baseTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primary = const Color(0xFF0BA360);
    final primaryDark = const Color(0xFF077C48);
    final accent = const Color(0xFFFF7A00);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? primaryDark : primary,
      onPrimary: Colors.white,
      secondary: accent,
      onSecondary: Colors.white,
      error: const Color(0xFFD32F2F),
      onError: Colors.white,
      background: isDark ? const Color(0xFF121417) : const Color(0xFFF4F6F8),
      onBackground: isDark ? const Color(0xFFF5F6F7) : const Color(0xFF0B0B0C),
      surface: isDark ? const Color(0xFF1A1D21) : Colors.white,
      onSurface: isDark ? const Color(0xFFF5F6F7) : const Color(0xFF0B0B0C),
      surfaceVariant: isDark ? const Color(0xFF1A1D21) : const Color(0xFFF4F6F8),
      onSurfaceVariant: isDark ? const Color(0xFFF5F6F7) : const Color(0xFF0B0B0C),
      outline: const Color(0xFFB0BEC5),
      shadow: Colors.black.withOpacity(0.25),
      scrim: Colors.black54,
      inverseSurface: isDark ? Colors.white : const Color(0xFF121417),
      onInverseSurface: isDark ? const Color(0xFF0B0B0C) : Colors.white,
      tertiary: const Color(0xFF1E88E5),
      onTertiary: Colors.white,
      secondaryContainer: accent.withOpacity(0.15),
      onSecondaryContainer: accent,
    );

    final textTheme = GoogleFonts.tajawalTextTheme().copyWith(
      displayLarge: GoogleFonts.tajawal(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: colorScheme.onBackground,
      ),
      titleLarge: GoogleFonts.tajawal(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: colorScheme.onBackground,
      ),
      titleMedium: GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colorScheme.onBackground,
      ),
      bodyLarge: GoogleFonts.tajawal(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: colorScheme.onBackground,
      ),
      bodyMedium: GoogleFonts.tajawal(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: colorScheme.onBackground,
      ),
      labelLarge: GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: colorScheme.onPrimary,
      ),
      bodySmall: GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.secondaryContainer,
        labelStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSecondaryContainer),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

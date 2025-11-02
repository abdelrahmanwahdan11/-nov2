import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AppTheme {
  const AppTheme({
    required this.primaryColor,
    required this.isDark,
  });

  final Color primaryColor;
  final bool isDark;

  ThemeData get data => _buildTheme();

  ThemeData _buildTheme() {
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textOnLight;

    final textTheme = _textTheme(base.textTheme, textColor);
    final borderRadius = BorderRadius.circular(AppDimensions.cardRadius);

    return base.copyWith(
      useMaterial3: true,
      scaffoldBackgroundColor: surfaceColor,
      colorScheme: base.colorScheme.copyWith(
        primary: primaryColor,
        secondary: AppColors.accent,
        surface: surfaceColor,
        background: surfaceColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
        error: AppColors.error,
      ),
      primaryColor: primaryColor,
      canvasColor: surfaceColor,
      cardColor: cardColor,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: textColor),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: textColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          minimumSize: const Size.fromHeight(52),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: textColor,
          side: BorderSide(color: textColor.withOpacity(0.4)),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor.withOpacity(isDark ? 0.45 : 0.85),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          borderSide: BorderSide.none,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textColor.withOpacity(0.6)),
        labelStyle: textTheme.bodyLarge,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: cardColor.withOpacity(isDark ? 0.45 : 0.85),
        selectedColor: primaryColor.withOpacity(0.25),
        labelStyle: textTheme.bodyMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
      ),
      cardTheme: CardTheme(
        color: cardColor.withOpacity(isDark ? 0.58 : 0.9),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        shadowColor: Colors.black.withOpacity(0.25),
        surfaceTintColor: Colors.white.withOpacity(isDark ? 0.08 : 0.04),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textColor.withOpacity(0.6),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: cardColor.withOpacity(isDark ? 0.9 : 0.95),
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(isDark ? 0.12 : 0.08),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: cardColor.withOpacity(isDark ? 0.6 : 0.92),
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
    );
  }

  TextTheme _textTheme(TextTheme base, Color textColor) {
    final interFamily = GoogleFonts.inter().fontFamily;
    final applyFallback = (TextStyle style) => style.copyWith(
          fontFamilyFallback: interFamily != null ? [interFamily] : null,
          color: textColor,
        );

    final tajawal = GoogleFonts.tajawalTextTheme(base).copyWith(
      displayLarge: applyFallback(
        GoogleFonts.tajawal(fontWeight: FontWeight.w800, fontSize: 34),
      ),
      titleLarge: applyFallback(
        GoogleFonts.tajawal(fontWeight: FontWeight.w700, fontSize: 22),
      ),
      titleMedium: applyFallback(
        GoogleFonts.tajawal(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      bodyLarge: applyFallback(
        GoogleFonts.tajawal(fontWeight: FontWeight.w500, fontSize: 16),
      ),
      bodyMedium: applyFallback(
        GoogleFonts.tajawal(fontWeight: FontWeight.w400, fontSize: 14),
      ),
      bodySmall: applyFallback(
        GoogleFonts.tajawal(fontWeight: FontWeight.w300, fontSize: 12).copyWith(color: textColor.withOpacity(0.8)),
      ),
      labelLarge: applyFallback(
        GoogleFonts.tajawal(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    );

    return tajawal.apply(displayColor: textColor, bodyColor: textColor);
  }
}

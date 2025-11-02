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
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
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
        fillColor: cardColor.withOpacity(isDark ? 0.4 : 0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          borderSide: BorderSide.none,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textColor.withOpacity(0.6)),
        labelStyle: textTheme.bodyLarge,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: cardColor,
        selectedColor: primaryColor.withOpacity(0.2),
        labelStyle: textTheme.bodyMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textColor.withOpacity(0.6),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  TextTheme _textTheme(TextTheme base, Color textColor) {
    final tajawal = GoogleFonts.tajawalTextTheme(base).copyWith(
      displayLarge: GoogleFonts.tajawal(fontWeight: FontWeight.w800, fontSize: 34, color: textColor),
      titleLarge: GoogleFonts.tajawal(fontWeight: FontWeight.w700, fontSize: 22, color: textColor),
      titleMedium: GoogleFonts.tajawal(fontWeight: FontWeight.w600, fontSize: 18, color: textColor),
      bodyLarge: GoogleFonts.tajawal(fontWeight: FontWeight.w500, fontSize: 16, color: textColor),
      bodyMedium: GoogleFonts.tajawal(fontWeight: FontWeight.w400, fontSize: 14, color: textColor),
      bodySmall: GoogleFonts.tajawal(fontWeight: FontWeight.w300, fontSize: 12, color: textColor.withOpacity(0.8)),
    );

    return tajawal.apply(displayColor: textColor, bodyColor: textColor);
  }
}

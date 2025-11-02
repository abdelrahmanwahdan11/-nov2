import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/signals/signal.dart';

class AppStore {
  AppStore._();

  static final AppStore _instance = AppStore._();
  static AppStore get instance => _instance;

  SharedPreferences? _prefs;

  final Signal<Locale> localeSignal = Signal(const Locale('ar'));
  final Signal<bool> darkModeSignal = Signal(true);
  final Signal<Color> primaryColorSignal = Signal(AppColors.primary);
  final Signal<bool> onboardingDoneSignal = Signal(false);
  final Signal<bool> authenticatedSignal = Signal(false);
  final Signal<Set<String>> savedItemsSignal = Signal(<String>{});
  final Signal<Map<String, dynamic>> planMetricsSignal = Signal(<String, dynamic>{});
  final Signal<bool> coachmarksSeenSignal = Signal(false);
  final Signal<bool> reducedMotionSignal = Signal(false);

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    final langCode = _prefs!.getString('lang') ?? 'ar';
    localeSignal.emit(Locale(langCode));

    final darkMode = _prefs!.getBool('dark_mode') ?? true;
    darkModeSignal.emit(darkMode);

    final primaryHex = _prefs!.getString('primary_color_hex');
    if (primaryHex != null) {
      final parsed = int.tryParse(primaryHex, radix: 16);
      if (parsed != null) {
        primaryColorSignal.emit(Color(parsed));
      }
    }

    final onboardingDone = _prefs!.getBool('onboarding_done') ?? false;
    onboardingDoneSignal.emit(onboardingDone);

    final token = _prefs!.getString('auth_token_mock');
    authenticatedSignal.emit(token != null);

    final saved = _prefs!.getStringList('saved_items') ?? <String>[];
    savedItemsSignal.emit(saved.toSet());

    final metrics = _prefs!.getString('my_plan_metrics');
    if (metrics != null && metrics.isNotEmpty) {
      planMetricsSignal.emit({'raw': metrics});
    }

    final seenCoachmarks = _prefs!.getBool('seen_coachmarks') ?? false;
    coachmarksSeenSignal.emit(seenCoachmarks);

    final reducedMotion = _prefs!.getBool('reduced_motion') ?? false;
    reducedMotionSignal.emit(reducedMotion);
  }

  Future<void> setLocale(Locale locale) async {
    localeSignal.emit(locale);
    await _prefs?.setString('lang', locale.languageCode);
  }

  Future<void> setDarkMode(bool dark) async {
    darkModeSignal.emit(dark);
    await _prefs?.setBool('dark_mode', dark);
  }

  Future<void> setPrimaryColor(Color color) async {
    primaryColorSignal.emit(color);
    final hex = color.value.toRadixString(16).padLeft(8, '0');
    await _prefs?.setString('primary_color_hex', hex);
  }

  Future<void> resetAppearance() async {
    await setLocale(const Locale('ar'));
    await setDarkMode(true);
    await setPrimaryColor(AppColors.primary);
    await setReducedMotion(false);
  }

  Future<void> markOnboardingDone() async {
    onboardingDoneSignal.emit(true);
    await _prefs?.setBool('onboarding_done', true);
  }

  Future<void> setAuthenticated(bool value) async {
    authenticatedSignal.emit(value);
    if (value) {
      await _prefs?.setString('auth_token_mock', 'token');
    } else {
      await _prefs?.remove('auth_token_mock');
    }
  }

  Future<void> toggleSavedItem(String id) async {
    final current = savedItemsSignal.value.toSet();
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    savedItemsSignal.emit(current);
    await _prefs?.setStringList('saved_items', current.toList());
  }

  Future<void> updatePlanMetrics(Map<String, dynamic> metrics) async {
    planMetricsSignal.emit(metrics);
    await _prefs?.setString('my_plan_metrics', metrics.toString());
  }

  Future<void> setCoachmarksSeen(bool seen) async {
    coachmarksSeenSignal.emit(seen);
    await _prefs?.setBool('seen_coachmarks', seen);
  }

  Future<void> setReducedMotion(bool value) async {
    reducedMotionSignal.emit(value);
    await _prefs?.setBool('reduced_motion', value);
  }

  String? getSortPreference(String screen) {
    final map = _readMap('last_sort_option');
    final value = map[screen];
    return value is String ? value : null;
  }

  Future<void> saveSortPreference(String screen, String sort) async {
    final map = _readMap('last_sort_option');
    map[screen] = sort;
    await _prefs?.setString('last_sort_option', jsonEncode(map));
  }

  Map<String, dynamic> getFilterPreference(String screen) {
    final map = _readMap('last_filters');
    final value = map[screen];
    if (value is Map) {
      return Map<String, dynamic>.from(value as Map);
    }
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {
        return <String, dynamic>{};
      }
    }
    return <String, dynamic>{};
  }

  Future<void> saveFilterPreference(String screen, Map<String, dynamic> filters) async {
    final sanitized = Map<String, dynamic>.from(filters)
      ..removeWhere((key, value) => value == null || (value is String && value.isEmpty));
    final map = _readMap('last_filters');
    if (sanitized.isEmpty) {
      map.remove(screen);
    } else {
      map[screen] = sanitized;
    }
    await _prefs?.setString('last_filters', jsonEncode(map));
  }

  Map<String, dynamic> _readMap(String key) {
    if (_prefs == null) {
      return <String, dynamic>{};
    }
    final raw = _prefs!.getString(key);
    if (raw == null || raw.isEmpty) {
      return <String, dynamic>{};
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return <String, dynamic>{};
    }
    return <String, dynamic>{};
  }
}

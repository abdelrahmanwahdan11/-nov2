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

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    final langCode = _prefs!.getString('lang') ?? 'ar';
    localeSignal.emit(Locale(langCode));

    final darkMode = _prefs!.getBool('dark_mode') ?? true;
    darkModeSignal.emit(darkMode);

    final primaryHex = _prefs!.getString('primary_color_hex');
    if (primaryHex != null) {
      primaryColorSignal.emit(Color(int.parse(primaryHex, radix: 16)));
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
    await _prefs?.setString('primary_color_hex', color.value.toRadixString(16));
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
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'application/stores/app_store.dart';
import 'core/localization/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/signals/signal.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_motion.dart';

class SahaApp extends StatefulWidget {
  const SahaApp({super.key});

  @override
  State<SahaApp> createState() => _SahaAppState();
}

class _SahaAppState extends State<SahaApp> {
  late final SahaRouterDelegate _routerDelegate;
  late final SahaRouteInformationParser _routeInformationParser;

  @override
  void initState() {
    super.initState();
    _routerDelegate = SahaRouterDelegate(AppRouter.instance);
    _routeInformationParser = SahaRouteInformationParser();
  }

  @override
  void dispose() {
    _routerDelegate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return SignalBuilder<Locale>(
      signal: store.localeSignal,
      builder: (context, locale, _) {
        return SignalBuilder<bool>(
          signal: store.darkModeSignal,
          builder: (context, isDark, __) {
            return SignalBuilder<Color>(
              signal: store.primaryColorSignal,
              builder: (context, primary, ___) {
                final lightTheme = AppTheme(primaryColor: primary, isDark: false).data;
                final darkTheme = AppTheme(primaryColor: primary, isDark: true).data;
                return MaterialApp.router(
                  title: 'SahaPlay',
                  debugShowCheckedModeBanner: false,
                  locale: locale,
                  supportedLocales: SahaLocalizations.supportedLocales,
                  localeResolutionCallback: (deviceLocale, supported) {
                    if (deviceLocale == null) return locale;
                    return supported.firstWhere(
                      (element) => element.languageCode == deviceLocale.languageCode,
                      orElse: () => locale,
                    );
                  },
                  localizationsDelegates: const [
                    SahaLocalizationsDelegate(),
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  routerDelegate: _routerDelegate,
                  routeInformationParser: _routeInformationParser,
                  backButtonDispatcher: RootBackButtonDispatcher(),
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                  builder: (context, child) {
                    final textDirection = locale.languageCode == 'ar'
                        ? TextDirection.rtl
                        : TextDirection.ltr;
                    return Directionality(
                      textDirection: textDirection,
                      child: SignalBuilder<bool>(
                        signal: store.reducedMotionSignal,
                        builder: (context, reducedMotion, __) {
                          Widget content = child ?? const SizedBox.shrink();
                          final mediaQuery = MediaQuery.maybeOf(context);
                          if (mediaQuery != null) {
                            content = MediaQuery(
                              data: mediaQuery.copyWith(disableAnimations: reducedMotion),
                              child: content,
                            );
                          }
                          return ReducedMotionScope(
                            reducedMotion: reducedMotion,
                            child: content,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

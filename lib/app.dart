import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/localization/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

class SahaApp extends ConsumerWidget {
  const SahaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final theme = ref.watch(appThemeProvider);

    return MaterialApp.router(
      title: 'ساحة',
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localeResolutionCallback: (_, __) => const Locale('ar'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      themeMode: ThemeMode.system,
      theme: theme.light,
      darkTheme: theme.dark,
      builder: (context, child) {
        final textTheme = Theme.of(context).textTheme;
        final rtlChild = Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
        return DefaultTextStyle.merge(
          style: GoogleFonts.tajawalTextStyle(textStyle: textTheme.bodyMedium),
          child: rtlChild,
        );
      },
    );
  }
}

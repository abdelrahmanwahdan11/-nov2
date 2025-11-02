import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'core/state/app_scope.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

class SahaApp extends StatelessWidget {
  const SahaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = AppTheme.build(state.darkMode);
    final locale = state.locale;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ساحة',
      theme: theme.light,
      darkTheme: theme.dark,
      themeMode: state.darkMode ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(locale),
      supportedLocales: const [Locale('ar'), Locale('en')],
      builder: (context, child) {
        final dir = locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;
        final textTheme = Theme.of(context).textTheme;
        final base = DefaultTextStyle.merge(
          style: GoogleFonts.tajawalTextStyle(textStyle: textTheme.bodyMedium),
          child: Directionality(
            textDirection: dir,
            child: child ?? const SizedBox.shrink(),
          ),
        );
        return base.animate().fadeIn(duration: 400.ms);
      },
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.initialRoute,
    );
  }
}

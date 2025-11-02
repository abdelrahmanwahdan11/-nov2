import 'package:flutter/material.dart';

import '../../../application/stores/app_store.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/signals/signal.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    final theme = Theme.of(context);
    final store = AppStore.instance;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        SignalBuilder<bool>(
          signal: store.darkModeSignal,
          builder: (context, isDark, _) {
            return SwitchListTile(
              value: isDark,
              title: Text(l10n.t('dark_mode')),
              onChanged: (value) => store.setDarkMode(value),
            );
          },
        ),
        const SizedBox(height: 12),
        SignalBuilder<Locale>(
          signal: store.localeSignal,
          builder: (context, locale, _) {
            return DropdownButtonFormField<String>(
              value: locale.languageCode,
              decoration: InputDecoration(labelText: l10n.t('language')),
              items: [
                DropdownMenuItem(value: 'ar', child: Text(l10n.t('language_ar'))),
                DropdownMenuItem(value: 'en', child: Text(l10n.t('language_en'))),
              ],
              onChanged: (value) {
                if (value != null) {
                  store.setLocale(Locale(value));
                }
              },
            );
          },
        ),
        const SizedBox(height: 24),
        Text(l10n.t('primary_color_picker'), style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        SignalBuilder<Color>(
          signal: store.primaryColorSignal,
          builder: (context, color, _) {
            final palette = const [
              AppColors.primary,
              Color(0xFF22D3EE),
              Color(0xFFF72585),
              Color(0xFF22C55E),
              Color(0xFFF59E0B),
              Color(0xFFEF4444),
            ];
            return Wrap(
              spacing: 12,
              children: palette
                  .map(
                    (swatch) => GestureDetector(
                      onTap: () => store.setPrimaryColor(swatch),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [swatch, swatch.withOpacity(0.7)],
                          ),
                          border: Border.all(
                            color: swatch.value == color.value ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          tileColor: theme.cardColor,
          title: Text(l10n.t('coachmarks_replay')),
          trailing: const Icon(Icons.play_circle_outline),
          onTap: () => store.setCoachmarksSeen(false),
        ),
        const SizedBox(height: 12),
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          tileColor: theme.cardColor,
          title: Text(l10n.t('about')),
          subtitle: const Text('إصدار تجريبي - بدون باك إند'),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: store.resetAppearance,
          icon: const Icon(Icons.refresh),
          label: Text(l10n.t('reset_defaults')),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/localization/app_localizations.dart';
import '../../widgets/primary_button.dart';

class AiStubScreen extends StatelessWidget {
  const AiStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('ai_insight'))),
      body: Center(
        child: Animate(
          effects: const [FadeEffect(duration: Duration(milliseconds: 300)), ScaleEffect(begin: Offset(0.9, 0.9), end: Offset(1, 1))],
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 48, color: theme.colorScheme.onPrimary),
                const SizedBox(height: 16),
                Text(
                  l10n.t('ai_stub_msg'),
                  style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: l10n.t('close'),
                  onPressed: () => Navigator.of(context).maybePop(),
                  expand: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/localization/app_localizations.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    final theme = Theme.of(context);
    final notifications = const [
      {'title': 'دعوة لتحدي جديد', 'time': 'قبل ساعة'},
      {'title': 'تم قبول حجزك', 'time': 'قبل 3 ساعات'},
    ];

    if (notifications.isEmpty) {
      return Center(child: Text(l10n.t('inbox_empty')));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemBuilder: (context, index) {
        final item = notifications[index];
        return Animate(
          effects: const [FadeEffect(duration: Duration(milliseconds: 300))],
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: theme.cardColor,
            title: Text(item['title']!),
            subtitle: Text(item['time']!),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: notifications.length,
    );
  }
}

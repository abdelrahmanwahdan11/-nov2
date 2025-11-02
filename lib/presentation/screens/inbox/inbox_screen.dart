import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/localization/app_localizations.dart';
import '../../widgets/empty_state.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final List<Map<String, String>> _notifications = [
    {'title': 'دعوة لتحدي جديد', 'time': 'قبل ساعة'},
    {'title': 'تم قبول حجزك', 'time': 'قبل 3 ساعات'},
  ];

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    final theme = Theme.of(context);

    if (_notifications.isEmpty) {
      return Center(
        child: EmptyState(
          title: l10n.t('inbox_empty'),
          icon: Icons.mail_outline,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        itemBuilder: (context, index) {
          final item = _notifications[index];
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
        itemCount: _notifications.length,
      ),
    );
  }
}

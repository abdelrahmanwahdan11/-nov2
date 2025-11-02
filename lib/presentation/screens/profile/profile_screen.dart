import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.3),
            child: const Icon(Icons.person, size: 48),
          ),
        ),
        const SizedBox(height: 12),
        Center(child: Text('نور الرياضية', style: theme.textTheme.titleLarge)),
        const SizedBox(height: 24),
        Text(l10n.t('profile_badges'), style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: const [
            _BadgeChip(label: 'Sprinter'),
            _BadgeChip(label: 'Padel Star'),
            _BadgeChip(label: 'Walker'),
          ],
        ),
        const SizedBox(height: 24),
        Text(l10n.t('profile_activity'), style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _ActivityRow(title: 'Football Booking', time: 'اليوم 20:00'),
              _ActivityRow(title: 'Walk Route', time: 'أمس 06:30'),
              _ActivityRow(title: 'Challenge: Steps', time: 'أتممت منذ 3 أيام'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          tileColor: theme.cardColor,
          leading: const Icon(Icons.settings),
          title: Text(l10n.t('settings')),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => AppRouter.instance.push('/settings'),
        ),
      ],
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(label),
      backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.title, required this.time});

  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
          Text(time, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

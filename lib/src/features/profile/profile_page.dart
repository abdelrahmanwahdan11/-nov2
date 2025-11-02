import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/i18n/strings.dart';
import '../../core/state/app_scope.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final locale = state.locale;
    final user = state.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(Strings.of(locale, 'profile'))),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 36, child: Text(user?.name.substring(0, 1) ?? '?')),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? 'ضيف', style: Theme.of(context).textTheme.titleLarge),
                    Text('المستوى: ${user?.level ?? 'beginner'}'),
                  ],
                ),
              ],
            ).animate().fadeIn(duration: 240.ms),
            const SizedBox(height: 24),
            SwitchListTile(
              value: state.darkMode,
              title: Text(Strings.of(locale, 'toggle_theme')),
              onChanged: (_) => state.toggleDark(),
            ),
            ListTile(
              title: Text(Strings.of(locale, 'toggle_locale')),
              trailing: const Icon(Icons.swap_horiz),
              onTap: () => state.setLocale(locale == 'ar' ? 'en' : 'ar'),
            ),
            const Divider(),
            Text('الإنجازات', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                _Badge(label: 'حضور 5 فعاليات'),
                _Badge(label: '3 حجوزات مؤكدة'),
                _Badge(label: 'سلسلة صحية 7 أيام'),
              ],
            ).animate().fadeIn(duration: 260.ms).moveY(begin: 12, end: 0),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.primary.withOpacity(0.4),
          ],
        ),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/primary_button.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.translate('nav_home'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _QuickActions(),
          SizedBox(height: 24),
          _NearbySection(),
          SizedBox(height: 24),
          _HealthWidgetPlaceholder(),
          SizedBox(height: 24),
          _MonthlyReminderCard(),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        PrimaryButton(label: strings.translate('cta_book_now'), icon: Icons.event_available, onPressed: () {}),
        PrimaryButton(label: strings.translate('cta_join'), icon: Icons.flag, onPressed: () {}),
        PrimaryButton(label: 'مسارات اليوم', icon: Icons.directions_walk, onPressed: () {}),
      ],
    );
  }
}

class _NearbySection extends StatelessWidget {
  const _NearbySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('قربك الآن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        _PlaceholderCard(title: 'ملعب كرة قدم', subtitle: '160 ر.س / ساعة'),
        _PlaceholderCard(title: 'تمرين شارع', subtitle: 'المستوى: متوسط'),
      ],
    );
  }
}

class _HealthWidgetPlaceholder extends StatelessWidget {
  const _HealthWidgetPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('الصحة اليوم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 16),
            _MetricRow(label: 'الوزن', value: '60 كجم'),
            _MetricRow(label: 'الخطوات', value: '7200'),
            _MetricRow(label: 'الماء', value: '2.3 لتر'),
          ],
        ),
      ),
    );
  }
}

class _MonthlyReminderCard extends StatelessWidget {
  const _MonthlyReminderCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            Icon(Icons.calendar_today),
            SizedBox(width: 12),
            Expanded(child: Text('تذكير: سجّل قياساتك الشهرية هذا الأسبوع.')),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_back_ios_new),
      ),
    );
  }
}

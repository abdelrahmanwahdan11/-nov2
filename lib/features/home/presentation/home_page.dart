import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/event.dart';
import '../../../core/models/venue.dart';
import '../../../core/services/providers.dart';
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
        children: [
          _QuickActions(strings: strings),
          const SizedBox(height: 24),
          _NearbySection(),
          const SizedBox(height: 24),
          const _HealthSummary(),
          const SizedBox(height: 24),
          const _MonthlyReminderCard(),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
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

class _NearbySection extends ConsumerWidget {
  const _NearbySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venuesAsync = ref.watch(venuesProvider);
    final eventsAsync = ref.watch(eventsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('قربك الآن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        venuesAsync.when(
          data: (venues) => _VenueList(venues: venues),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('خطأ في تحميل الملاعب: $error'),
        ),
        const SizedBox(height: 16),
        eventsAsync.when(
          data: (events) => _EventList(events: events),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('خطأ في تحميل الفعاليات: $error'),
        ),
      ],
    );
  }
}

class _VenueList extends StatelessWidget {
  const _VenueList({required this.venues});

  final List<Venue> venues;

  @override
  Widget build(BuildContext context) {
    if (venues.isEmpty) {
      return const Text('لا توجد ملاعب قريبة');
    }
    return Column(
      children: venues.take(3).map((venue) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.sports_soccer),
            title: Text(venue.name),
            subtitle: Text(venue.address),
            trailing: Text('${venue.rating.toStringAsFixed(1)} ★'),
          ),
        );
      }).toList(),
    );
  }
}

class _EventList extends StatelessWidget {
  const _EventList({required this.events});

  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Text('لا توجد فعاليات اليوم');
    }
    return Column(
      children: events.take(3).map((event) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.flag),
            title: Text(event.title),
            subtitle: Text('${event.timeWindow.name} • ${event.level.name}'),
            trailing: Text(event.fee == 0 ? 'مجاني' : '${event.fee} ر.س'),
          ),
        );
      }).toList(),
    );
  }
}

class _HealthSummary extends ConsumerWidget {
  const _HealthSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) {
      return const SizedBox.shrink();
    }
    final metricsAsync = ref.watch(healthMetricsProvider(user.id));
    return metricsAsync.when(
      data: (metrics) {
        final latest = metrics.isEmpty ? null : metrics.last;
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('الصحة اليوم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                _MetricRow(label: 'الوزن', value: latest?.weightKg?.toStringAsFixed(1) ?? '--'),
                _MetricRow(label: 'الخطوات', value: (latest?.steps ?? 0).toString()),
                _MetricRow(label: 'الماء (مل)', value: (latest?.waterMl ?? 0).toString()),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('خطأ في بيانات الصحة: $error'),
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

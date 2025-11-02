import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/i18n/strings.dart';
import '../../core/state/app_scope.dart';
import '../widgets/route_preview.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final locale = state.locale;
    final events = state.events;

    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.of(locale, 'explore')),
      ),
      body: events.isEmpty
          ? Center(child: Text(Strings.of(locale, 'no_results')))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.title, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        RoutePreview(points: event.previewPoints.isEmpty ? state.mockRoute() : event.previewPoints),
                        const SizedBox(height: 12),
                        Text(event.description, style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(label: Text(event.level)),
                            const SizedBox(width: 12),
                            Chip(label: Text(event.timeWindow)),
                            const Spacer(),
                            Text('${event.capacity - event.participants.length}/${event.capacity}'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => state.joinEvent(event.id, state.currentUser?.id ?? 'u_001'),
                              child: Text(Strings.of(locale, 'join')),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () => Navigator.pushNamed(context, '/events'),
                              child: const Text('المزيد'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 280.ms, delay: (index * 90).ms).moveY(begin: 18, end: 0);
              },
            ),
    );
  }
}

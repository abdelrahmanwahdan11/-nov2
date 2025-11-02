import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/state/app_scope.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final events = state.events;
    final userId = state.currentUser?.id ?? 'u_001';

    return Scaffold(
      appBar: AppBar(title: const Text('الفعاليات')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final joined = event.participants.contains(userId);
          final remaining = event.capacity - event.participants.length;
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(event.description),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(label: Text(event.level)),
                      Chip(label: Text(event.timeWindow)),
                      Chip(label: Text('المتبقي: $remaining')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: joined
                            ? () => setState(() => state.leaveEvent(event.id, userId))
                            : () => setState(() => state.joinEvent(event.id, userId)),
                        child: Text(joined ? 'انسحب' : 'انضم'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => _showCheckInSheet(context, event.checkinCode(), event.startAt, event.endAt),
                        child: const Text('تأكيد الحضور'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 250.ms, delay: (index * 80).ms).moveY(begin: 12, end: 0);
        },
      ),
    );
  }

  Future<void> _showCheckInSheet(BuildContext context, String expected, DateTime start, DateTime end) async {
    final controller = TextEditingController();
    String? feedback;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('أدخل كود الحضور المكوّن من 6 أرقام', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: OutlineInputBorder(), counterText: ''),
                  ),
                  if (feedback != null) ...[
                    const SizedBox(height: 12),
                    Text(feedback!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final value = controller.text.trim();
                        final now = DateTime.now();
                        final windowStart = start.subtract(const Duration(minutes: 15));
                        final windowEnd = end.add(const Duration(minutes: 15));
                        final withinWindow = now.isAfter(windowStart) && now.isBefore(windowEnd);
                        setSheetState(() {
                          if (value == expected && withinWindow) {
                            feedback = 'تم تأكيد حضورك بنجاح';
                          } else if (!withinWindow) {
                            feedback = 'خارج النافذة الزمنية للتحقق';
                          } else {
                            feedback = 'الكود غير صحيح';
                          }
                        });
                      },
                      child: const Text('تأكيد'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

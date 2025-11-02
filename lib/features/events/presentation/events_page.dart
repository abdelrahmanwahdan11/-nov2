import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/models/event.dart';
import '../../../core/models/geo_point.dart';
import '../../../core/services/providers.dart';
import '../../../shared/services/notifications.dart';
import 'event_actions_controller.dart';

class EventsPage extends ConsumerStatefulWidget {
  const EventsPage({super.key});

  @override
  ConsumerState<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends ConsumerState<EventsPage> {
  final Set<String> _loadingEvents = {};

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الفعاليات')),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('الرجاء اختيار مستخدم')); 
          }
          return eventsAsync.when(
            data: (events) {
              if (events.isEmpty) {
                return const Center(child: Text('لا توجد فعاليات حالياً'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final joined = event.attendeeIds.contains(user.id);
                  final capacityLeft = event.capacity - event.attendeeIds.length;
                  final busy = _loadingEvents.contains(event.id);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
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
                              Chip(label: Text('المستوى: ${event.level.name}')),
                              Chip(label: Text('الوقت: ${event.timeWindow.name}')),
                              Chip(label: Text('رسوم: ${event.fee == 0 ? 'مجاني' : '${event.fee} ر.س'}')),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('السعة المتبقية: $capacityLeft'),
                          const SizedBox(height: 8),
                          Text('المتطلبات: ${event.requirements.join(', ')}'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: busy
                                      ? null
                                      : () => _onJoinLeave(event, user.id, joined),
                                  child: Text(joined ? 'انسحب' : 'انضم'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                onPressed: () => _checkInQr(event.id),
                                tooltip: 'تأكيد حضور QR',
                                icon: const Icon(Icons.qr_code_2),
                              ),
                              IconButton(
                                onPressed: () => _checkInGps(event),
                                tooltip: 'تأكيد حضور GPS',
                                icon: const Icon(Icons.my_location),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('خطأ: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('خطأ: $error')),
      ),
    );
  }

  Future<void> _onJoinLeave(Event event, String userId, bool joined) async {
    setState(() => _loadingEvents.add(event.id));
    final actions = ref.read(eventActionsProvider);
    try {
      if (joined) {
        await actions.leave(event.id, userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الانسحاب')));
        }
      } else {
        await actions.join(event.id, userId);
        final reminderTime = event.startAt.subtract(const Duration(minutes: 60));
        if (reminderTime.isAfter(DateTime.now())) {
          await notificationsService.scheduleReminder(
            id: event.hashCode,
            scheduledAt: reminderTime,
            title: 'تذكير فعالية',
            body: 'موعد ${event.title} يقترب',
          );
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الانضمام')));
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر التحديث: $error')));
      }
    } finally {
      if (mounted) {
        setState(() => _loadingEvents.remove(event.id));
      }
    }
  }

  Future<void> _checkInQr(String eventId) async {
    final actions = ref.read(eventActionsProvider);
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return _QrScannerSheet(
          onCode: (code) async {
            final isValid = code.contains(eventId) &&
                await actions.canCheckInQr(eventId, DateTime.now());
            if (!mounted) return;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(isValid ? 'تم تأكيد الحضور QR' : 'رمز غير صالح')),
            );
          },
        );
      },
    );
  }

  Future<void> _checkInGps(Event event) async {
    final actions = ref.read(eventActionsProvider);
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('إذن الموقع مرفوض');
      }
      final position = await Geolocator.getCurrentPosition();
      final isValid = await actions.canCheckInGps(
        event.id,
        GeoPoint(lat: position.latitude, lon: position.longitude),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isValid ? 'تم التحقق عبر GPS' : 'أنت بعيد عن موقع الحدث')), 
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر التحقق: $error')));
    }
  }
}

class _QrScannerSheet extends StatelessWidget {
  const _QrScannerSheet({required this.onCode});

  final ValueChanged<String> onCode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('امسح رمز الحضور'),
          ),
          Expanded(
            child: MobileScanner(
              onDetect: (capture) {
                final barcode = capture.barcodes.first.rawValue;
                if (barcode != null) {
                  onCode(barcode);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

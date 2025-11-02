import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/domain/repositories/booking_repository.dart';
import '../../../core/domain/repositories/event_repository.dart';
import '../../../core/models/notification_item.dart';
import '../../../core/services/providers.dart';
import '../../../shared/services/notifications.dart';

class ScanPageConfig {
  const ScanPageConfig({this.expectedType, this.expectedId});

  final String? expectedType;
  final String? expectedId;
}

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key, this.config});

  final ScanPageConfig? config;

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  final TextEditingController _manualController = TextEditingController();
  bool _processing = false;
  String? _status;

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('مسح رمز الحضور'),
        actions: [
          if (widget.config?.expectedType != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: Chip(label: Text(widget.config!.expectedType!)),
            ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('الرجاء اختيار مستخدم أولاً'));
          }
          return Column(
            children: [
              Expanded(
                child: MobileScanner(
                  onDetect: (capture) {
                    final code = capture.barcodes.first.rawValue;
                    if (code != null) {
                      _validatePayload(code, user.id);
                    }
                  },
                ),
              ),
              if (_processing) const LinearProgressIndicator(),
              if (_status != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _status!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _manualController,
                        decoration: const InputDecoration(
                          labelText: 'أدخل الرمز يدويًا',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        final value = _manualController.text.trim();
                        if (value.isNotEmpty) {
                          _validatePayload(value, user.id);
                        }
                      },
                      child: const Text('تحقق'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('خطأ: $error')),
      ),
    );
  }

  Future<void> _validatePayload(String raw, String currentUserId) async {
    if (_processing) return;
    setState(() {
      _processing = true;
      _status = null;
    });

    final parsed = _parsePayload(raw);
    if (parsed == null) {
      setState(() {
        _processing = false;
        _status = 'تعذر قراءة الرمز';
      });
      return;
    }

    if (widget.config?.expectedType != null && widget.config!.expectedType != parsed.type) {
      setState(() {
        _processing = false;
        _status = 'نوع الرمز لا يطابق السياق الحالي';
      });
      return;
    }

    if (widget.config?.expectedId != null && widget.config!.expectedId != parsed.id) {
      setState(() {
        _processing = false;
        _status = 'رمز لفعالية/حجز مختلف';
      });
      return;
    }

    bool valid = false;
    if (parsed.type == 'event') {
      final repository = ref.read(eventRepositoryProvider);
      valid = await repository.canCheckInWithQr(parsed.id, DateTime.now());
    } else if (parsed.type == 'booking') {
      final repository = ref.read(bookingRepositoryProvider);
      valid = await repository.canCheckInBooking(parsed.id, parsed.userId ?? currentUserId, DateTime.now());
    }

    setState(() {
      _processing = false;
      _status = valid ? 'تم التحقق من الرمز بنجاح' : 'الرمز خارج النافذة الزمنية أو غير صالح';
    });

    if (valid) {
      final notificationRepo = ref.read(notificationRepositoryProvider);
      await notificationRepo.upsertNotification(
        NotificationItem(
          id: 'scan_${parsed.type}_${parsed.id}_${DateTime.now().millisecondsSinceEpoch}',
          userId: currentUserId,
          title: 'تم التحقق من الحضور',
          body: parsed.type == 'event' ? 'تم تأكيد حضور الفعالية بنجاح.' : 'تم تأكيد حضور الحجز بنجاح.',
          createdAt: DateTime.now(),
          type: 'checkin',
        ),
      );
      await notificationsService.scheduleReminder(
        id: raw.hashCode,
        scheduledAt: DateTime.now().add(const Duration(minutes: 1)),
        title: 'تم تسجيل الحضور',
        body: 'شكراً لاستخدامك تطبيق ساحة.',
      );
      if (mounted) {
        Future<void>.delayed(const Duration(milliseconds: 600), () {
          if (mounted) context.pop(parsed);
        });
      }
    }
  }

  _QrPayload? _parsePayload(String raw) {
    if (raw.startsWith('booking:')) {
      final parts = raw.split(':');
      if (parts.length >= 3) {
        return _QrPayload(type: 'booking', id: parts[1], userId: parts[2]);
      }
    }
    if (raw.startsWith('event:')) {
      final parts = raw.split(':');
      if (parts.length >= 2) {
        return _QrPayload(type: 'event', id: parts[1], userId: parts.length >= 3 ? parts[2] : null);
      }
    }
    return null;
  }
}

class _QrPayload {
  const _QrPayload({required this.type, required this.id, this.userId});

  final String type;
  final String id;
  final String? userId;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../../core/models/enums.dart';
import '../../../core/models/geo_point.dart';
import '../../../core/models/notification_item.dart';
import '../../../core/services/providers.dart';

class CreatePage extends ConsumerStatefulWidget {
  const CreatePage({super.key});

  @override
  ConsumerState<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends ConsumerState<CreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController(text: 'حذاء مناسب');
  final _capacityController = TextEditingController(text: '10');
  final _feeController = TextEditingController(text: '0');
  Level _level = Level.beginner;
  EventType _type = EventType.walk;
  TimeWindow _timeWindow = TimeWindow.morning;
  DateTime _startAt = DateTime.now().add(const Duration(hours: 2));
  DateTime _endAt = DateTime.now().add(const Duration(hours: 3));
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _capacityController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء فعالية محلية')),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('الرجاء اختيار مستخدم لإنشاء الفعاليات'));
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'عنوان الفعالية'),
                  validator: (value) => value == null || value.isEmpty ? 'أدخل عنوانًا' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'الوصف'),
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty ? 'أدخل وصفًا' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<EventType>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'نوع الفعالية'),
                  items: EventType.values
                      .map((type) => DropdownMenuItem(value: type, child: Text(type.name)))
                      .toList(),
                  onChanged: (value) => setState(() => _type = value ?? _type),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Level>(
                  value: _level,
                  decoration: const InputDecoration(labelText: 'المستوى'),
                  items: Level.values
                      .map((level) => DropdownMenuItem(value: level, child: Text(level.name)))
                      .toList(),
                  onChanged: (value) => setState(() => _level = value ?? _level),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TimeWindow>(
                  value: _timeWindow,
                  decoration: const InputDecoration(labelText: 'فترة اليوم'),
                  items: TimeWindow.values
                      .map((time) => DropdownMenuItem(value: time, child: Text(time.name)))
                      .toList(),
                  onChanged: (value) => setState(() => _timeWindow = value ?? _timeWindow),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _requirementsController,
                  decoration: const InputDecoration(labelText: 'المتطلبات (مفصولة بفواصل)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _capacityController,
                  decoration: const InputDecoration(labelText: 'السعة'),
                  keyboardType: TextInputType.number,
                  validator: (value) => (int.tryParse(value ?? '') ?? 0) > 0 ? null : 'أدخل قيمة صالحة',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _feeController,
                  decoration: const InputDecoration(labelText: 'الرسوم (ر.س)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => double.tryParse(value ?? '') != null ? null : 'أدخل رقمًا',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DateButton(
                        label: 'تاريخ البدء',
                        value: _startAt,
                        onChanged: (value) => setState(() => _startAt = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateButton(
                        label: 'تاريخ الانتهاء',
                        value: _endAt,
                        onChanged: (value) => setState(() => _endAt = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _saving ? null : () => _submit(user.id),
                  icon: _saving ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check),
                  label: const Text('حفظ الفعالية'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('خطأ: $error')),
      ),
    );
  }

  Future<void> _submit(String organizerId) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _saving = true);
    try {
      GeoPoint location;
      try {
        final permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          throw const GeolocatorException(message: 'permission denied');
        }
        final position = await Geolocator.getCurrentPosition();
        location = GeoPoint(lat: position.latitude, lon: position.longitude);
      } catch (_) {
        location = const GeoPoint(lat: 24.7136, lon: 46.6753);
      }

      final requirements = _requirementsController.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();

      final repository = ref.read(eventRepositoryProvider);
      final notificationRepo = ref.read(notificationRepositoryProvider);
      final event = await repository.createEvent(
        type: _type,
        title: _titleController.text,
        description: _descriptionController.text,
        level: _level,
        requirements: requirements,
        timeWindow: _timeWindow,
        startAt: _startAt,
        endAt: _endAt,
        location: location,
        capacity: int.parse(_capacityController.text),
        fee: double.parse(_feeController.text),
        organizerId: organizerId,
      );

      await notificationRepo.upsertNotification(
        NotificationItem(
          id: 'ntf_create_${event.id}',
          userId: organizerId,
          title: 'تم إنشاء الفعالية',
          body: 'تم حفظ ${event.title} ويمكن دعوة الأصدقاء الآن.',
          createdAt: DateTime.now(),
          type: 'event',
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء الفعالية بنجاح')));
      setState(() {
        _titleController.clear();
        _descriptionController.clear();
        _requirementsController.text = 'حذاء مناسب';
        _capacityController.text = '10';
        _feeController.text = '0';
        _level = Level.beginner;
        _type = EventType.walk;
        _timeWindow = TimeWindow.morning;
        _startAt = DateTime.now().add(const Duration(hours: 2));
        _endAt = DateTime.now().add(const Duration(hours: 3));
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الحفظ: $error')));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({required this.label, required this.value, required this.onChanged});

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('dd MMM، HH:mm').format(value);
    return OutlinedButton(
      onPressed: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime.now().subtract(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date == null) return;
        final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(value));
        if (time == null) return;
        final selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        onChanged(selected);
      },
      child: Column(
        children: [
          Text(label),
          const SizedBox(height: 4),
          Text(formatted, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

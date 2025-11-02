import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/models/models.dart';
import '../../core/state/app_scope.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _capacityController = TextEditingController(text: '10');
  String _type = 'walk';
  String _level = 'beginner';
  String _timeWindow = 'morning';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء فعالية')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'العنوان'),
            ).animate().fadeIn(duration: 220.ms),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'الوصف'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'السعة'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _type,
              items: const [
                DropdownMenuItem(value: 'walk', child: Text('مسار مشي')),
                DropdownMenuItem(value: 'street', child: Text('تمرين شارع')),
                DropdownMenuItem(value: 'challenge', child: Text('تحدي')), 
              ],
              onChanged: (value) => setState(() => _type = value ?? 'walk'),
              decoration: const InputDecoration(labelText: 'النوع'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _level,
              items: const [
                DropdownMenuItem(value: 'beginner', child: Text('مبتدئ')),
                DropdownMenuItem(value: 'intermediate', child: Text('متوسط')),
                DropdownMenuItem(value: 'advanced', child: Text('متقدم')),
              ],
              onChanged: (value) => setState(() => _level = value ?? 'beginner'),
              decoration: const InputDecoration(labelText: 'المستوى'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _timeWindow,
              items: const [
                DropdownMenuItem(value: 'morning', child: Text('الصباح')),
                DropdownMenuItem(value: 'evening', child: Text('المساء')),
              ],
              onChanged: (value) => setState(() => _timeWindow = value ?? 'morning'),
              decoration: const InputDecoration(labelText: 'الوقت'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                if (_titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل عنوانًا')));
                  return;
                }
                final now = DateTime.now();
                final start = now.add(const Duration(hours: 1));
                final end = start.add(const Duration(hours: 1));
                final venue = state.venues.isNotEmpty ? state.venues.first : null;
                final event = Event(
                  id: 'e_${DateTime.now().millisecondsSinceEpoch}',
                  type: _type,
                  title: _titleController.text,
                  description: _descriptionController.text.isEmpty ? 'جلسة رائعة بالقرب منك' : _descriptionController.text,
                  level: _level,
                  requirements: const ['حماس', 'ماء'],
                  timeWindow: _timeWindow,
                  startAt: start,
                  endAt: end,
                  location: venue?.geo ?? const GeoPoint(lat: 24.7136, lon: 46.6753),
                  capacity: int.tryParse(_capacityController.text) ?? 10,
                  fee: 0,
                  organizerId: state.currentUser?.id ?? 'u_001',
                  participants: [],
                );
                state.addEvent(event);
                Navigator.pop(context);
              },
              child: const Text('حفظ الفعالية'),
            ).animate().fadeIn(duration: 240.ms).moveY(begin: 14, end: 0),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الحدث $eventId')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('تفاصيل الحدث', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('المتطلبات: ...'),
            SizedBox(height: 12),
            Text('المستوى: ...'),
            SizedBox(height: 12),
            Text('السعة: ...'),
            SizedBox(height: 24),
            Text('الانضمام والتحقق من الحضور محليًا.'),
          ],
        ),
      ),
    );
  }
}

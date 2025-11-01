import 'package:flutter/material.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الفعاليات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _EventCard(
            title: 'مسار مشي صباحي',
            details: 'المستوى: مبتدئ | السعة: 20',
            requirements: 'حذاء مريح، قارورة ماء',
          ),
          _EventCard(
            title: 'تمرين شارع مسائي',
            details: 'المستوى: متوسط | السعة: 15',
            requirements: 'قفازات، منشفة',
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.title,
    required this.details,
    required this.requirements,
  });

  final String title;
  final String details;
  final String requirements;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(details),
            const SizedBox(height: 8),
            Text('المتطلبات: $requirements'),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('انضم')),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('QR'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

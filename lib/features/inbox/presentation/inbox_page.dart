import 'package:flutter/material.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الرسائل')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text('دعوة رقم ${index + 1}'),
              subtitle: const Text('تفاصيل محلية حول الحدث أو الحجز.'),
              trailing: const Icon(Icons.mark_chat_unread_outlined),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: 5,
      ),
    );
  }
}

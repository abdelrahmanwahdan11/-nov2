import 'package:flutter/material.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء')), 
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('ابدأ تحديًا أو حدثًا جديدًا', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('يمكنك إعداد حجز ودعوة الأصدقاء وتقسيم الدفع محليًا.'),
            SizedBox(height: 24),
            _CreateOptionCard(title: 'حجز ملعب', description: 'حدد ملعبك المفضل وحدد الوقت والسعر.'),
            _CreateOptionCard(title: 'تحدي شارع', description: 'خطط لتمرين جديد وحدد المتطلبات.'),
            _CreateOptionCard(title: 'مسار مشي', description: 'اختر المسار وحدد فترة الصباح أو المساء.'),
          ],
        ),
      ),
    );
  }
}

class _CreateOptionCard extends StatelessWidget {
  const _CreateOptionCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_back_ios_new),
      ),
    );
  }
}

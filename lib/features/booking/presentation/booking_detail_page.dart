import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BookingDetailPage extends StatelessWidget {
  const BookingDetailPage({super.key, required this.fieldId});

  final String fieldId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الحجز $fieldId')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _imageCarousel(),
          const SizedBox(height: 24),
          const _AvailabilityGrid(),
          const SizedBox(height: 24),
          _pricingCard(context),
          const SizedBox(height: 24),
          _qrSection(),
        ],
      ),
    );
  }

  Widget _imageCarousel() {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: 3,
        itemBuilder: (_, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.grey.shade300,
              child: Center(child: Text('صورة ${index + 1}')),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pricingCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('السعر وسياسة الإلغاء', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('160 ر.س / ساعة'),
            const SizedBox(height: 8),
            const Text('سياسة الإلغاء: قبل 6 ساعات'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.payment),
              label: const Text('ادفع'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.group),
              label: const Text('تقسيم الدفع'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qrSection() {
    final data = 'booking:$fieldId:user:u_001:${DateTime.now().toIso8601String()}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('تأكيد الحضور'),
            const SizedBox(height: 12),
            QrImageView(data: data, size: 160),
            const SizedBox(height: 8),
            const Text('يمكن مسح الرمز خلال 15 دقيقة من موعد الحجز.'),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityGrid extends StatelessWidget {
  const _AvailabilityGrid();

  @override
  Widget build(BuildContext context) {
    final slots = const [
      ('06:00', true),
      ('07:00', false),
      ('20:00', true),
      ('21:00', true),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('التوافر'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: slots
                  .map(
                    (slot) => FilterChip(
                      selected: slot.$2,
                      label: Text(slot.$1),
                      onSelected: (_) {},
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الصحة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _MetricInputCard(),
          SizedBox(height: 24),
          _DailyOverview(),
          SizedBox(height: 24),
          _TrendPlaceholder(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('إضافة قياس'),
        icon: const Icon(Icons.add_chart),
      ),
    );
  }
}

class _MetricInputCard extends StatelessWidget {
  const _MetricInputCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('قياسات الشهر', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'الوزن (كجم)')),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'محيط الخصر (سم)')),
          ],
        ),
      ),
    );
  }
}

class _DailyOverview extends StatelessWidget {
  const _DailyOverview();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            _StatRow(label: 'خطوات اليوم', value: '7,200'),
            Divider(),
            _StatRow(label: 'السعرات', value: '1,850'),
            Divider(),
            _StatRow(label: 'الماء', value: '2.3 لتر'),
          ],
        ),
      ),
    );
  }
}

class _TrendPlaceholder extends StatelessWidget {
  const _TrendPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: const Center(child: Text('رسم بياني للاتجاهات (Sparkline)')),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

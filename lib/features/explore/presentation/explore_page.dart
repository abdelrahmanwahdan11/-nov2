import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('استكشاف')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _MapPlaceholder(),
          SizedBox(height: 24),
          _FilterChips(),
          SizedBox(height: 24),
          _ResultList(),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: const Center(child: Icon(Icons.map, size: 48)),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    final filters = ['الوقت', 'السعر', 'المستوى', 'النوع'];
    return Wrap(
      spacing: 8,
      children: filters.map((label) => Chip(label: Text(label))).toList(),
    );
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Card(
          child: ListTile(
            leading: const Icon(Icons.sports_soccer),
            title: Text('نتيجة ${index + 1}'),
            subtitle: const Text('تفاصيل مرتبطة بالخريطة'),
            trailing: const Icon(Icons.arrow_back_ios_new),
          ),
        ),
      ),
    );
  }
}

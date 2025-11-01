import 'package:flutter/material.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المحفظة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _BalanceCard(),
          SizedBox(height: 24),
          _TransactionsList(),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('الرصيد التجريبي', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('450 ر.س', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('إيداع'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.payments),
                  label: const Text('سحب'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionsList extends StatelessWidget {
  const _TransactionsList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('سجل العمليات', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...List.generate(
          4,
          (index) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(index.isEven ? Icons.call_made : Icons.call_received),
              title: Text(index.isEven ? 'دفع محلي' : 'استرداد محلي'),
              subtitle: const Text('تم التنفيذ بنجاح بدون اتصال.'),
              trailing: Text(index.isEven ? '-80 ر.س' : '+120 ر.س'),
            ),
          ),
        ),
      ],
    );
  }
}

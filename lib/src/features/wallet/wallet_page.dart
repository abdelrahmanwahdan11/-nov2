import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/models/models.dart';
import '../../core/state/app_scope.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final userId = state.currentUser?.id ?? 'u_001';
    final balance = state.walletBalance(userId);
    final transactions = state.wallet.where((tx) => tx.userId == userId).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('المحفظة')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(colors: [Color(0xFF0BA360), Color(0xFF077C48)]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الرصيد الحالي', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(balance.toStringAsFixed(2), style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white)).animate().shimmer(duration: 1200.ms),
                ],
              ),
            ).animate().fadeIn(duration: 260.ms).moveY(begin: 18, end: 0),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'المبلغ'),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () => _addTx(context, state, userId, true),
                  child: const Text('إيداع'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => _addTx(context, state, userId, false),
                  child: const Text('سحب'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: transactions.isEmpty
                  ? const Center(child: Text('لا توجد عمليات'))
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        return ListTile(
                          leading: Icon(tx.type == 'credit' ? Icons.arrow_downward : Icons.arrow_upward, color: tx.type == 'credit' ? Colors.green : Colors.red),
                          title: Text('${tx.amount.toStringAsFixed(2)}'),
                          subtitle: Text(tx.createdAt.toLocal().toString()),
                        ).animate().fadeIn(duration: 200.ms, delay: (index * 70).ms);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTx(BuildContext context, AppState state, String userId, bool isCredit) {
    final value = double.tryParse(_amountController.text);
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل مبلغًا صحيحًا')));
      return;
    }
    final tx = WalletTx(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      amount: value,
      type: isCredit ? 'credit' : 'debit',
      createdAt: DateTime.now(),
      note: isCredit ? 'إيداع يدوي' : 'سحب يدوي',
    );
    state.addWalletTx(tx);
    _amountController.clear();
  }
}

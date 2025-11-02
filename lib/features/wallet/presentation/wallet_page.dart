import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/wallet_tx.dart';
import '../../../core/models/enums.dart';
import '../../../core/services/providers.dart';
import 'wallet_controller.dart';

class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final controllerState = ref.watch(walletControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('المحفظة')),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('الرجاء اختيار مستخدم لعرض الرصيد'));
          }
          final transactionsAsync = ref.watch(walletProvider(user.id));
          return transactionsAsync.when(
            data: (txs) {
              final balance = _calculateBalance(txs);
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _BalanceCard(
                    balance: balance,
                    loading: controllerState.isLoading,
                    onDeposit: (amount) => _onAddTransaction(ref, user.id, amount, WalletType.credit, 'إيداع يدوي'),
                    onWithdraw: (amount) => _onAddTransaction(ref, user.id, amount, WalletType.debit, 'سحب يدوي'),
                  ),
                  const SizedBox(height: 24),
                  _TransactionsList(transactions: txs),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('خطأ: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('خطأ: $error')),
      ),
    );
  }

  double _calculateBalance(List<WalletTx> txs) {
    return txs.fold(0.0, (value, tx) {
      return tx.type == WalletType.credit ? value + tx.amount : value - tx.amount;
    });
  }

  Future<void> _onAddTransaction(
    WidgetRef ref,
    String userId,
    double amount,
    WalletType type,
    String note,
  ) async {
    final notifier = ref.read(walletControllerProvider.notifier);
    await notifier.addTransaction(
      WalletTx(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        amount: amount,
        type: type,
        createdAt: DateTime.now(),
        note: note,
      ),
    );
  }
}

class _BalanceCard extends StatefulWidget {
  const _BalanceCard({
    required this.balance,
    required this.loading,
    required this.onDeposit,
    required this.onWithdraw,
  });

  final double balance;
  final bool loading;
  final Future<void> Function(double amount) onDeposit;
  final Future<void> Function(double amount) onWithdraw;

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard> {
  final TextEditingController _amountController = TextEditingController(text: '50');

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('الرصيد الحالي', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('${widget.balance.toStringAsFixed(2)} ر.س', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المبلغ', suffixText: 'ر.س'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: widget.loading
                      ? null
                      : () {
                          final amount = double.tryParse(_amountController.text) ?? 0;
                          if (amount <= 0) return;
                          widget.onDeposit(amount);
                        },
                  icon: const Icon(Icons.add),
                  label: const Text('إيداع'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: widget.loading
                      ? null
                      : () {
                          final amount = double.tryParse(_amountController.text) ?? 0;
                          if (amount <= 0) return;
                          widget.onWithdraw(amount);
                        },
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
  const _TransactionsList({required this.transactions});

  final List<WalletTx> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Text('لا توجد عمليات بعد.');
    }
    final formatter = DateFormat('dd/MM HH:mm');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('سجل العمليات', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...transactions.map(
          (tx) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(tx.type == WalletType.credit ? Icons.call_received : Icons.call_made),
              title: Text(tx.note ?? (tx.type == WalletType.credit ? 'رصيد وارد' : 'دفع خارج')), 
              subtitle: Text(formatter.format(tx.createdAt)),
              trailing: Text(
                '${tx.type == WalletType.credit ? '+' : '-'}${tx.amount.toStringAsFixed(2)} ر.س',
                style: TextStyle(color: tx.type == WalletType.credit ? Colors.green : Colors.red),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

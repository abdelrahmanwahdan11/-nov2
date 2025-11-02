import 'dart:async';
import 'package:collection/collection.dart';

import '../../../core/data/hive/hive_boxes.dart';
import '../../../core/data/hive/hive_manager.dart';
import '../../../core/domain/repositories/wallet_repository.dart';
import '../../../core/models/wallet_tx.dart';

class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl() : _manager = HiveManager.instance;

  final HiveManager _manager;

  @override
  Stream<List<WalletTx>> watchTransactions(String userId) {
    final box = _manager.box<WalletTx>(HiveBoxes.wallet);
    final controller = StreamController<List<WalletTx>>.broadcast();

    void emit() {
      final txs = box.values
          .where((tx) => tx.userId == userId)
          .sorted((a, b) => b.createdAt.compareTo(a.createdAt))
          .toList();
      controller.add(txs);
    }

    emit();
    final sub = box.watch().listen((_) => emit());
    controller.onCancel = () => sub.cancel();
    return controller.stream;
  }

  @override
  Future<void> addTransaction(WalletTx tx) async {
    await _manager.box<WalletTx>(HiveBoxes.wallet).put(tx.id, tx);
  }
}

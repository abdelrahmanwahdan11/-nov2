import '../../models/wallet_tx.dart';

abstract class WalletRepository {
  Stream<List<WalletTx>> watchTransactions(String userId);
  Future<void> addTransaction(WalletTx tx);
}

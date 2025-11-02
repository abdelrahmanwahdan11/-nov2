import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/repositories/wallet_repository.dart';
import '../../../core/models/wallet_tx.dart';
import '../../../core/services/providers.dart';

class WalletController extends StateNotifier<AsyncValue<void>> {
  WalletController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  WalletRepository get _repository => _ref.read(walletRepositoryProvider);

  Future<void> addTransaction(WalletTx tx) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addTransaction(tx);
      state = const AsyncValue.data(null);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

final walletControllerProvider =
    StateNotifierProvider<WalletController, AsyncValue<void>>(
  (ref) => WalletController(ref),
);

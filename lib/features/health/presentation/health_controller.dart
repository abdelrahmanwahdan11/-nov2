import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/repositories/health_repository.dart';
import '../../../core/models/health_metric.dart';
import '../../../core/services/providers.dart';

class HealthController extends StateNotifier<AsyncValue<void>> {
  HealthController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  HealthRepository get _repository => _ref.read(healthRepositoryProvider);

  Future<void> saveMetric(HealthMetric metric) async {
    state = const AsyncValue.loading();
    try {
      await _repository.saveMetric(metric);
      state = const AsyncValue.data(null);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

final healthControllerProvider =
    StateNotifierProvider<HealthController, AsyncValue<void>>(
  (ref) => HealthController(ref),
);

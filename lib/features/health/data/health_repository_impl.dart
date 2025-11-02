import 'dart:async';
import 'package:collection/collection.dart';

import '../../../core/data/hive/hive_boxes.dart';
import '../../../core/data/hive/hive_manager.dart';
import '../../../core/domain/repositories/health_repository.dart';
import '../../../core/models/health_metric.dart';

class HealthRepositoryImpl implements HealthRepository {
  HealthRepositoryImpl() : _manager = HiveManager.instance;

  final HiveManager _manager;

  @override
  Stream<List<HealthMetric>> watchMetrics(String userId) {
    final box = _manager.box<HealthMetric>(HiveBoxes.healthMetrics);
    final controller = StreamController<List<HealthMetric>>.broadcast();

    void emit() {
      final metrics = box.values
          .where((metric) => metric.userId == userId)
          .sorted((a, b) => a.date.compareTo(b.date))
          .toList();
      controller.add(metrics);
    }

    emit();
    final sub = box.watch().listen((_) => emit());
    controller.onCancel = () => sub.cancel();
    return controller.stream;
  }

  @override
  Future<void> saveMetric(HealthMetric metric) async {
    await _manager.box<HealthMetric>(HiveBoxes.healthMetrics).put(metric.id, metric);
  }
}

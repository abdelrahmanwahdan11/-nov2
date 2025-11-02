import '../../models/health_metric.dart';

abstract class HealthRepository {
  Stream<List<HealthMetric>> watchMetrics(String userId);
  Future<void> saveMetric(HealthMetric metric);
}

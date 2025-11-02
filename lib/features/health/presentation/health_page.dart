import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/health_metric.dart';
import '../../../core/services/providers.dart';
import 'health_controller.dart';

class HealthPage extends ConsumerStatefulWidget {
  const HealthPage({super.key});

  @override
  ConsumerState<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends ConsumerState<HealthPage> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الصحة')),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('الرجاء اختيار مستخدم')); 
          }
          final metricsAsync = ref.watch(healthMetricsProvider(user.id));
          final controllerState = ref.watch(healthControllerProvider);
          return metricsAsync.when(
            data: (metrics) {
              final monthly = metrics.where((metric) => metric.isMonthly).toList();
              final daily = metrics.where((metric) => !metric.isMonthly).toList();
              final latest = metrics.isEmpty ? null : metrics.last;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _MetricCard(metric: latest),
                  const SizedBox(height: 24),
                  _DailyOverview(metrics: daily),
                  const SizedBox(height: 24),
                  _TrendSparkline(metrics: monthly),
                  if (controllerState.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMetric(context),
        label: const Text('إضافة قياس'),
        icon: const Icon(Icons.add_chart),
      ),
    );
  }

  Future<void> _showAddMetric(BuildContext context) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      return;
    }
    final weightController = TextEditingController();
    final waistController = TextEditingController();
    final stepsController = TextEditingController();
    final caloriesController = TextEditingController();
    final waterController = TextEditingController();
    bool isMonthly = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('إضافة قياس', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'الوزن (كجم)'),
                  ),
                  TextField(
                    controller: waistController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'محيط الخصر (سم)'),
                  ),
                  SwitchListTile(
                    value: isMonthly,
                    onChanged: (value) => setState(() => isMonthly = value),
                    title: const Text('قياس شهري'),
                  ),
                  TextField(
                    controller: stepsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'الخطوات'),
                  ),
                  TextField(
                    controller: caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'السعرات'),
                  ),
                  TextField(
                    controller: waterController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'الماء (مل)'),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: ElevatedButton(
                      onPressed: () async {
                        final metric = HealthMetric(
                          id: 'hm_${DateTime.now().millisecondsSinceEpoch}',
                          userId: user.id,
                          date: DateTime.now(),
                          weightKg: double.tryParse(weightController.text),
                          waistCm: double.tryParse(waistController.text),
                          steps: int.tryParse(stepsController.text),
                          calories: int.tryParse(caloriesController.text),
                          waterMl: int.tryParse(waterController.text),
                          isMonthly: isMonthly,
                        );
                        await ref.read(healthControllerProvider.notifier).saveMetric(metric);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم حفظ القياس')), 
                          );
                        }
                      },
                      child: const Text('حفظ'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({this.metric});

  final HealthMetric? metric;

  @override
  Widget build(BuildContext context) {
    if (metric == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('لا توجد قياسات بعد'),
            ],
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('آخر تحديث: ${metric!.date.toLocal().toString().substring(0, 16)}'),
            if (metric!.weightKg != null)
              Text('الوزن: ${metric!.weightKg!.toStringAsFixed(1)} كجم'),
            if (metric!.waistCm != null)
              Text('الخصر: ${metric!.waistCm!.toStringAsFixed(1)} سم'),
          ],
        ),
      ),
    );
  }
}

class _DailyOverview extends StatelessWidget {
  const _DailyOverview({required this.metrics});

  final List<HealthMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayMetrics = metrics.where((metric) =>
        metric.date.year == today.year &&
        metric.date.month == today.month &&
        metric.date.day == today.day);
    final steps = todayMetrics.fold<int>(0, (acc, metric) => acc + (metric.steps ?? 0));
    final calories = todayMetrics.fold<int>(0, (acc, metric) => acc + (metric.calories ?? 0));
    final water = todayMetrics.fold<int>(0, (acc, metric) => acc + (metric.waterMl ?? 0));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _StatRow(label: 'خطوات اليوم', value: steps.toString()),
            const Divider(),
            _StatRow(label: 'السعرات', value: calories.toString()),
            const Divider(),
            _StatRow(label: 'الماء (مل)', value: water.toString()),
          ],
        ),
      ),
    );
  }
}

class _TrendSparkline extends StatelessWidget {
  const _TrendSparkline({required this.metrics});

  final List<HealthMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final weights = metrics
        .where((metric) => metric.weightKg != null)
        .map((metric) => metric.weightKg!)
        .toList();
    if (weights.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        child: const Center(child: Text('لا توجد بيانات اتجاهات')), 
      );
    }
    return Card(
      child: SizedBox(
        height: 180,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CustomPaint(
            painter: _SparklinePainter(weights),
          ),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal == 0 ? 1 : maxVal - minVal;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = size.height - ((values[i] - minVal) / range * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

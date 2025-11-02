import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/models/models.dart';
import '../../core/state/app_scope.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  final _weightController = TextEditingController();
  final _stepsController = TextEditingController();
  final _waterController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _stepsController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final metrics = [...state.healthMetrics]..sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      appBar: AppBar(title: const Text('الصحة')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('أدخل قياساتك اليوم', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _HealthField(label: 'الوزن (كجم)', controller: _weightController),
              const SizedBox(height: 12),
              _HealthField(label: 'الخطوات', controller: _stepsController),
              const SizedBox(height: 12),
              _HealthField(label: 'الماء (مل)', controller: _waterController),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final metric = HealthMetric(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      date: DateTime.now(),
                      weightKg: double.tryParse(_weightController.text),
                      steps: int.tryParse(_stepsController.text),
                      waterMl: int.tryParse(_waterController.text),
                    );
                    state.addHealthMetric(metric);
                    _weightController.clear();
                    _stepsController.clear();
                    _waterController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ')));
                  },
                  child: const Text('حفظ'),
                ),
              ),
              const SizedBox(height: 24),
              if (metrics.isNotEmpty)
                _SparklineCard(
                  title: 'الوزن',
                  values: metrics.map((e) => e.weightKg ?? 0).toList(),
                  color: Theme.of(context).colorScheme.primary,
                ),
              const SizedBox(height: 16),
              if (metrics.isNotEmpty)
                _SparklineCard(
                  title: 'الخطوات',
                  values: metrics.map((e) => (e.steps ?? 0).toDouble()).toList(),
                  color: Theme.of(context).colorScheme.secondary,
                ),
              const SizedBox(height: 16),
              if (metrics.isNotEmpty)
                _SparklineCard(
                  title: 'الماء',
                  values: metrics.map((e) => (e.waterMl ?? 0).toDouble()).toList(),
                  color: const Color(0xFF1E88E5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthField extends StatelessWidget {
  const _HealthField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ).animate().fadeIn(duration: 220.ms);
  }
}

class _SparklineCard extends StatelessWidget {
  const _SparklineCard({required this.title, required this.values, required this.color});

  final String title;
  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: CustomPaint(
                painter: _SparklinePainter(values: values, color: color),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 260.ms).moveY(begin: 16, end: 0);
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxValue = values.reduce((a, b) => a > b ? a : b).clamp(1, double.infinity);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = (maxValue - minValue).abs().clamp(1, double.infinity);

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1 ? size.width / 2 : (i / (values.length - 1)) * size.width;
      final normalized = (values[i] - minValue) / range;
      final y = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => oldDelegate.values != values || oldDelegate.color != color;
}

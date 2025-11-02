import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../application/stores/app_store.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/signals/signal.dart';
import '../../widgets/primary_button.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  String _mode = 'week';

  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    final theme = Theme.of(context);
    return SignalBuilder<Map<String, dynamic>>(
      signal: AppStore.instance.planMetricsSignal,
      builder: (context, _, __) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(l10n.t('plan_overview'), style: theme.textTheme.displayLarge),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment<String>(
                    value: 'week',
                    label: Text(l10n.t('week')),
                    icon: const Icon(Icons.calendar_view_week),
                  ),
                  ButtonSegment<String>(
                    value: 'month',
                    label: Text(l10n.t('month')),
                    icon: const Icon(Icons.calendar_view_month),
                  ),
                ],
                showSelectedIcon: false,
                selected: <String>{_mode},
                onSelectionChanged: (selection) {
                  setState(() => _mode = selection.first);
                },
              ),
            ),
            const SizedBox(height: 16),
            _PlanCard(
              title: l10n.t('heatmap'),
              child: _Heatmap(mode: _mode),
            ),
            const SizedBox(height: 16),
            _PlanCard(
              title: l10n.t('weekly_activity'),
              child: _SparklinePlaceholder(color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            _PlanCard(
              title: l10n.t('completed_challenges'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _TimelineRow(label: '10K Steps', value: '✓'),
                  _TimelineRow(label: 'HIIT 3x', value: '✓'),
                  _TimelineRow(label: 'Yoga Streak', value: '5/30'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _PlanCard(
              title: l10n.t('next_bookings'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _TimelineRow(label: 'Padel Arena', value: 'الغد 19:00'),
                  _TimelineRow(label: 'Walk Route', value: 'الخميس 06:00'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _PlanCard(
              title: l10n.t('quick_goals'),
              child: Row(
                children: [
                  Expanded(
                    child: _GoalTile(
                      icon: Icons.water_drop_outlined,
                      title: l10n.t('hydration'),
                      value: '6/8',
                      progress: 0.75,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GoalTile(
                      icon: Icons.directions_walk,
                      title: l10n.t('steps'),
                      value: _mode == 'week' ? '42K' : '180K',
                      progress: _mode == 'week' ? 0.6 : 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: l10n.t('ai_cta'),
              onPressed: () => AppRouter.instance.push('/ai'),
            ),
          ],
        );
      },
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Animate(
      effects: const [FadeEffect(duration: Duration(milliseconds: 350)), SlideEffect(begin: Offset(0, 0.1), end: Offset.zero)],
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    final height = mode == 'week' ? 90.0 : 140.0;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _HeatmapPainter(
          mode: mode,
          primary: Theme.of(context).colorScheme.primary,
          accent: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({required this.mode, required this.primary, required this.accent});

  final String mode;
  final Color primary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final columns = mode == 'week' ? 7 : 14;
    final rows = mode == 'week' ? 1 : 4;
    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;
    final random = math.Random(mode.hashCode);

    for (var c = 0; c < columns; c++) {
      for (var r = 0; r < rows; r++) {
        final intensity = random.nextDouble();
        final color = Color.lerp(primary, accent, intensity)!.withOpacity(0.35 + intensity * 0.4);
        final rect = Rect.fromLTWH(
          c * cellWidth + 2,
          r * cellHeight + 2,
          cellWidth - 4,
          cellHeight - 4,
        );
        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) {
    return oldDelegate.mode != mode || oldDelegate.primary != primary || oldDelegate.accent != accent;
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.progress,
  });

  final IconData icon;
  final String title;
  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 8,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePlaceholder extends StatelessWidget {
  const _SparklinePlaceholder({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: CustomPaint(
        painter: _SparklinePainter(color: color),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final path = Path();
    final points = [12.0, 40.0, 24.0, 60.0, 34.0, 30.0, 48.0, 70.0, 60.0];
    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - (points[i] / 80.0) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(value, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

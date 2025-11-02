import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../application/stores/app_store.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/signals/signal.dart';
import '../../widgets/primary_button.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

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
            _PlanCard(
              title: l10n.t('weekly_activity'),
              child: _SparklinePlaceholder(color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            _PlanCard(
              title: l10n.t('completed_challenges'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

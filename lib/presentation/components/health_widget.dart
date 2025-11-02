import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/utils/app_motion.dart';

class HealthWidget extends StatelessWidget {
  const HealthWidget({
    super.key,
    required this.metrics,
    required this.title,
  });

  final Map<String, double> metrics;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = AppMotion.duration(context, const Duration(milliseconds: 400));
    return Animate(
      effects: [
        FadeEffect(duration: duration),
        SlideEffect(begin: const Offset(0, 0.15), end: Offset.zero, duration: duration),
      ],
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.colorScheme.primary.withOpacity(0.8), theme.colorScheme.secondary.withOpacity(0.6)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge?.copyWith(color: Colors.black)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: metrics.entries
                  .map(
                    (entry) => Chip(
                      label: Text('${entry.key}: ${entry.value.toStringAsFixed(0)}'),
                      backgroundColor: Colors.black.withOpacity(0.1),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/utils/app_motion.dart';

class ShimmerPlaceholder extends StatelessWidget {
  const ShimmerPlaceholder({
    super.key,
    this.height = 120,
    this.width,
    this.borderRadius,
  });

  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseContainer = Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.25),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
    );
    if (!AppMotion.useShimmer(context)) {
      return baseContainer;
    }
    final duration = AppMotion.duration(context, const Duration(seconds: 2));
    return Animate(
      effects: [ShimmerEffect(duration: duration)],
      child: baseContainer,
    );
  }
}

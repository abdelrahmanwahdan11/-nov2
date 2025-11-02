import 'package:flutter/material.dart';

import '../../application/stores/app_store.dart';

class ReducedMotionScope extends InheritedWidget {
  const ReducedMotionScope({
    super.key,
    required this.reducedMotion,
    required super.child,
  });

  final bool reducedMotion;

  static bool of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ReducedMotionScope>();
    if (scope != null) {
      return scope.reducedMotion;
    }
    return AppStore.instance.reducedMotionSignal.value;
  }

  @override
  bool updateShouldNotify(ReducedMotionScope oldWidget) {
    return oldWidget.reducedMotion != reducedMotion;
  }
}

class AppMotion {
  const AppMotion._();

  static Duration duration(BuildContext context, Duration base) {
    final reduced = ReducedMotionScope.of(context);
    if (!reduced) {
      return base;
    }
    final half = base.inMilliseconds / 2;
    return Duration(milliseconds: half.clamp(1, base.inMilliseconds).round());
  }

  static bool useShimmer(BuildContext context) {
    return !ReducedMotionScope.of(context);
  }
}

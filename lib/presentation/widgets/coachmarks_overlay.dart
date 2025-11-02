import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'primary_button.dart';

class CoachmarkStep {
  const CoachmarkStep({
    required this.targetKey,
    required this.message,
  });

  final GlobalKey targetKey;
  final String message;
}

class CoachmarksOverlay extends StatefulWidget {
  const CoachmarksOverlay({
    super.key,
    required this.steps,
    required this.title,
    required this.nextLabel,
    required this.doneLabel,
    required this.skipLabel,
    required this.onFinish,
  });

  final List<CoachmarkStep> steps;
  final String title;
  final String nextLabel;
  final String doneLabel;
  final String skipLabel;
  final VoidCallback onFinish;

  @override
  State<CoachmarksOverlay> createState() => _CoachmarksOverlayState();
}

class _CoachmarksOverlayState extends State<CoachmarksOverlay> {
  final GlobalKey _overlayKey = GlobalKey();
  Rect? _targetRect;
  int _index = 0;

  CoachmarkStep get _currentStep => widget.steps[_index];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateRect());
  }

  @override
  void didUpdateWidget(CoachmarksOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.steps != widget.steps) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateRect());
    }
  }

  void _updateRect() {
    if (!mounted) return;
    final render = _currentStep.targetKey.currentContext?.findRenderObject() as RenderBox?;
    final overlayBox = _overlayKey.currentContext?.findRenderObject() as RenderBox?;
    if (render == null || overlayBox == null) {
      Future.delayed(const Duration(milliseconds: 120), _updateRect);
      return;
    }
    final targetGlobal = render.localToGlobal(Offset.zero);
    final topLeft = overlayBox.globalToLocal(targetGlobal);
    final rect = Rect.fromLTWH(topLeft.dx, topLeft.dy, render.size.width, render.size.height);
    setState(() => _targetRect = rect);
  }

  void _next() {
    if (_index < widget.steps.length - 1) {
      setState(() => _index += 1);
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateRect());
    } else {
      widget.onFinish();
    }
  }

  void _skip() {
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rect = _targetRect;
    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.72),
        child: Stack(
          key: _overlayKey,
          children: [
            if (rect != null) _HighlightFrame(rect: rect),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: Container(
                    key: ValueKey<int>(_index),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _currentStep.message,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            TextButton(
                              onPressed: _skip,
                              child: Text(widget.skipLabel),
                            ),
                            const Spacer(),
                            PrimaryButton(
                              label: _index == widget.steps.length - 1
                                  ? widget.doneLabel
                                  : widget.nextLabel,
                              onPressed: _next,
                              expand: false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightFrame extends StatefulWidget {
  const _HighlightFrame({required this.rect});

  final Rect rect;

  @override
  State<_HighlightFrame> createState() => _HighlightFrameState();
}

class _HighlightFrameState extends State<_HighlightFrame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rect = widget.rect;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
      left: rect.left - 16,
      top: rect.top - 16,
      width: rect.width + 32,
      height: rect.height + 32,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final glow = 12 + _animation.value * 12;
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.25),
                    blurRadius: glow,
                    spreadRadius: math.max(1, _animation.value * 3),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

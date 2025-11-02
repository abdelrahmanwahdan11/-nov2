import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/catalog_item.dart';
import '../../core/localization/app_localizations.dart';

class CatalogItemOverlay extends StatefulWidget {
  const CatalogItemOverlay({
    super.key,
    required this.item,
    required this.heroTag,
    this.onPrimaryAction,
  });

  final CatalogItem item;
  final String heroTag;
  final VoidCallback? onPrimaryAction;

  static Future<void> show(
    BuildContext context, {
    required CatalogItem item,
    required String heroTag,
    VoidCallback? onPrimaryAction,
  }) {
    return Navigator.of(context).push(PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black87.withOpacity(0.75),
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: CatalogItemOverlay(
            item: item,
            heroTag: heroTag,
            onPrimaryAction: onPrimaryAction,
          ),
        );
      },
    ));
  }

  @override
  State<CatalogItemOverlay> createState() => _CatalogItemOverlayState();
}

class _CatalogItemOverlayState extends State<CatalogItemOverlay> {
  bool _showBack = false;
  double _dragOffset = 0;

  void _toggleCard() {
    setState(() => _showBack = !_showBack);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _dragOffset += details.primaryDelta ?? 0;
    if (_dragOffset > 80) {
      Navigator.of(context).pop();
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    _dragOffset = 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      onVerticalDragUpdate: _handleDragUpdate,
      onVerticalDragEnd: _handleDragEnd,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: widget.heroTag,
                child: Material(
                  color: Colors.transparent,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 250),
                    scale: 1.0,
                    child: GestureDetector(
                      onTap: _toggleCard,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 450),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeInBack,
                          transitionBuilder: _transitionBuilder,
                          layoutBuilder: (currentChild, previousChildren) {
                            return Stack(
                              alignment: Alignment.center,
                              children: <Widget>[if (currentChild != null) currentChild, ...previousChildren],
                            );
                          },
                          child: _showBack
                              ? _BackCard(
                                  key: const ValueKey('back'),
                                  item: widget.item,
                                  theme: theme,
                                  l10n: l10n,
                                  onPrimaryAction: widget.onPrimaryAction,
                                  close: () => Navigator.of(context).pop(),
                                )
                              : _FrontCard(
                                  key: const ValueKey('front'),
                                  item: widget.item,
                                  theme: theme,
                                  l10n: l10n,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 24,
              child: IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _transitionBuilder(Widget child, Animation<double> animation) {
    final rotateAnim = Tween<double>(begin: math.pi, end: 0).animate(animation);
    return AnimatedBuilder(
      animation: rotateAnim,
      child: child,
      builder: (context, child) {
        final isBack = child!.key == const ValueKey('back');
        var value = rotateAnim.value;
        if (isBack) {
          value = -value;
        }
        final visible = value.abs() <= math.pi / 2;
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(value),
          alignment: Alignment.center,
          child: visible ? child : const SizedBox.shrink(),
        );
      },
    );
  }
}

class _FrontCard extends StatelessWidget {
  const _FrontCard({
    super.key,
    required this.item,
    required this.theme,
    required this.l10n,
  });

  final CatalogItem item;
  final ThemeData theme;
  final SahaLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Image.network(item.imageUrl, fit: BoxFit.cover),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Chip(
                  label: Text(item.level != null ? l10n.t(item.level!) : l10n.t('all')),
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  style: theme.textTheme.displayLarge?.copyWith(color: Colors.white),
                ),
                if (item.city != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.city!,
                            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  l10n.t('tap_to_flip'),
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackCard extends StatelessWidget {
  const _BackCard({
    super.key,
    required this.item,
    required this.theme,
    required this.l10n,
    required this.onPrimaryAction,
    required this.close,
  });

  final CatalogItem item;
  final ThemeData theme;
  final SahaLocalizations l10n;
  final VoidCallback? onPrimaryAction;
  final VoidCallback close;

  String _primaryCtaLabel() {
    switch (item.type) {
      case CatalogType.venue:
        return l10n.t('book_now');
      case CatalogType.challenge:
      case CatalogType.streetWorkout:
        return l10n.t('join_now');
      case CatalogType.walkRoute:
      case CatalogType.training:
        return l10n.t('start_now');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.98),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (item.level != null)
                _InfoChip(icon: Icons.military_tech, label: l10n.t(item.level!)),
              if (item.pricePerHour != null)
                _InfoChip(icon: Icons.attach_money, label: '${item.pricePerHour!.toStringAsFixed(0)} ₪/h'),
              if (item.distanceKm != null)
                _InfoChip(icon: Icons.route, label: '${item.distanceKm!.toStringAsFixed(1)} km'),
              if (item.time != null)
                _InfoChip(icon: Icons.access_time, label: item.time!),
              if (item.pace != null)
                _InfoChip(icon: Icons.speed, label: item.pace!),
              if (item.metric != null)
                _InfoChip(icon: Icons.flag, label: '${item.metric}: ${item.goal ?? ''}'),
              if (item.durationMinutes != null)
                _InfoChip(icon: Icons.timer, label: '${item.durationMinutes} min'),
              if (item.kcal != null)
                _InfoChip(icon: Icons.local_fire_department, label: '${item.kcal} kcal'),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            item.city ?? '',
            style: theme.textTheme.bodyLarge,
          ),
          if (item.sport != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('${l10n.t('sport_type')}: ${item.sport}'),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onPrimaryAction,
            child: Text(_primaryCtaLabel()),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: close,
            child: Text(l10n.t('close')),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: theme.textTheme.bodyMedium),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../application/stores/app_store.dart';
import '../../core/constants/app_gradients.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/signals/signal.dart';
import '../../domain/entities/catalog_item.dart';
import 'primary_button.dart';

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

  Future<void> _toggleSaved(SahaLocalizations l10n) async {
    final store = AppStore.instance;
    final wasSaved = store.savedItemsSignal.value.contains(widget.item.id);
    await store.toggleSavedItem(widget.item.id);
    await HapticFeedback.lightImpact();
    if (!mounted) return;
    final message = wasSaved ? l10n.t('unlike') : l10n.t('like');
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text('$message · ${widget.item.title}')),
      );
  }

  void _showShareDialog(SahaLocalizations l10n) {
    final link = 'saha://item/${widget.item.id}';
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.t('share')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.t('deeplink_label')),
              const SizedBox(height: 12),
              SelectableText(link, style: Theme.of(dialogContext).textTheme.bodyLarge),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.t('cancel')),
            ),
            PrimaryButton(
              label: l10n.t('copy_link'),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: link));
                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.t('link_copied'))),
                );
              },
              expand: false,
            ),
          ],
        );
      },
    );
  }

  void _handleDoubleTap(SahaLocalizations l10n) {
    _toggleSaved(l10n);
  }

  void _handleLongPress(SahaLocalizations l10n) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor.withOpacity(0.94),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      builder: (sheetContext) {
        final isSaved = AppStore.instance.savedItemsSignal.value.contains(widget.item.id);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.bookmark_add_outlined),
                title: Text(isSaved ? l10n.t('unlike') : l10n.t('like')),
                subtitle: Text(l10n.t('quick_actions')),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _toggleSaved(l10n);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: Text(l10n.t('share')),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showShareDialog(l10n);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: Text(l10n.t('close')),
                onTap: () => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        );
      },
    );
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
      behavior: HitTestBehavior.opaque,
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
                      onDoubleTap: () => _handleDoubleTap(l10n),
                      onLongPress: () => _handleLongPress(l10n),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: SignalBuilder<Set<String>>(
                          signal: AppStore.instance.savedItemsSignal,
                          builder: (context, savedItems, _) {
                            final isSaved = savedItems.contains(widget.item.id);
                            return AnimatedSwitcher(
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
                                      isSaved: isSaved,
                                      onToggleSave: () => _toggleSaved(l10n),
                                      onShare: () => _showShareDialog(l10n),
                                    )
                                  : _FrontCard(
                                      key: const ValueKey('front'),
                                      item: widget.item,
                                      theme: theme,
                                      l10n: l10n,
                                      isSaved: isSaved,
                                    ),
                            );
                          },
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
    required this.isSaved,
  });

  final CatalogItem item;
  final ThemeData theme;
  final SahaLocalizations l10n;
  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[];
    if (item.level != null) {
      badges.add(_Badge(icon: Icons.military_tech, label: l10n.t(item.level!)));
    }
    final price = item.pricePerHour ?? item.fee;
    if (price != null) {
      badges.add(_Badge(icon: Icons.attach_money, label: '${price.toStringAsFixed(0)} ₪'));
    }
    if (item.time != null && item.time!.isNotEmpty) {
      badges.add(_Badge(icon: Icons.access_time, label: item.time!));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              semanticLabel: item.title,
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Container(
                key: ValueKey(isSaved),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_outline,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(decoration: const BoxDecoration(gradient: AppGradients.imageOverlay)),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (badges.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: badges,
                  ),
                if (badges.isNotEmpty) const SizedBox(height: 12),
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
    required this.isSaved,
    required this.onToggleSave,
    required this.onShare,
  });

  final CatalogItem item;
  final ThemeData theme;
  final SahaLocalizations l10n;
  final VoidCallback? onPrimaryAction;
  final VoidCallback close;
  final bool isSaved;
  final VoidCallback onToggleSave;
  final VoidCallback onShare;

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
    final isArabic = l10n.languageCode == 'ar';
    final description = isArabic
        ? 'تجربة ${item.sport ?? 'نشاط'} تجريبية تعرض كيف سيبدو المحتوى الحقيقي داخل البطاقة المقلوبة.'
        : 'A demo ${item.sport ?? 'activity'} preview that illustrates how live content will appear on the flipped card.';
    final policy = isArabic
        ? 'محاكاة: الدفع، الانضمام، والسداد تجريبي — نوصي بالوصول قبل 10 دقائق والاستعداد لخيارات الدفع المشترك.'
        : 'Mocked flow: booking, join, and payments are simulated — arrive 10 minutes early and be ready for split payment.';

    final maxHeight = MediaQuery.of(context).size.height * 0.75;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
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
              if (item.city != null)
                Text(
                  item.city!,
                  style: theme.textTheme.bodyLarge,
                ),
              if (item.sport != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('${l10n.t('sport_type')}: ${item.sport}'),
                ),
              const SizedBox(height: 16),
              Text(description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              Divider(color: Colors.white.withOpacity(0.08)),
              const SizedBox(height: 12),
              Text(l10n.t('policies'), style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(policy, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _primaryCtaLabel(),
                onPressed: onPrimaryAction,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onToggleSave,
                icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_outline),
                label: Text(isSaved ? l10n.t('saved') : l10n.t('save')),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share_outlined),
                label: Text(l10n.t('share')),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: close,
                child: Text(l10n.t('close')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
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

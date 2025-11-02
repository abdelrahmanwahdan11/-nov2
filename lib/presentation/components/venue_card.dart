import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_gradients.dart';
import '../../domain/entities/catalog_item.dart';

class VenueCard extends StatelessWidget {
  const VenueCard({
    super.key,
    required this.item,
    required this.onTap,
    this.heroTag,
  });

  final CatalogItem item;
  final VoidCallback onTap;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = item.pricePerHour != null
        ? '${item.pricePerHour!.toStringAsFixed(0)} ₪/h'
        : (item.fee != null ? '${item.fee!.toStringAsFixed(0)} ₪' : '--');

    final card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.cardColor.withOpacity(0.8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    semanticLabel: item.title,
                  ),
                  Container(decoration: const BoxDecoration(gradient: AppGradients.imageOverlay)),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: Colors.white70),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.city ?? '-',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (item.level != null)
                      Chip(
                        label: Text(item.level!),
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.18),
                      ),
                    if (price != '--')
                      Chip(
                        label: Text(price),
                      ),
                    if (item.time != null)
                      Chip(
                        label: Text(item.time!),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final heroWrapped = heroTag != null
        ? Hero(tag: heroTag!, child: Material(type: MaterialType.transparency, child: card))
        : card;

    return Animate(
      effects: const [FadeEffect(duration: Duration(milliseconds: 300)), SlideEffect(begin: Offset(0, 0.1), end: Offset.zero)],
      child: GestureDetector(onTap: onTap, child: heroWrapped),
    );
  }
}

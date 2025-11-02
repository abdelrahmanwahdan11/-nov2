import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    final card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                semanticLabel: item.title,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.city ?? '-',
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text('${item.level ?? 'all'}'),
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                    ),
                    Text(
                      item.pricePerHour != null
                          ? '${item.pricePerHour!.toStringAsFixed(0)} ₪/h'
                          : (item.fee != null ? '${item.fee!.toStringAsFixed(0)} ₪' : '--'),
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
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

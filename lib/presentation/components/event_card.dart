import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/entities/catalog_item.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final CatalogItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Animate(
      effects: const [FadeEffect(duration: Duration(milliseconds: 300)), SlideEffect(begin: Offset(0, 0.1), end: Offset.zero)],
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        tileColor: theme.cardColor,
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            item.imageUrl,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(item.title, style: theme.textTheme.titleMedium),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Chip(
                label: Text(item.level ?? ''),
              ),
              const SizedBox(width: 8),
              if (item.time != null)
                Text(
                  item.time!,
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
        trailing: Icon(Icons.arrow_forward, color: theme.colorScheme.primary),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../application/services/catalog_service.dart';
import '../../core/localization/app_localizations.dart';

class CatalogSortMenu extends StatelessWidget {
  const CatalogSortMenu({
    super.key,
    required this.value,
    required this.onSelected,
  });

  final CatalogSortOption value;
  final ValueChanged<CatalogSortOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    return PopupMenuButton<CatalogSortOption>(
      tooltip: l10n.t('sort_by'),
      initialValue: value,
      onSelected: onSelected,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: CatalogSortOption.popular,
          child: Text(l10n.t('sort_popular')),
        ),
        PopupMenuItem(
          value: CatalogSortOption.priceLowHigh,
          child: Text(l10n.t('sort_price_low_high')),
        ),
        PopupMenuItem(
          value: CatalogSortOption.nearest,
          child: Text(l10n.t('sort_nearest')),
        ),
        PopupMenuItem(
          value: CatalogSortOption.timeSoonest,
          child: Text(l10n.t('sort_time_soonest')),
        ),
      ],
      icon: const Icon(Icons.sort),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../application/services/service_locator.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/catalog_item.dart';
import '../../components/venue_card.dart';
import '../../widgets/shimmer_placeholder.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, this.initialType});

  final CatalogType? initialType;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  CatalogType? _selectedType;
  String? _levelFilter;
  late Future<List<CatalogItem>> _future;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _future = ServiceLocator.instance.catalogService.loadAll();
  }

  void _applyFilters({CatalogType? type, String? level}) {
    setState(() {
      _selectedType = type;
      _levelFilter = level;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('catalog')),
        actions: [
          IconButton(
            onPressed: () => _applyFilters(type: null, level: null),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.t('filters_reset'),
          ),
        ],
      ),
      body: FutureBuilder<List<CatalogItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return GridView.count(
              padding: const EdgeInsets.all(24),
              crossAxisCount: 2,
              childAspectRatio: 0.74,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: const [
                ShimmerPlaceholder(),
                ShimmerPlaceholder(),
                ShimmerPlaceholder(),
                ShimmerPlaceholder(),
              ],
            );
          }
          final items = snapshot.data!
              .where((item) => _selectedType == null || item.type == _selectedType)
              .where((item) => _levelFilter == null || item.level == _levelFilter)
              .toList();

          return Column(
            children: [
              _FiltersBar(
                l10n: l10n,
                selectedType: _selectedType,
                levelFilter: _levelFilter,
                onTypeSelected: (type) => _applyFilters(type: type, level: _levelFilter),
                onLevelSelected: (level) => _applyFilters(type: _selectedType, level: level),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(child: Text(l10n.t('no_results')))
                    : GridView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: items.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.74,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Animate(
                            effects: const [FadeEffect(duration: Duration(milliseconds: 250))],
                            child: VenueCard(
                              item: item,
                              onTap: () {
                                switch (item.type) {
                                  case CatalogType.venue:
                                    AppRouter.instance.push('/booking/${item.id}');
                                    break;
                                  case CatalogType.walkRoute:
                                    AppRouter.instance.push('/event/${item.id}');
                                    break;
                                  case CatalogType.challenge:
                                  case CatalogType.streetWorkout:
                                  case CatalogType.training:
                                    AppRouter.instance.push('/event/${item.id}');
                                    break;
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.l10n,
    required this.selectedType,
    required this.levelFilter,
    required this.onTypeSelected,
    required this.onLevelSelected,
  });

  final SahaLocalizations l10n;
  final CatalogType? selectedType;
  final String? levelFilter;
  final ValueChanged<CatalogType?> onTypeSelected;
  final ValueChanged<String?> onLevelSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _FilterChip(
            label: l10n.t('venues'),
            selected: selectedType == CatalogType.venue,
            onSelected: (value) => onTypeSelected(value ? CatalogType.venue : null),
          ),
          const SizedBox(width: 12),
          _FilterChip(
            label: l10n.t('challenges'),
            selected: selectedType == CatalogType.challenge,
            onSelected: (value) => onTypeSelected(value ? CatalogType.challenge : null),
          ),
          const SizedBox(width: 12),
          _FilterChip(
            label: l10n.t('walk_routes'),
            selected: selectedType == CatalogType.walkRoute,
            onSelected: (value) => onTypeSelected(value ? CatalogType.walkRoute : null),
          ),
          const SizedBox(width: 12),
          _FilterChip(
            label: l10n.t('street_workout'),
            selected: selectedType == CatalogType.streetWorkout,
            onSelected: (value) => onTypeSelected(value ? CatalogType.streetWorkout : null),
          ),
          const SizedBox(width: 12),
          DropdownButton<String?>(
            value: levelFilter,
            hint: Text(l10n.t('level')),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.t('all'))),
              DropdownMenuItem(value: 'beginner', child: Text(l10n.t('beginner'))),
              DropdownMenuItem(value: 'intermediate', child: Text(l10n.t('intermediate'))),
              DropdownMenuItem(value: 'advanced', child: Text(l10n.t('advanced'))),
              DropdownMenuItem(value: 'all', child: Text(l10n.t('all_levels'))),
            ],
            onChanged: (value) => onLevelSelected(value == null ? null : value),
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(16),
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }
}

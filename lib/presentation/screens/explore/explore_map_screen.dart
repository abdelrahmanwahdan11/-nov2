import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../application/services/service_locator.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/catalog_item.dart';
import '../../widgets/catalog_item_overlay.dart';
import '../../widgets/shimmer_placeholder.dart';

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  final List<_ExploreEntry> _entries = [];
  bool _loading = true;
  String? _sportFilter;
  String? _levelFilter;
  String? _priceFilter;
  String? _timeWindowFilter;
  String? _distanceFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await ServiceLocator.instance.catalogService.loadAll();
    final withLocation = items.where((element) => element.lat != null && element.lon != null).toList();
    _entries
      ..clear()
      ..addAll(withLocation.map((item) {
        final distance = item.distanceKm ?? _mockDistance(item.id.hashCode);
        final timeWindow = _resolveTimeWindow(item.time);
        return _ExploreEntry(item: item, distanceKm: distance, timeWindow: timeWindow);
      }));
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    final theme = Theme.of(context);
    final filtered = _filteredEntries();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('explore_map')),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [
                  ShimmerPlaceholder(height: 220),
                  SizedBox(height: 16),
                  ShimmerPlaceholder(height: 120),
                  SizedBox(height: 12),
                  ShimmerPlaceholder(height: 120),
                ],
              )
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _MapMock(entries: filtered, l10n: l10n)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.t('map_overview'), style: theme.textTheme.titleLarge),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _FilterChip(
                                label: l10n.t('sport_type'),
                                value: _sportFilter,
                                options: _sportOptions(),
                                onSelected: (value) => setState(() => _sportFilter = value),
                              ),
                              _FilterChip(
                                label: l10n.t('level'),
                                value: _levelFilter,
                                options: const ['beginner', 'intermediate', 'advanced', 'all'],
                                optionLabelBuilder: (value) => l10n.t(value),
                                onSelected: (value) => setState(() => _levelFilter = value),
                              ),
                              _FilterChip(
                                label: l10n.t('price'),
                                value: _priceFilter,
                                options: const ['free', '<20', '20-40', '>40'],
                                onSelected: (value) => setState(() => _priceFilter = value),
                              ),
                              _FilterChip(
                                label: l10n.t('filters_time_window'),
                                value: _timeWindowFilter,
                                options: const ['morning', 'evening'],
                                optionLabelBuilder: (option) =>
                                    option == 'morning' ? l10n.t('time_window_morning') : l10n.t('time_window_evening'),
                                onSelected: (value) => setState(() => _timeWindowFilter = value),
                              ),
                              _FilterChip(
                                label: l10n.t('distance'),
                                value: _distanceFilter,
                                options: const ['short', 'medium', 'long'],
                                optionLabelBuilder: (option) {
                                  switch (option) {
                                    case 'short':
                                      return '<=3 km';
                                    case 'medium':
                                      return '3-6 km';
                                    case 'long':
                                      return '>6 km';
                                  }
                                  return option;
                                },
                                onSelected: (value) => setState(() => _distanceFilter = value),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('${filtered.length} ${l10n.t('search_results')}', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                  SliverList.separated(
                    itemBuilder: (context, index) {
                      final entry = filtered[index];
                      final item = entry.item;
                      final heroTag = 'catalog_${item.id}';
                      final priceText = item.pricePerHour != null
                          ? '${item.pricePerHour!.toStringAsFixed(0)} ₪/h'
                          : (item.fee != null ? '${item.fee!.toStringAsFixed(0)} ₪' : null);
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        leading: Hero(
                          tag: heroTag,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(item.imageUrl, width: 64, height: 64, fit: BoxFit.cover),
                          ),
                        ),
                        title: Text(item.title),
                        subtitle: Text('${entry.distanceKm.toStringAsFixed(1)} km · ${item.city ?? ''}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_timeWindowLabel(entry.timeWindow, l10n)),
                            if (priceText != null)
                              Text(priceText, style: theme.textTheme.bodySmall),
                          ],
                        ),
                        onTap: () => _openItem(entry.item),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: filtered.length,
                  ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
                ],
              ),
      ),
    );
  }

  List<_ExploreEntry> _filteredEntries() {
    return _entries.where((entry) {
      final item = entry.item;
      final sportMatch = _sportFilter == null || item.sport == _sportFilter;
      final levelMatch = _levelFilter == null || item.level == _levelFilter || (_levelFilter == 'all' && item.level != null);
      final priceMatch = _priceFilter == null || _matchesPrice(item, _priceFilter!);
      final timeMatch = _timeWindowFilter == null || entry.timeWindow == _timeWindowFilter;
      final distanceMatch = _distanceFilter == null || _matchesDistance(entry.distanceKm, _distanceFilter!);
      return sportMatch && levelMatch && priceMatch && timeMatch && distanceMatch;
    }).toList();
  }

  List<String> _sportOptions() {
    final set = <String>{};
    for (final entry in _entries) {
      final sport = entry.item.sport;
      if (sport != null && sport.isNotEmpty) {
        set.add(sport);
      }
    }
    return set.toList()..sort();
  }

  void _openItem(CatalogItem item) {
    final heroTag = 'catalog_${item.id}';
    CatalogItemOverlay.show(
      context,
      item: item,
      heroTag: heroTag,
      onPrimaryAction: () {
        Navigator.of(context).pop();
        switch (item.type) {
          case CatalogType.venue:
            AppRouter.instance.push('/booking/${item.id}');
            break;
          case CatalogType.challenge:
          case CatalogType.streetWorkout:
          case CatalogType.training:
          case CatalogType.walkRoute:
            AppRouter.instance.push('/event/${item.id}');
            break;
        }
      },
    );
  }

  double _mockDistance(int seed) {
    final random = math.Random(seed);
    return 1.5 + random.nextDouble() * 6.5;
  }

  String _resolveTimeWindow(String? time) {
    if (time == null || time.isEmpty) {
      return math.Random().nextBool() ? 'morning' : 'evening';
    }
    final hour = int.tryParse(time.split(':').first) ?? 12;
    return hour < 12 ? 'morning' : 'evening';
  }

  String _timeWindowLabel(String window, SahaLocalizations l10n) {
    return window == 'morning' ? l10n.t('time_window_morning') : l10n.t('time_window_evening');
  }

  bool _matchesPrice(CatalogItem item, String filter) {
    final price = item.pricePerHour ?? item.fee ?? 0;
    switch (filter) {
      case 'free':
        return price == 0;
      case '<20':
        return price > 0 && price < 20;
      case '20-40':
        return price >= 20 && price <= 40;
      case '>40':
        return price > 40;
    }
    return true;
  }

  bool _matchesDistance(double distance, String filter) {
    switch (filter) {
      case 'short':
        return distance <= 3;
      case 'medium':
        return distance > 3 && distance <= 6;
      case 'long':
        return distance > 6;
    }
    return true;
  }
}

class _MapMock extends StatelessWidget {
  const _MapMock({required this.entries, required this.l10n});

  final List<_ExploreEntry> entries;
  final SahaLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = width > 600 ? EdgeInsets.symmetric(horizontal: (width - 600) / 2) : EdgeInsets.zero;
    final hasEntries = entries.isNotEmpty;
    final latitudes = hasEntries ? entries.map((e) => e.item.lat!).toList() : [0.0];
    final longitudes = hasEntries ? entries.map((e) => e.item.lon!).toList() : [0.0];
    final minLat = latitudes.reduce(math.min);
    final maxLat = latitudes.reduce(math.max);
    final minLon = longitudes.reduce(math.min);
    final maxLon = longitudes.reduce(math.max);

    return Padding(
      padding: EdgeInsets.only(left: padding.horizontal / 2, right: padding.horizontal / 2, top: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 240,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F1216), Color(0xFF1F2731)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.25,
                  child: GridPaper(
                    color: Colors.white24,
                    divisions: 3,
                    interval: 60,
                    subdivisions: 2,
                  ),
                ),
              ),
              ...entries.map((entry) {
                final latRatio = maxLat == minLat ? 0.5 : (entry.item.lat! - minLat) / (maxLat - minLat);
                final lonRatio = maxLon == minLon ? 0.5 : (entry.item.lon! - minLon) / (maxLon - minLon);
                return Positioned(
                  left: lonRatio * (MediaQuery.of(context).size.width - padding.horizontal - 48) + 24,
                  top: (1 - latRatio) * 200 + 20,
                  child: _MapMarker(entry: entry),
                );
              }),
              Positioned(
                left: 24,
                top: 16,
                child: Text(l10n.t('map_overview'), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.entry});

  final _ExploreEntry entry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black87.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(entry.item.title, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
        const SizedBox(height: 4),
        Container(
          width: 14,
          height: 14,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [Color(0xFFCBF94E), Color(0xFFF72585)]),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
    this.optionLabelBuilder,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onSelected;
  final String Function(String option)? optionLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: DropdownButton<String?>(
          value: value,
          hint: Text(label),
          items: [
            DropdownMenuItem<String?>(value: null, child: Text(label)),
            ...options.map((option) {
              final labelText = optionLabelBuilder?.call(option) ?? option;
              return DropdownMenuItem<String?>(value: option, child: Text(labelText));
            }),
          ],
          onChanged: onSelected,
        ),
      ),
    );
  }
}

class _ExploreEntry {
  _ExploreEntry({required this.item, required this.distanceKm, required this.timeWindow});

  final CatalogItem item;
  final double distanceKm;
  final String timeWindow;
}

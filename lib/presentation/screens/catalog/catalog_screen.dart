import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../application/services/catalog_service.dart';
import '../../../application/services/service_locator.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/catalog_item.dart';
import '../../components/venue_card.dart';
import '../../widgets/catalog_item_overlay.dart';
import '../../widgets/catalog_sort_menu.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/shimmer_placeholder.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, this.initialType});

  final CatalogType? initialType;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  static const _pageSize = 10;
  CatalogType? _selectedType;
  String? _levelFilter;
  late final CatalogService _service;
  final ScrollController _scrollController = ScrollController();
  final List<CatalogItem> _items = [];
  bool _isLoading = false;
  bool _initialLoading = true;
  bool _hasMore = true;
  int _page = 0;
  CatalogSortOption _sortOption = CatalogSortOption.popular;
  String? _sportFilter;
  String? _durationFilter;
  String? _kcalFilter;
  String? _priceFilter;
  List<String> _sportOptions = [];

  static const List<String> _durationRanges = ['<30', '30-45', '45-60', '>60'];
  static const List<String> _kcalRanges = ['<200', '200-350', '350-500', '>500'];
  static const List<String> _priceRanges = ['free', '<20', '20-40', '>40'];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _service = ServiceLocator.instance.catalogService;
    _scrollController.addListener(_onScroll);
    _loadFilterOptions();
    _fetch(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFilterOptions() async {
    final items = await _service.loadAll();
    final sports = <String>{};
    for (final item in items) {
      final sport = item.sport;
      if (sport != null && sport.isNotEmpty) {
        sports.add(sport);
      }
    }
    if (!mounted) return;
    setState(() {
      _sportOptions = sports.toList()..sort();
    });
  }

  void _applyFilters({CatalogType? type, String? level}) {
    if (_selectedType == type && _levelFilter == level) {
      return;
    }
    setState(() {
      _selectedType = type;
      _levelFilter = level;
    });
    _fetch(reset: true);
  }

  void _applySort(CatalogSortOption option) {
    if (_sortOption == option) return;
    setState(() => _sortOption = option);
    _fetch(reset: true);
  }

  void _setSport(String? sport) {
    if (_sportFilter == sport) return;
    setState(() => _sportFilter = sport);
    _fetch(reset: true);
  }

  void _setDuration(String? range) {
    if (_durationFilter == range) return;
    setState(() => _durationFilter = range);
    _fetch(reset: true);
  }

  void _setKcal(String? range) {
    if (_kcalFilter == range) return;
    setState(() => _kcalFilter = range);
    _fetch(reset: true);
  }

  void _setPrice(String? range) {
    if (_priceFilter == range) return;
    setState(() => _priceFilter = range);
    _fetch(reset: true);
  }

  void _resetFilters() {
    setState(() {
      _selectedType = null;
      _levelFilter = null;
      _sportFilter = null;
      _durationFilter = null;
      _kcalFilter = null;
      _priceFilter = null;
    });
    _fetch(reset: true);
  }

  Future<void> _fetch({bool reset = false}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      if (reset) {
        _initialLoading = _items.isEmpty;
      }
    });

    if (reset) {
      _items.clear();
      _hasMore = true;
      _page = 0;
    }

    final result = await _service.loadPage(
      page: _page,
      pageSize: _pageSize,
      type: _selectedType,
      level: _levelFilter,
      sport: _sportFilter,
      durationRange: _durationFilter,
      kcalRange: _kcalFilter,
      priceRange: _priceFilter,
      sort: _sortOption,
    );

    setState(() {
      _items.addAll(result.items);
      _hasMore = result.hasMore;
      _page += result.items.isEmpty ? 0 : 1;
      _isLoading = false;
      _initialLoading = false;
    });
  }

  void _onScroll() {
    if (!_hasMore || _isLoading) return;
    if (_scrollController.position.extentAfter < 280) {
      _fetch();
    }
  }

  Future<void> _onRefresh() async {
    await _fetch(reset: true);
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
          case CatalogType.walkRoute:
          case CatalogType.challenge:
          case CatalogType.streetWorkout:
          case CatalogType.training:
            AppRouter.instance.push('/event/${item.id}');
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('catalog')),
        actions: [
          CatalogSortMenu(
            value: _sortOption,
            onSelected: _applySort,
          ),
          IconButton(
            onPressed: _resetFilters,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.t('filters_reset'),
          ),
          IconButton(
            onPressed: () => AppRouter.instance.push('/explore'),
            icon: const Icon(Icons.map_outlined),
            tooltip: l10n.t('explore_map'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: _FiltersBar(
                l10n: l10n,
                selectedType: _selectedType,
                levelFilter: _levelFilter,
                sportFilter: _sportFilter,
                durationFilter: _durationFilter,
                kcalFilter: _kcalFilter,
                priceFilter: _priceFilter,
                sportOptions: _sportOptions,
                durationOptions: _durationRanges,
                kcalOptions: _kcalRanges,
                priceOptions: _priceRanges,
                onTypeSelected: (type) => _applyFilters(type: type, level: _levelFilter),
                onLevelSelected: (level) => _applyFilters(type: _selectedType, level: level),
                onSportSelected: _setSport,
                onDurationSelected: _setDuration,
                onKcalSelected: _setKcal,
                onPriceSelected: _setPrice,
              ),
            ),
            if (_initialLoading)
              SliverLayoutBuilder(
                builder: (context, constraints) {
                  final layout = _gridLayoutForWidth(constraints.crossAxisExtent);
                  return SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: layout.padding, vertical: 24),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 320,
                        childAspectRatio: layout.cardRatio,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const ShimmerPlaceholder(),
                        childCount: 6,
                      ),
                    ),
                  );
                },
              )
            else if (_items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  title: l10n.t('no_results'),
                  icon: Icons.search_off,
                ),
              )
            else
              SliverLayoutBuilder(
                builder: (context, constraints) {
                  final layout = _gridLayoutForWidth(constraints.crossAxisExtent);
                  return SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: layout.padding, vertical: 24),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 320,
                        childAspectRatio: layout.cardRatio,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= _items.length) {
                            return const ShimmerPlaceholder();
                          }
                          final item = _items[index];
                          final heroTag = 'catalog_${item.id}';
                          return Animate(
                            effects: const [FadeEffect(duration: Duration(milliseconds: 220))],
                            child: VenueCard(
                              item: item,
                              heroTag: heroTag,
                              onTap: () => _openItem(item),
                            ),
                          );
                        },
                        childCount: _items.length + (_isLoading && _hasMore ? 2 : 0),
                      ),
                    ),
                  );
                },
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: _isLoading && !_initialLoading
                      ? Text(l10n.t('loading_more'), style: theme.textTheme.bodyMedium)
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _GridLayout _gridLayoutForWidth(double width) {
    if (width >= 900) {
      return const _GridLayout(padding: 24, cardRatio: 0.85);
    }
    if (width >= 600) {
      return const _GridLayout(padding: 20, cardRatio: 0.80);
    }
    return const _GridLayout(padding: 16, cardRatio: 0.74);
  }
}

class _GridLayout {
  const _GridLayout({required this.padding, required this.cardRatio});

  final double padding;
  final double cardRatio;
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.l10n,
    required this.selectedType,
    required this.levelFilter,
    required this.sportFilter,
    required this.durationFilter,
    required this.kcalFilter,
    required this.priceFilter,
    required this.sportOptions,
    required this.durationOptions,
    required this.kcalOptions,
    required this.priceOptions,
    required this.onTypeSelected,
    required this.onLevelSelected,
    required this.onSportSelected,
    required this.onDurationSelected,
    required this.onKcalSelected,
    required this.onPriceSelected,
  });

  final SahaLocalizations l10n;
  final CatalogType? selectedType;
  final String? levelFilter;
  final String? sportFilter;
  final String? durationFilter;
  final String? kcalFilter;
  final String? priceFilter;
  final List<String> sportOptions;
  final List<String> durationOptions;
  final List<String> kcalOptions;
  final List<String> priceOptions;
  final ValueChanged<CatalogType?> onTypeSelected;
  final ValueChanged<String?> onLevelSelected;
  final ValueChanged<String?> onSportSelected;
  final ValueChanged<String?> onDurationSelected;
  final ValueChanged<String?> onKcalSelected;
  final ValueChanged<String?> onPriceSelected;

  @override
  Widget build(BuildContext context) {
    final durationItems = [
      _FilterDropdownItem(value: null, label: l10n.t('duration_any')),
      ...durationOptions.map(
        (option) => _FilterDropdownItem(value: option, label: _durationLabel(option)),
      ),
    ];
    final kcalItems = [
      _FilterDropdownItem(value: null, label: l10n.t('kcal_any')),
      ...kcalOptions.map(
        (option) => _FilterDropdownItem(value: option, label: _kcalLabel(option)),
      ),
    ];
    final priceItems = [
      _FilterDropdownItem(value: null, label: l10n.t('price_any')),
      ...priceOptions.map(
        (option) => _FilterDropdownItem(value: option, label: _priceLabel(option)),
      ),
    ];
    final levelItems = [
      _FilterDropdownItem(value: null, label: l10n.t('all')),
      _FilterDropdownItem(value: 'beginner', label: l10n.t('beginner')),
      _FilterDropdownItem(value: 'intermediate', label: l10n.t('intermediate')),
      _FilterDropdownItem(value: 'advanced', label: l10n.t('advanced')),
      _FilterDropdownItem(value: 'all', label: l10n.t('all_levels')),
    ];
    final sportItems = [
      _FilterDropdownItem(value: null, label: l10n.t('sport_any')),
      ...sportOptions.map(
        (option) => _FilterDropdownItem(value: option, label: option),
      ),
    ];

    final filters = <Widget>[
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
      _DropdownFilter(
        label: l10n.t('level'),
        value: levelFilter,
        items: levelItems,
        onChanged: onLevelSelected,
      ),
      const SizedBox(width: 12),
      _DropdownFilter(
        label: l10n.t('sport_type'),
        value: sportFilter,
        items: sportItems,
        onChanged: onSportSelected,
      ),
      const SizedBox(width: 12),
      _DropdownFilter(
        label: l10n.t('duration'),
        value: durationFilter,
        items: durationItems,
        onChanged: onDurationSelected,
      ),
      const SizedBox(width: 12),
      _DropdownFilter(
        label: l10n.t('kcal'),
        value: kcalFilter,
        items: kcalItems,
        onChanged: onKcalSelected,
      ),
      const SizedBox(width: 12),
      _DropdownFilter(
        label: l10n.t('price'),
        value: priceFilter,
        items: priceItems,
        onChanged: onPriceSelected,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(children: filters),
    );
  }

  String _durationLabel(String option) {
    switch (option) {
      case '<30':
        return l10n.t('duration_under_30');
      case '30-45':
        return l10n.t('duration_30_45');
      case '45-60':
        return l10n.t('duration_45_60');
      case '>60':
        return l10n.t('duration_over_60');
    }
    return option;
  }

  String _kcalLabel(String option) {
    switch (option) {
      case '<200':
        return l10n.t('kcal_under_200');
      case '200-350':
        return l10n.t('kcal_200_350');
      case '350-500':
        return l10n.t('kcal_350_500');
      case '>500':
        return l10n.t('kcal_over_500');
    }
    return option;
  }

  String _priceLabel(String option) {
    switch (option) {
      case 'free':
        return l10n.t('price_free');
      case '<20':
        return l10n.t('price_under_20');
      case '20-40':
        return l10n.t('price_20_40');
      case '>40':
        return l10n.t('price_over_40');
    }
    return option;
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

class _FilterDropdownItem {
  const _FilterDropdownItem({required this.value, required this.label});

  final String? value;
  final String label;
}

class _DropdownFilter extends StatelessWidget {
  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<_FilterDropdownItem> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = items.length > 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      constraints: const BoxConstraints(minWidth: 140),
      child: DropdownButton<String?>(
        value: value,
        hint: Text(label),
        items: items
            .map(
              (item) => DropdownMenuItem<String?>(
                value: item.value,
                child: Text(item.label),
              ),
            )
            .toList(),
        onChanged: isEnabled ? onChanged : null,
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(16),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}

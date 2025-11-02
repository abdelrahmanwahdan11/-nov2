import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../application/services/catalog_service.dart';
import '../../../application/services/service_locator.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/catalog_item.dart';
import '../../components/venue_card.dart';
import '../../widgets/catalog_item_overlay.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _service = ServiceLocator.instance.catalogService;
    _scrollController.addListener(_onScroll);
    _fetch(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _applyFilters({CatalogType? type, String? level}) {
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
          PopupMenuButton<CatalogSortOption>(
            tooltip: l10n.t('sort_by'),
            initialValue: _sortOption,
            onSelected: _applySort,
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
          ),
          IconButton(
            onPressed: () => _applyFilters(type: null, level: null),
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
                onTypeSelected: (type) => _applyFilters(type: type, level: _levelFilter),
                onLevelSelected: (level) => _applyFilters(type: _selectedType, level: level),
              ),
            ),
            if (_initialLoading)
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    childAspectRatio: 0.74,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const ShimmerPlaceholder(),
                    childCount: 6,
                  ),
                ),
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
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    childAspectRatio: 0.74,
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

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconly/iconly.dart';

import '../../../application/services/service_locator.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/catalog_item.dart';
import '../../components/event_card.dart';
import '../../components/health_widget.dart';
import '../../components/hero_carousel_card.dart';
import '../../components/quick_action_button.dart';
import '../../components/venue_card.dart';
import '../../widgets/catalog_item_overlay.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/shimmer_placeholder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.quickActionsKey,
    this.searchBarKey,
  });

  final GlobalKey? quickActionsKey;
  final GlobalKey? searchBarKey;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HomeData> _load() async {
    final catalog = ServiceLocator.instance.catalogService;
    final venues = await catalog.getByType(CatalogType.venue);
    final workouts = await catalog.getByType(CatalogType.streetWorkout);
    final walks = await catalog.getByType(CatalogType.walkRoute);
    final challenges = await catalog.getByType(CatalogType.challenge);
    return _HomeData(
      venues: venues.take(6).toList(),
      workouts: workouts.take(4).toList(),
      walks: walks.take(4).toList(),
      challenges: challenges.take(4).toList(),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
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

    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<_HomeData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                ErrorState(
                  title: l10n.t('error_generic'),
                  subtitle: snapshot.error.toString(),
                  icon: Icons.error_outline,
                  retryLabel: l10n.t('retry'),
                  onRetry: _refresh,
                ),
              ],
            );
          }
          if (!snapshot.hasData) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: const [
                ShimmerPlaceholder(height: 180),
                SizedBox(height: 16),
                ShimmerPlaceholder(height: 120),
                SizedBox(height: 16),
                ShimmerPlaceholder(height: 240),
              ],
            );
          }

          final data = snapshot.data!;
          final topVenues = data.venues.take(4).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.t('today'), style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white54)),
                      const SizedBox(height: 8),
                      Text('SahaPlay', style: theme.textTheme.displayLarge),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: KeyedSubtree(
                    key: widget.searchBarKey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: l10n.t('search_hint'),
                            ),
                            onTap: () => AppRouter.instance.push('/search'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () => AppRouter.instance.push('/explore'),
                          icon: const Icon(Icons.map_outlined),
                          tooltip: l10n.t('explore_map'),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => AppRouter.instance.push('/catalog'),
                          icon: const Icon(Icons.tune),
                          tooltip: l10n.t('filters'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: KeyedSubtree(
                    key: widget.quickActionsKey,
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        QuickActionButton(
                          icon: IconlyLight.calendar,
                          label: l10n.t('book_field'),
                          onTap: () => AppRouter.instance.push('/catalog?type=venue'),
                        ),
                        QuickActionButton(
                          icon: IconlyLight.activity,
                          label: l10n.t('join_challenge'),
                          onTap: () => AppRouter.instance.push('/catalog?type=challenge'),
                        ),
                        QuickActionButton(
                          icon: IconlyLight.dumbbell,
                          label: l10n.t('street_workout'),
                          onTap: () => AppRouter.instance.push('/catalog?type=street_workout'),
                        ),
                        QuickActionButton(
                          icon: IconlyLight.location,
                          label: l10n.t('walk_routes'),
                          onTap: () => AppRouter.instance.push('/catalog?type=walk_route'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 220,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.86),
                    itemCount: data.venues.length,
                    itemBuilder: (context, index) {
                      final item = data.venues[index];
                      return HeroCarouselCard(
                        id: item.id,
                        imageUrl: item.imageUrl,
                        title: item.title,
                        subtitle: l10n.t('explore_now'),
                        heroTag: 'catalog_${item.id}',
                        onTap: () => _openItem(item),
                      );
                    },
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.t('book_field_title'), style: theme.textTheme.titleLarge),
                      TextButton(
                        onPressed: () => AppRouter.instance.push('/catalog?type=venue'),
                        child: Text(l10n.t('see_all')),
                      ),
                    ],
                  ),
                ),
              ),
              if (topVenues.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.74,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = topVenues[index];
                        return VenueCard(
                          item: item,
                          heroTag: 'catalog_${item.id}',
                          onTap: () => _openItem(item),
                        );
                      },
                      childCount: topVenues.length,
                    ),
                  ),
                ),
              if (topVenues.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: EmptyState(
                      title: l10n.t('no_results'),
                      icon: Icons.search_off,
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                sliver: SliverToBoxAdapter(
                  child: Text(l10n.t('today'), style: theme.textTheme.titleLarge),
                ),
              ),
              SliverList.separated(
                itemBuilder: (context, index) {
                  final item = data.workouts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: EventCard(
                      item: item,
                      heroTag: 'catalog_${item.id}',
                      onTap: () => _openItem(item),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: data.workouts.length,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  child: HealthWidget(
                    title: l10n.t('plan_overview'),
                    metrics: {
                      'Steps': 8500,
                      'Calories': 520,
                      'Water': 6,
                      'Sleep': 7,
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HomeData {
  const _HomeData({
    required this.venues,
    required this.workouts,
    required this.walks,
    required this.challenges,
  });

  final List<CatalogItem> venues;
  final List<CatalogItem> workouts;
  final List<CatalogItem> walks;
  final List<CatalogItem> challenges;
}

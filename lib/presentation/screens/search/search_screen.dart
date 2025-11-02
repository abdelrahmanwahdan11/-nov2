import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../application/services/catalog_service.dart';
import '../../../application/services/service_locator.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/catalog_item.dart';
import '../../widgets/catalog_item_overlay.dart';
import '../../widgets/shimmer_placeholder.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<CatalogItem> _results = [];
  late final CatalogService _service;
  bool _isSearching = false;
  bool _hasMore = false;
  bool _initial = true;
  int _page = 0;
  static const _pageSize = 10;
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _service = ServiceLocator.instance.catalogService;
    _controller.addListener(() => setState(() {}));
    _scrollController.addListener(_onScroll);
  }

  Future<void> _onSearch(String query) async {
    setState(() {
      _query = query;
      _initial = false;
    });
    await _fetch(reset: true);
  }

  Future<void> _fetch({bool reset = false}) async {
    if (_isSearching) return;
    setState(() => _isSearching = true);
    if (reset) {
      _results.clear();
      _hasMore = true;
      _page = 0;
    }
    final result = await _service.searchPaged(
      _query,
      page: _page,
      pageSize: _pageSize,
    );
    setState(() {
      _results.addAll(result.items);
      _hasMore = result.hasMore;
      if (result.items.isNotEmpty) {
        _page += 1;
      }
      _isSearching = false;
    });
  }

  void _onScroll() {
    if (!_hasMore || _isSearching) return;
    if (_scrollController.position.extentAfter < 200) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('search')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: l10n.t('search_hint'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _results.clear();
                            _query = '';
                            _page = 0;
                            _hasMore = false;
                            _initial = true;
                          });
                        },
                      )
                    : null,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _onSearch,
            ),
            const SizedBox(height: 24),
            if (_isSearching && _results.isEmpty) const LinearProgressIndicator(),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: Builder(
                  builder: (context) {
                    if (_initial && _results.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: 260,
                            child: Center(child: Text(l10n.t('search_hint'))),
                          ),
                        ],
                      );
                    }
                    if (_results.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: 220,
                            child: Center(child: Text(l10n.t('no_results'))),
                          ),
                        ],
                      );
                    }
                    return ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _results.length + (_isSearching && _hasMore ? 3 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index >= _results.length) {
                          return const ShimmerPlaceholder(height: 80);
                        }
                        final item = _results[index];
                        final subtitle = item.city ?? item.metric ?? '';
                        return Animate(
                          effects: const [FadeEffect(duration: Duration(milliseconds: 250))],
                          child: ListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            tileColor: theme.cardColor,
                            leading: Hero(
                              tag: 'catalog_${item.id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(item.imageUrl, width: 56, height: 56, fit: BoxFit.cover),
                              ),
                            ),
                            title: Text(item.title),
                            subtitle: Text(subtitle),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => _openItem(item),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

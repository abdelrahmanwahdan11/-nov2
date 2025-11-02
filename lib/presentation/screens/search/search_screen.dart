import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../application/services/service_locator.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/catalog_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<CatalogItem> _results = const [];
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSearch(String query) async {
    setState(() => _isSearching = true);
    final service = ServiceLocator.instance.catalogService;
    final items = await service.search(query);
    setState(() {
      _results = items;
      _isSearching = false;
    });
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
                          setState(() => _results = const []);
                        },
                      )
                    : null,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _onSearch,
            ),
            const SizedBox(height: 24),
            if (_isSearching) const LinearProgressIndicator(),
            const SizedBox(height: 12),
            Expanded(
              child: _results.isEmpty
                  ? Center(child: Text(l10n.t('no_results')))
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        return Animate(
                          effects: const [FadeEffect(duration: Duration(milliseconds: 250))],
                          child: ListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            tileColor: theme.cardColor,
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(item.imageUrl, width: 56, height: 56, fit: BoxFit.cover),
                            ),
                            title: Text(item.title),
                            subtitle: Text(item.city ?? item.metric ?? ''),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => AppRouter.instance.push('/event/${item.id}'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

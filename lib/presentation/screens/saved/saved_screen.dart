import 'package:flutter/material.dart';

import '../../../application/services/service_locator.dart';
import '../../../application/stores/app_store.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/signals/signal.dart';
import '../../../domain/entities/catalog_item.dart';
import '../../components/event_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    return SignalBuilder<Set<String>>(
      signal: AppStore.instance.savedItemsSignal,
      builder: (context, savedIds, _) {
        if (savedIds.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: EmptyState(
              title: l10n.t('saved_empty'),
              icon: Icons.bookmark_outline,
            ),
          );
        }

        final future = _load(savedIds);
        return FutureBuilder<List<CatalogItem>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: ErrorState(
                  title: l10n.t('error_generic'),
                  subtitle: snapshot.error.toString(),
                  icon: Icons.error_outline,
                  retryLabel: l10n.t('retry'),
                  onRetry: () => setState(() {}),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = snapshot.data!;
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: EmptyState(
                  title: l10n.t('saved_empty'),
                  icon: Icons.bookmark_outline,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => _refresh(savedIds),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final route = item.type == CatalogType.venue
                      ? '/booking/${item.id}'
                      : '/event/${item.id}';
                  return EventCard(
                    item: item,
                    onTap: () => AppRouter.instance.push(route),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: items.length,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _refresh(Set<String> ids) async {
    await _load(ids);
    if (mounted) {
      setState(() {});
    }
  }

  Future<List<CatalogItem>> _load(Set<String> ids) async {
    final service = ServiceLocator.instance.catalogService;
    final futures = ids.map(service.findById);
    final results = await Future.wait(futures);
    return results.whereType<CatalogItem>().toList();
  }
}

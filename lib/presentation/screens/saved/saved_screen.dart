import 'package:flutter/material.dart';

import '../../../application/services/service_locator.dart';
import '../../../application/stores/app_store.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/signals/signal.dart';
import '../../../domain/entities/catalog_item.dart';
import '../../components/event_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    return SignalBuilder<Set<String>>(
      signal: AppStore.instance.savedItemsSignal,
      builder: (context, savedIds, _) {
        if (savedIds.isEmpty) {
          return Center(
            child: Text(l10n.t('saved_empty'), textAlign: TextAlign.center),
          );
        }
        return FutureBuilder<List<CatalogItem>>(
          future: _load(savedIds),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data!;
            return ListView.separated(
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
            );
          },
        );
      },
    );
  }

  Future<List<CatalogItem>> _load(Set<String> ids) async {
    final service = ServiceLocator.instance.catalogService;
    final futures = ids.map(service.findById);
    final results = await Future.wait(futures);
    return results.whereType<CatalogItem>().toList();
  }
}

import 'package:flutter/material.dart';

import '../../../application/services/service_locator.dart';
import '../../../application/stores/app_store.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/signals/signal.dart';
import '../../../domain/entities/catalog_item.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    final theme = Theme.of(context);
    return FutureBuilder<CatalogItem?>(
      future: ServiceLocator.instance.catalogService.findById(itemId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final item = snapshot.data;
        if (item == null) {
          return Scaffold(appBar: AppBar(), body: Center(child: Text(l10n.t('no_results'))));
        }
        return Scaffold(
          appBar: AppBar(title: Text(item.title)),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => AppStore.instance.toggleSavedItem(item.id),
            label: SignalBuilder<Set<String>>(
              signal: AppStore.instance.savedItemsSignal,
              builder: (context, saved, _) {
                final isSaved = saved.contains(item.id);
                return Text(isSaved ? l10n.t('saved') : l10n.t('save'));
              },
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(item.imageUrl, height: 220, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                children: [
                  Chip(label: Text(item.level ?? '')), 
                  if (item.city != null) Chip(label: Text(item.city!)),
                  if (item.metric != null) Chip(label: Text(item.metric!)),
                ],
              ),
              const SizedBox(height: 16),
              Text(item.goal ?? '', style: theme.textTheme.bodyLarge),
              const SizedBox(height: 24),
              Text(l10n.t('ai_insight'), style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(l10n.t('ai_stub_msg')),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                child: Text(item.type == CatalogType.challenge ? l10n.t('join_now') : l10n.t('start_now')),
              ),
            ],
          ),
        );
      },
    );
  }
}

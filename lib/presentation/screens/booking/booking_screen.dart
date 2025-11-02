import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../application/services/service_locator.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../domain/entities/catalog_item.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.venueId});

  final String venueId;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late Future<CatalogItem?> _future;

  @override
  void initState() {
    super.initState();
    _future = ServiceLocator.instance.catalogService.findById(widget.venueId);
  }

  void _reload() {
    setState(() {
      _future = ServiceLocator.instance.catalogService.findById(widget.venueId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    return FutureBuilder<CatalogItem?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: ErrorState(
                title: l10n.t('error_generic'),
                subtitle: snapshot.error.toString(),
                icon: Icons.error_outline,
                retryLabel: l10n.t('retry'),
                onRetry: _reload,
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final venue = snapshot.data;
        if (venue == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: EmptyState(
                title: l10n.t('no_results'),
                icon: Icons.search_off,
              ),
            ),
          );
        }
        final theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(title: Text(venue.title)),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Hero(
                  tag: 'hero-card-${venue.id}',
                  child: Image.network(
                    venue.imageUrl,
                    height: 200,
                    fit: BoxFit.cover,
                    semanticLabel: venue.title,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('${venue.city} · ${venue.sport}', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              Text('${venue.pricePerHour?.toStringAsFixed(0) ?? '--'} ₪/h', style: theme.textTheme.titleLarge),
              const SizedBox(height: 24),
              Text(l10n.t('available_slots'), style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              _AvailabilityGrid(),
              const SizedBox(height: 24),
              Text(l10n.t('policies'), style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('• إلغاء قبل 6 ساعات\n• الدفع عند الوصول'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                child: Text(l10n.t('book_now')),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AvailabilityGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final slots = ['16:00', '17:00', '18:00', '19:00', '20:00', '21:00'];
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: slots
          .map(
            (slot) => Animate(
              effects: const [FadeEffect(duration: Duration(milliseconds: 200))],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.cardColor,
                ),
                child: Text(slot, style: theme.textTheme.bodyMedium),
              ),
            ),
          )
          .toList(),
    );
  }
}

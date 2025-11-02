import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../application/services/service_locator.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/app_motion.dart';
import '../../../domain/entities/catalog_item.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/primary_button.dart';

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
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            titleTextStyle: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
            title: Text(venue.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                onPressed: () => _showQrDialog(l10n),
                icon: const Icon(Icons.qr_code_2),
                tooltip: l10n.t('qr_checkin'),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              children: [
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Hero(
                    tag: 'hero-card-${venue.id}',
                    child: Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Image.network(
                          venue.imageUrl,
                          height: 240,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          semanticLabel: venue.title,
                        ),
                        Container(
                          height: 240,
                          decoration: const BoxDecoration(gradient: AppGradients.imageOverlay),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(venue.level != null ? l10n.t(venue.level!) : l10n.t('all')),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                venue.title,
                                style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (venue.city != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    '${venue.city} · ${venue.sport ?? ''}',
                                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('${venue.pricePerHour?.toStringAsFixed(0) ?? '--'} ₪/h', style: theme.textTheme.displaySmall),
                const SizedBox(height: 12),
                Text('${venue.city ?? ''} · ${venue.sport ?? ''}', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 24),
                Text(l10n.t('available_slots'), style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _AvailabilityGrid(),
                const SizedBox(height: 24),
                Text(l10n.t('policies'), style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('• إلغاء قبل 6 ساعات\n• الدفع عند الوصول', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 24),
                Text(l10n.t('quick_actions'), style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.groups_2_outlined),
                      label: Text(l10n.t('split_payment')),
                      onPressed: () => _showSplitPaymentSheet(l10n, venue),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.qr_code_2),
                      label: Text(l10n.t('qr_checkin')),
                      onPressed: () => _showQrDialog(l10n),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: l10n.t('book_now'),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(SnackBar(content: Text(l10n.t('signin_success'))));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSplitPaymentSheet(SahaLocalizations l10n, CatalogItem venue) {
    final price = venue.pricePerHour ?? venue.fee ?? 0;
    final participants = 4;
    final share = price == 0 ? 0 : price / participants;
    final totalText = price.toStringAsFixed(0);
    final shareText = share.toStringAsFixed(0);
    final summary = l10n.languageCode == 'ar'
        ? 'قسمة $totalText ₪ على $participants لاعبين = $shareText ₪ لكل لاعب.'
        : 'Splitting $totalText ₪ across $participants players equals $shareText ₪ each.';
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.groups_outlined, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(l10n.t('split_payment'), style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 16),
                Text(summary, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).cardColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 1; i <= participants; i++)
                        Padding(
                          padding: EdgeInsets.only(bottom: i == participants ? 0 : 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                child: Text('$i'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.languageCode == 'ar'
                                      ? 'لاعب رقم $i'
                                      : 'Player #$i',
                                ),
                              ),
                              Text('${share.toStringAsFixed(0)} ₪'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text(l10n.t('close')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQrDialog(SahaLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.t('qr_checkin')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
                  ),
                  child: const Center(
                    child: Icon(Icons.qr_code_2, size: 96),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.t('qr_checkin_hint'), textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.t('close')),
            ),
          ],
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
              effects: [
                FadeEffect(duration: AppMotion.duration(context, const Duration(milliseconds: 200))),
              ],
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

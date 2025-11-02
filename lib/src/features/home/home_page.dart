import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconly/iconly.dart';

import '../../core/i18n/strings.dart';
import '../../core/models/models.dart';
import '../../core/state/app_scope.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final locale = state.locale;
    final t = Strings.of(locale, 'welcome');
    final userName = state.currentUser?.name ?? 'زائر';

    return Scaffold(
      appBar: AppBar(
        title: Text('${Strings.of(locale, 'app_title')} · $userName'),
        actions: [
          IconButton(
            tooltip: Strings.of(locale, 'toggle_theme'),
            icon: Icon(state.darkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: state.toggleDark,
          ),
          IconButton(
            tooltip: Strings.of(locale, 'toggle_locale'),
            icon: const Icon(Icons.language),
            onPressed: () => state.setLocale(locale == 'ar' ? 'en' : 'ar'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create'),
        icon: const Icon(Icons.add),
        label: Text(Strings.of(locale, 'create')),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(IconlyLight.home), label: ''),
          NavigationDestination(icon: Icon(IconlyLight.location), label: ''),
          NavigationDestination(icon: Icon(IconlyLight.calendar), label: ''),
          NavigationDestination(icon: Icon(IconlyLight.chat), label: ''),
          NavigationDestination(icon: Icon(IconlyLight.profile), label: ''),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 1:
              Navigator.pushNamed(context, '/explore');
              break;
            case 2:
              Navigator.pushNamed(context, '/events');
              break;
            case 3:
              Navigator.pushNamed(context, '/inbox');
              break;
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
            default:
          }
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t, style: Theme.of(context).textTheme.titleLarge).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 12),
          _QuickActions(locale: locale),
          const SizedBox(height: 24),
          _UpcomingEvents(events: state.staggeredEvents(), locale: locale),
          const SizedBox(height: 24),
          _WalletSnapshot(locale: locale, balance: state.walletBalance(state.currentUser?.id ?? 'u_001')),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickActionData(Strings.of(locale, 'explore'), Icons.map_outlined, '/explore'),
      _QuickActionData(Strings.of(locale, 'booking'), Icons.sports_soccer, '/booking'),
      _QuickActionData(Strings.of(locale, 'health'), Icons.monitor_heart_outlined, '/health'),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final item in items)
          ElevatedButton.icon(
            icon: Icon(item.icon),
            label: Text(item.label),
            onPressed: () => Navigator.pushNamed(context, item.route),
          )
              .animate()
              .fadeIn(duration: 250.ms)
              .scale(delay: (items.indexOf(item) * 80).ms, begin: 0.92, end: 1),
      ],
    );
  }
}

class _QuickActionData {
  const _QuickActionData(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}

class _UpcomingEvents extends StatelessWidget {
  const _UpcomingEvents({required this.events, required this.locale});

  final List<Event> events;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Strings.of(locale, 'events'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...events.take(3).map((event) {
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              title: Text(event.title),
              subtitle: Text('${event.timeWindow} · ${event.level}'),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () => Navigator.pushNamed(context, '/events'),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: (events.indexOf(event) * 70).ms).moveX(begin: 16, end: 0);
        }),
      ],
    );
  }
}

class _WalletSnapshot extends StatelessWidget {
  const _WalletSnapshot({required this.locale, required this.balance});
  final String locale;
  final double balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0BA360),
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Strings.of(locale, 'wallet_balance'), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 12),
          Text(balance.toStringAsFixed(2), style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white)).animate().fadeIn().shimmer(duration: 1200.ms),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.pushNamed(context, '/wallet'),
            style: FilledButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2)),
            child: Text(Strings.of(locale, 'wallet')),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).moveY(begin: 24, end: 0);
  }
}
